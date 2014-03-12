//
//  OBSApplication.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSApplication+.h"

#import "OBSQuery+.h"

#import "OBSAccount+.h"
#import "OBSChatRoom+.h"
#import "OBSMedia+.h"
#import "OBSUser+.h"
#import "OBSUserState+.h"

#import "OBSConnection.h"

@implementation OBSApplication

+ (OBSApplication *)applicationWithClient:(id<OBSClientProtocol>)client
{
    return client ? [[self alloc] initWithClient:client] : nil;
}

- (NSString *)applicationId
{
    return [self.client appId];
}

- (NSString *)applicationKey
{
    return [self.client appKey];
}

- (OBSAccount *)applicationAccount
{
    return [[OBSAccount alloc] initWithApplication:self];
}

- (OBSMedia *)applicationMedia
{
    return [[OBSMedia alloc] initWithApplication:self];
}

- (void)getUserWithId:(NSString *)userId withCompletionHandler:(void (^)(OBSApplication *, NSString *, OBSUser *, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasUserId = userId && [userId isKindOfClass:[NSString class]];
        if (hasUserId) {
            [OBSConnection get_application:self userWithId:userId queryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler)
                    return;

                // Called with error?
                if (error) {
                    handler(self, userId, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }

                // Create user.
                OBSUser *user = nil;
                if ([result isKindOfClass:[NSDictionary class]]) {
                    user = [OBSUser userFromDataJSON:result[OBSConnectionResultDataKey] andMetadataJSON:result[OBSConnectionResultMetadataKey] withClient:self.client];
                }
                if (!user) {
                    // User wasn't created.
                    handler(self, userId, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                    return;
                }

                handler(self, userId, user, nil);
            }];
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:1];
            // Add missing parameters to the array.
            if (!hasUserId) [missingRequiredParameters addObject:@"userId"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, userId, nil, error);
        }
    });
}

- (void)getUserIdsWithQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(OBSApplication *, OBSCollectionPage *, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [OBSConnection get_application:self usersWithQueryDictionary:query completionHandler:^(id result, NSInteger statusCode, NSError *error) {
            if (!handler)
                return;

            // Called with error?
            if (error) {
                handler(self, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                return;
            }

            // Create collection page.
            OBSCollectionPage *collectionPage = nil;
            if ([result isKindOfClass:[NSDictionary class]]) {
                collectionPage = [OBSCollectionPage collectionPageFromDataJSON:result andMetadataJSON:nil];
            }
            if (!collectionPage) {
                // Collection page wasn't created.
                handler(self, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                return;
            }

            handler(self, collectionPage, nil);
        }];
    });
}

- (void)getUsersWithQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(OBSApplication *, OBSCollectionPage *, OBSError *))handler elementCompletionHandler:(void (^)(OBSApplication *, NSString *, OBSUser *, OBSError *))elementHandler
{
    [self getUserIdsWithQueryDictionary:query completionHandler:^(OBSApplication *application, OBSCollectionPage *userIds, OBSError *error) {
        if (handler)
            handler(application, userIds, error);

        if (!error) {
            for (NSString *userId in [userIds elements]) {
                [self getUserWithId:userId withCompletionHandler:elementHandler];
            }
        }
    }];
}

- (void)getUsersWithQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(OBSApplication *, OBSCollectionPage *, OBSError *))handler
{
    NSArray *show = query[OBSQueryParamShow];
    if (!show)
        show = @[];
    
    NSArray *userNativeFields = [OBSUser nativeFields];
    show = [show arrayByAddingObjectsFromArray:userNativeFields];
    
    if (query) {
        NSMutableDictionary *mutableQuery = [query mutableCopy];
        mutableQuery[OBSQueryParamShow] = show;
        query = mutableQuery;
    } else {
        query = @{OBSQueryParamShow: show};
    }
    
    [self getUserIdsWithQueryDictionary:query completionHandler:^(OBSApplication *application, OBSCollectionPage *users, OBSError *error) {
        if (error) {
            handler(application, nil, error);
        } else {
            NSArray *elements = users.elements;
            NSUInteger count = [elements count];
            NSMutableArray *userObjects = [NSMutableArray arrayWithCapacity:count];
            for (NSUInteger e = 0; e < count; e++) {
                OBSCollectionPageElement *elementObject = elements[e];
                NSDictionary *data = elementObject.data;
                NSDictionary *metadata = elementObject.metadata;
                OBSUser *user = [OBSUser userFromDataJSON:data andMetadataJSON:metadata withClient:application.client];
                if (users) {
                    [userObjects addObject:user];
                } else {
                    [userObjects addObject:[NSNull null]];
                }
            }
            users.elements = [NSArray arrayWithArray:userObjects];
            handler(application, users, nil);
        }
    }];
}

- (void)getUsersStatesOfUsersWithIds:(NSArray *)userIds includeMisses:(BOOL)includeMisses withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(OBSApplication *, NSArray *, NSArray *, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasUserIds = userIds && [userIds isKindOfClass:[NSArray class]];
        if (hasUserIds) {
            if ([userIds count]) {
                [OBSConnection post_application:self usersStateWithIds:userIds includeMisses:includeMisses queryDictionary:query completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                    if (!handler)
                        return;
                    
                    // Called with error?
                    if (error) {
                        handler(self, userIds, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                        return;
                    }
                    
                    // Check result.
                    NSArray *array = result;
                    if (![array isKindOfClass:[NSArray class]]) {
                        // Result is not valid.
                        handler(self, userIds, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                        return;
                    }
                    
                    // Result is valid.
                    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[array count]];
                    for (NSDictionary *element in array) {
                        if ([element isEqual:[NSNull null]]) {
                            [mutableArray addObject:[NSNull null]];
                        } else {
                            OBSUserState *state = [OBSUserState userStateFromJSONObject:element];
                            if (state) {
                                [mutableArray addObject:state];
                            } else if (includeMisses) {
                                [mutableArray addObject:[NSNull null]];
                            }
                        }
                    }
                    handler(self, userIds, [NSArray arrayWithArray:mutableArray], nil);
                }];
            } else {
                handler(self, userIds, @[], nil);
            }
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:1];
            // Add missing parameters to the array.
            if (!hasUserIds) [missingRequiredParameters addObject:@"userIds"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, userIds, nil, error);
        }
    });
}

- (void)getChatRoomWithUsers:(NSArray *)users completionHandler:(void (^)(OBSApplication *, NSArray *, OBSChatRoom *, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasUsersArray = users && [users isKindOfClass:[NSArray class]];
        if (hasUsersArray) {
            NSMutableArray *userIds = [NSMutableArray arrayWithCapacity:[users count]];
            for (OBSUser *user in users) {
                [userIds addObject:user.userId];
            }
            [self getChatRoomWithUserIds:userIds completionHandler:^(OBSApplication *application, NSArray *userIds, OBSChatRoom *chatRoom, OBSError *error) {
                if (handler)
                    handler(application, users, chatRoom, error);
            }];
        } else {
            if (handler) {
                //// Some or all the required parameters are missing
                // Create an array to hold the missing parameters' names.
                NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:1];
                // Add missing parameters to the array.
                if (!hasUsersArray) [missingRequiredParameters addObject:@"users"];
                // Create userInfo dictionary.
                NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
                // Create an error instace to send to the callback.
                OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                       code:kOBSLocalErrorCodeMissingRequiredParameters
                                                   userInfo:userInfo];
                // Action completed with error.
                handler(self, users, nil, error);
            }
        }
    });
}

- (void)getChatRoomWithUserIds:(NSArray *)userIds completionHandler:(void (^)(OBSApplication *, NSArray *, OBSChatRoom *, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasUserIdsArray = userIds && [userIds isKindOfClass:[NSArray class]];
        if (hasUserIdsArray) {
            [OBSConnection post_application:self openChatRoomWithUserIds:userIds queryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler) {
                    return;
                }
                
                // Called with error?
                if (error) {
                    handler(self, userIds, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }
                
                // Create chat room.
                OBSChatRoom *chatRoom = nil;
                if ([result isKindOfClass:[NSDictionary class]]) {
                    chatRoom = [OBSChatRoom chatRoomFromDataJSON:result andMetadataJSON:nil withClient:self.client];
                }
                if (!chatRoom) {
                    // User wasn't created.
                    handler(self, userIds, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                    return;
                }
                
                handler(self, userIds, chatRoom, nil);
            }];
        } else {
            if (handler) {
                //// Some or all the required parameters are missing
                // Create an array to hold the missing parameters' names.
                NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:1];
                // Add missing parameters to the array.
                if (!hasUserIdsArray) [missingRequiredParameters addObject:@"userIds"];
                // Create userInfo dictionary.
                NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
                // Create an error instace to send to the callback.
                OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                       code:kOBSLocalErrorCodeMissingRequiredParameters
                                                   userInfo:userInfo];
                // Action completed with error.
                handler(self, userIds, nil, error);
            }
        }
    });
}

- (void)registerDeviceToken:(NSData *)deviceToken forNotificationsToClient:(NSString *)client withCompletionHandler:(void (^)(OBSApplication *, NSData *, NSString *, BOOL, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasDeviceToken = deviceToken && [deviceToken isKindOfClass:[NSData class]];
        BOOL hasClient = client && [client isKindOfClass:[NSString class]];
        if (hasDeviceToken && hasClient) {
            NSMutableString *hex = [NSMutableString stringWithCapacity:[deviceToken length]*2];
            [deviceToken enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
                const unsigned char *dataBytes = (const unsigned char *)bytes;
                for (NSUInteger i = byteRange.location; i < byteRange.length; ++i) {
                    [hex appendFormat:@"%02x", dataBytes[i]];
                }
            }];
            [OBSConnection post_application:self registerDeviceToken:hex forNotificationsToClient:client withQueryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler) {
                    return;
                }
                
                // Called with error?
                if (error) {
                    handler(self, deviceToken, client, NO, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }
                
                handler(self, deviceToken, client, YES, nil);
            }];
        } else {
            if (handler) {
                //// Some or all the required parameters are missing
                // Create an array to hold the missing parameters' names.
                NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:2];
                // Add missing parameters to the array.
                if (!hasDeviceToken) [missingRequiredParameters addObject:@"deviceToken"];
                if (!hasClient) [missingRequiredParameters addObject:@"client"];
                // Create userInfo dictionary.
                NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
                // Create an error instace to send to the callback.
                OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                       code:kOBSLocalErrorCodeMissingRequiredParameters
                                                   userInfo:userInfo];
                // Action completed with error.
                handler(self, deviceToken, client, NO, error);
            }
        }
    });
}

- (void)unregisterDeviceToken:(NSData *)deviceToken forNotificationsToClient:(NSString *)client withCompletionHandler:(void (^)(OBSApplication *, NSData *, NSString *, BOOL, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasDeviceToken = deviceToken && [deviceToken isKindOfClass:[NSData class]];
        BOOL hasClient = client && [client isKindOfClass:[NSString class]];
        if (hasDeviceToken && hasClient) {
            NSMutableString *hex = [NSMutableString stringWithCapacity:[deviceToken length]*2];
            [deviceToken enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
                const unsigned char *dataBytes = (const unsigned char *)bytes;
                for (NSUInteger i = byteRange.location; i < byteRange.length; ++i) {
                    [hex appendFormat:@"%02x", dataBytes[i]];
                }
            }];
            [OBSConnection post_application:self unregisterDeviceToken:hex forNotificationsToClient:client withQueryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler) {
                    return;
                }
                
                // Called with error?
                if (error) {
                    handler(self, deviceToken, client, NO, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }
                
                handler(self, deviceToken, client, YES, nil);
            }];
        } else {
            if (handler) {
                //// Some or all the required parameters are missing
                // Create an array to hold the missing parameters' names.
                NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:2];
                // Add missing parameters to the array.
                if (!hasDeviceToken) [missingRequiredParameters addObject:@"deviceToken"];
                if (!hasClient) [missingRequiredParameters addObject:@"client"];
                // Create userInfo dictionary.
                NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
                // Create an error instace to send to the callback.
                OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                       code:kOBSLocalErrorCodeMissingRequiredParameters
                                                   userInfo:userInfo];
                // Action completed with error.
                handler(self, deviceToken, client, NO, error);
            }
        }
    });
}

#pragma mark Data

- (void)searchPath:(NSString *)path withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(OBSApplication *, NSString *, OBSCollectionPage *, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasPath = path && [path isKindOfClass:[NSString class]];
        if (hasPath) {
            [OBSConnection get_application:self dataPath:path withQueryDictionary:query completionHandler:^(id result, NSInteger statusCode, NSError *error) {
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
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:1];
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

- (void)readPath:(NSString *)path withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(OBSApplication *, NSString *, id, id, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasPath = path && [path isKindOfClass:[NSString class]];
        if (hasPath) {
            [OBSConnection get_application:self dataPath:path withQueryDictionary:query completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler)
                    return;

                // Called with error?
                if (error) {
                    handler(self, path, nil, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }

                if ([result isKindOfClass:[NSDictionary class]]) {
                    // Result is valid.
                    id data = result[OBSConnectionResultDataKey];
                    if ([data isEqual:[NSNull null]]) {
                        data = nil;
                    }
                    id metadata = result[OBSConnectionResultMetadataKey];
                    if ([metadata isEqual:[NSNull null]]) {
                        metadata = nil;
                    }
                    handler(self, path, data, metadata, nil);
                    return;
                }

                // Result is not valid.
                handler(self, path, nil, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
            }];
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:1];
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

- (void)insertObject:(NSDictionary *)object atPath:(NSString *)path withCompletionHandler:(void (^)(OBSApplication *, NSString *, NSDictionary *, BOOL, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasObject = object && [object isKindOfClass:[NSDictionary class]];
        BOOL hasPath = path && [path isKindOfClass:[NSString class]];
        if (hasObject && hasPath) {
            [OBSConnection put_application:self dataPath:path withQueryDictionary:nil object:object completionHandler:^(id result, NSInteger statusCode, NSError *error) {
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
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:2];
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

- (void)updatePath:(NSString *)path withObject:(NSDictionary *)object completionHandler:(void (^)(OBSApplication *, NSString *, NSDictionary *, BOOL, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasObject = object && [object isKindOfClass:[NSDictionary class]];
        BOOL hasPath = path && [path isKindOfClass:[NSString class]];
        if (hasObject && hasPath) {
            [OBSConnection patch_application:self dataPath:path withQueryDictionary:nil object:object completionHandler:^(id result, NSInteger statusCode, NSError *error) {
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
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:2];
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

- (void)removePath:(NSString *)path withCompletionHandler:(void (^)(OBSApplication *, NSString *, BOOL, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasPath = path && [path isKindOfClass:[NSString class]];
        if (hasPath) {
            [OBSConnection delete_application:self dataPath:path withQueryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
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
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:1];
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
