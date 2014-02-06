//
//  OBSUser.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 05/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSUser+.h"

#import "OBSConnection.h"

@implementation OBSUser

- (void)dealloc
{
    _userId = nil;
    _userEmail = nil;
    _userName = nil;
    _userFile = nil;
}

+ (OBSUser *)userFromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata withClient:(id<OBSClientProtocol>)client
{
    NSString *userId = data[@"userId"];
    if (!userId || [userId isEqual:[NSNull null]]) {
        return nil; // userId is missing from JSON.
    }
    NSString *userEmail = data[@"email"];
    if (!userEmail || [userEmail isEqual:[NSNull null]]) {
        return nil; // User's e-mail is missing from JSON.
    }
    NSString *userName = data[@"userName"];
    if ([userName isEqual:[NSNull null]]) {
        userName = nil; // User has no name.
    }
    NSString *userFile = data[@"userFile"];
    if ([userFile isEqual:[NSNull null]]) {
        userFile = nil; // User has no file.
    }
    
    BOOL online = [data[@"online"] boolValue];

    CLLocation *userLastLocation = nil;
    NSString *lastLocationStr = data[@"lastLocation"];
    if ([lastLocationStr isEqual:[NSNull null]]) {
        lastLocationStr = nil;
    }
    if (lastLocationStr) {
        @try {
            NSArray *components = [lastLocationStr componentsSeparatedByString:@":"];
            NSString *latitudeStr = components[0];
            NSString *longitudeStr = components[1];
            CLLocationDegrees latitude = [latitudeStr doubleValue];
            CLLocationDegrees longitude = [longitudeStr doubleValue];
            userLastLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        }
        @catch (NSException *exception) {
            return nil;
        }
    }
    CLLocation *userBaseLocation = nil;
    NSString *baseLocationStr = data[@"baseLocation"];
    if ([baseLocationStr isEqual:[NSNull null]]) {
        baseLocationStr = nil;
    }
    if (baseLocationStr) {
        @try {
            NSArray *components = [baseLocationStr componentsSeparatedByString:@":"];
            NSString *latitudeStr = components[0];
            NSString *longitudeStr = components[1];
            CLLocationDegrees latitude = [latitudeStr doubleValue];
            CLLocationDegrees longitude = [longitudeStr doubleValue];
            userBaseLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        }
        @catch (NSException *exception) {
            return nil;
        }
    }
    NSNumber *baseLocationOption = data[@"baseLocationOption"];
    if ([baseLocationOption isEqual:[NSNull null]]) {
        baseLocationOption = nil;
    }
    BOOL usesBaseLocation = [baseLocationOption boolValue];
    
    NSDate *lastUpdateDate = nil;
    NSNumber *seconds = metadata[@"lastUpdateDate"];
    if (seconds && ![baseLocationStr isEqual:[NSNull null]]) {
        lastUpdateDate = [NSDate dateWithTimeIntervalSince1970:[seconds doubleValue]];
    }

    // Create and initialise object.
    OBSUser *user = [[OBSUser alloc] initWithClient:client];
    // Set proprieties.
    user.userId = userId;
    user.userEmail = userEmail;
    user.userName = userName;
    user.userFile = userFile;
    user.online = online;
    user.userLastLocation = userLastLocation;
    user.userBaseLocation = userBaseLocation;
    user.usesBaseLocation = usesBaseLocation;
    user.lastUpdatedAt = lastUpdateDate;

    return user;
}

#pragma mark -

- (void)updateUserWithCompletionHandler:(void(^)(OBSUser *user, OBSError *error))handler
{
    OBSApplication *application = [OBSApplication applicationWithClient:self.client];
    [application getUserWithId:self.userId withCompletionHandler:^(OBSApplication *application, NSString *userId, OBSUser *user, OBSError *error) {
        if (!handler)
            return;

        if (error) {
            handler(self, error);
        } else if ([userId isEqualToString:self.userId]) {

            self.userId = user.userId;
            self.userEmail = user.userEmail;
            self.userName = user.userName;
            self.userFile = user.userFile;
            self.userLastLocation = user.userLastLocation;
            self.userBaseLocation = user.userBaseLocation;
            self.usesBaseLocation = user.usesBaseLocation;

            handler(self, nil);
        }
    }];
}

- (void)setUserName:(NSString *)userName andFile:(NSString *)userFile withCompletionHandler:(void(^)(OBSUser *user, OBSError *error))handler
{
    NSString *string = [NSString string];
    NSDictionary *data = @{@"userName": userName ? userName : string,
                           @"userFile": userFile ? userFile : string};
    [OBSConnection patch_user:self data:data withQueryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
        if (error) {
            if (handler) {
                handler(self, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
            }
            return;
        }
        
        self.userName = userName;
        self.userFile = userFile;
        handler(self, nil);
    }];
}

- (void)setBaseLocation:(CLLocation *)location withCompletionHandler:(void (^)(OBSUser *, CLLocation *, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *patchData = nil;
        if (location) {
            CLLocationCoordinate2D coordinate = [location coordinate];
            NSString *baseLocation = [NSString stringWithFormat:@"%lf:%lf", coordinate.latitude, coordinate.longitude];
            patchData = @{@"baseLocation": baseLocation};
        } else {
            patchData = @{@"baseLocation": [NSNull null]};
        }
        [OBSConnection patch_user:self data:patchData withQueryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
            if (error) {
                if (handler) {
                    handler(self, location, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                }
                return;
            }

            if (location) {
                self.userBaseLocation = [[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            } else {
                self.userBaseLocation = nil;
            }

            if (handler) {
                handler(self, location, nil);
            }
        }];
    });
}

- (void)useBaseLocation:(BOOL)useBaseLocation withCompletionHandler:(void (^)(OBSUser *, BOOL, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *patchData = @{@"baseLocationOption": [NSNumber numberWithBool:useBaseLocation]};
        [OBSConnection patch_user:self data:patchData withQueryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
            if (error) {
                if (handler) {
                    handler(self, useBaseLocation, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                }
                return;
            }

            self.usesBaseLocation = useBaseLocation;

            if (handler) {
                handler(self, useBaseLocation, nil);
            }
        }];
    });
}

#pragma mark Data

- (void)searchPath:(NSString *)path withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(OBSUser *, NSString *, OBSCollectionPage *, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasPath = path && [path isKindOfClass:[NSString class]];
        if (hasPath) {
            [OBSConnection get_user:self dataPath:path withQueryDictionary:query completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler)
                    return;
                
                // Called with error?
                if (error) {
                    handler(self, path, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }
                
                // Create collection page.
                OBSCollectionPage *collectionPage = nil;
                if ([result isKindOfClass:[NSDictionary class]]) {
                    collectionPage = [OBSCollectionPage collectionPageFromDataJSON:result andMetadataJSON:nil];
                }
                if (collectionPage) {
                    // Result is valid.
                    handler(self, path, collectionPage, nil);
                    return;
                }
                
                // Result is not valid.
                handler(self, path, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
            }];
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:3];
            // Add missing parameters to the array.
            if (!hasPath) [missingRequiredParameters addObject:@"path"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, path, nil, error);
        }
    });
}

- (void)readPath:(NSString *)path withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(OBSUser *, NSString *, id, id, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasPath = path && [path isKindOfClass:[NSString class]];
        if (hasPath) {
            [OBSConnection get_user:self dataPath:path withQueryDictionary:query completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler)
                    return;

                // Called with error?
                if (error) {
                    handler(self, path, nil, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }

                if ([result isKindOfClass:[NSDictionary class]]) {
                    // Result is valid.
                    handler(self, path, result[OBSConnectionResultDataKey], result[OBSConnectionResultMetadataKey], nil);
                    return;
                }

                // Result is not valid.
                handler(self, path, nil, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
            }];
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:3];
            // Add missing parameters to the array.
            if (!hasPath) [missingRequiredParameters addObject:@"path"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, path, nil, nil, error);
        }
    });
}

- (void)insertObject:(NSDictionary *)object atPath:(NSString *)path withCompletionHandler:(void (^)(OBSUser *, NSString *, NSDictionary *, BOOL, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasObject = object && [object isKindOfClass:[NSDictionary class]];
        BOOL hasPath = path && [path isKindOfClass:[NSString class]];
        if (hasObject && hasPath) {
            [OBSConnection put_user:self dataPath:path withQueryDictionary:nil object:object completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler)
                    return;

                // Called with error?
                if (error) {
                    handler(self, path, object, NO, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }

                handler(self, path, object, YES, nil);
            }];
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:3];
            // Add missing parameters to the array.
            if (!hasObject) [missingRequiredParameters addObject:@"object"];
            if (!hasPath) [missingRequiredParameters addObject:@"path"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, path, object, NO, error);
        }
    });
}

- (void)updatePath:(NSString *)path withObject:(NSDictionary *)object completionHandler:(void (^)(OBSUser *, NSString *, NSDictionary *, BOOL, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasObject = object && [object isKindOfClass:[NSDictionary class]];
        BOOL hasPath = path && [path isKindOfClass:[NSString class]];
        if (hasObject && hasPath) {
            [OBSConnection patch_user:self dataPath:path withQueryDictionary:nil object:object completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler)
                    return;

                // Called with error?
                if (error) {
                    handler(self, path, object, NO, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }

                handler(self, path, object, YES, nil);
            }];
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:3];
            // Add missing parameters to the array.
            if (!hasObject) [missingRequiredParameters addObject:@"object"];
            if (!hasPath) [missingRequiredParameters addObject:@"path"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, path, object, NO, error);
        }
    });
}

- (void)removePath:(NSString *)path withCompletionHandler:(void (^)(OBSUser *, NSString *, BOOL, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasPath = path && [path isKindOfClass:[NSString class]];
        if (hasPath) {
            [OBSConnection delete_user:self dataPath:path withQueryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler)
                    return;

                // Called with error?
                if (error) {
                    handler(self, path, statusCode == 200, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }

                handler(self, path, statusCode == 200, nil);
            }];
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:3];
            // Add missing parameters to the array.
            if (!hasPath) [missingRequiredParameters addObject:@"path"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, path, NO, error);
        }
    });
}

@end
