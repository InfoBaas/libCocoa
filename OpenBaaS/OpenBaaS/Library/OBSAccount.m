//
//  OBSAccount.m
//  OpenBaaS
//
/*****************************************************************************************
 Infosistema - Lib-Cocoa
 Copyright(C) 2002-2014 Infosistema, S.A.
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU Affero General Public License for more details.
 You should have received a copy of the GNU Affero General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 www.infosistema.com
 info@openbaas.com
 Av. José Gomes Ferreira, 11 3rd floor, s.34
 Miraflores
 1495-139 Algés Portugal
 ****************************************************************************************/

#import "OBSAccount+.h"

#import "OBSEmailValidation+.h"

#import "OBSApplication+.h"
#import "OBSSession+.h"
#import "OBSUser+.h"

#import "OBSConnection.h"

@implementation OBSAccount

- (id)initWithApplication:(OBSApplication *)application
{
    self = [super initWithClient:application.client];
    if (self) {
        _application = application;
    }
    return self;
}

- (void)dealloc
{
    _application = nil;
}

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(OBSAccount *, BOOL, OBSSession *, OBSError *))handler
{
    [self signUpWithEmail:email password:password userName:nil userFile:nil completionHandler:handler];
}

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile completionHandler:(void (^)(OBSAccount *, BOOL, OBSSession *, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasEmail = email && ![email isEqualToString:[NSString string]];
        BOOL hasPassword = password && ![password isEqualToString:[NSString string]];
        if (hasEmail && hasPassword) {
            if (obs_validateEmailFormat(email)) {
                [OBSConnection post_account:self signUpWithEmail:email password:password userName:userName userFile:userFile queryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                    if (!handler)
                        return;

                    // Called with error?
                    if (error) {
                        handler(self, statusCode == 201, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                        return;
                    }

                    // Is data empty?
                    if ([result isEqual:[NSNull null]]) {
                        handler(self, statusCode == 201, nil, nil);
                        return;
                    }

                    // Create session.
                    OBSSession *session = nil;
                    if ([result isKindOfClass:[NSDictionary class]]) {
                        session = [OBSSession sessionFromDataJSON:result[OBSConnectionResultDataKey] andMetadataJSON:result[OBSConnectionResultMetadataKey] withClient:self.client];
                    }
                    if (!session) {
                        // Session wasn't created.
                        handler(self, statusCode == 201, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                        return;
                    }

                    handler(self, statusCode == 201, session, nil);
                }];
            } else if (handler) {
                NSDictionary *userInfo = @{kOBSErrorUserInfoKeyInvalidParameters: @[@"email", kOBSErrorInvalidParameterReasonBadFormat]};
                // Create an error instace to send to the callback.
                OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                       code:kOBSLocalErrorCodeInvalidParameters
                                                   userInfo:userInfo];
                // Action completed with error.
                handler(self, NO, nil, error);
            }
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:3];
            // Add missing parameters to the array.
            if (!hasEmail) [missingRequiredParameters addObject:@"email"];
            if (!hasPassword) [missingRequiredParameters addObject:@"password"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, NO, nil, error);
        }
    });
}

- (void)signInWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(OBSAccount *, BOOL, OBSSession *, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasEmail = email && ![email isEqualToString:[NSString string]];
        BOOL hasPassword = password && ![password isEqualToString:[NSString string]];
        if (hasEmail && hasPassword) {
            if (obs_validateEmailFormat(email)) {
                [OBSConnection post_account:self signInWithEmail:email password:password queryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                    if (!handler)
                        return;

                    // Called with error?
                    if (error) {
                        handler(self, statusCode == 200, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                        return;
                    }

                    // Create session.
                    OBSSession *session = nil;
                    if ([result isKindOfClass:[NSDictionary class]]) {
                        session = [OBSSession sessionFromDataJSON:result[OBSConnectionResultDataKey] andMetadataJSON:result[OBSConnectionResultMetadataKey] withClient:self.client];
                    }
                    if (!session) {
                        // Session wasn't created.
                        handler(self, statusCode == 200, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                        return;
                    }

                    handler(self, statusCode == 200, session, nil);
                }];
            } else if (handler) {
                NSDictionary *userInfo = @{kOBSErrorUserInfoKeyInvalidParameters: @[@"email", kOBSErrorInvalidParameterReasonBadFormat]};
                // Create an error instace to send to the callback.
                OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                       code:kOBSLocalErrorCodeInvalidParameters
                                                   userInfo:userInfo];
                // Action completed with error.
                handler(self, NO, nil, error);
            }
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:3];
            // Add missing parameters to the array.
            if (!hasEmail) [missingRequiredParameters addObject:@"email"];
            if (!hasPassword) [missingRequiredParameters addObject:@"password"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, NO, nil, error);
        }
    });
}

- (void)signInWithFacebookOAuthToken:(NSString *)oauthToken completionHandler:(void (^)(OBSAccount *, BOOL, BOOL, OBSSession *, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasToken = oauthToken && ![oauthToken isEqualToString:[NSString string]];
        if (hasToken) {
            [OBSConnection post_account:self integrationFacebookWithOAuthToken:oauthToken queryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler)
                    return;

                // Called with error?
                if (error) {
                    handler(self, statusCode == 201, statusCode == 200, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }

                // Create session.
                OBSSession *session = nil;
                if ([result isKindOfClass:[NSDictionary class]]) {
                    session = [OBSSession sessionFromDataJSON:result[OBSConnectionResultDataKey] andMetadataJSON:result[OBSConnectionResultMetadataKey] withClient:self.client];
                }
                if (!session) {
                    // Session wasn't created.
                    handler(self, statusCode == 201, statusCode == 200, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                    return;
                }

                handler(self, statusCode == 201, statusCode == 200, session, nil);
            }];
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:3];
            // Add missing parameters to the array.
            if (!hasToken) [missingRequiredParameters addObject:@"token"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, NO, NO, nil, error);
        }
    });
}

- (void)signOutFromSession:(OBSSession *)session closingAllOthers:(BOOL)closeAll withCompletionHandler:(void (^)(OBSAccount *, BOOL, OBSSession *, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [OBSConnection post_account:self signOutWithSession:session all:closeAll queryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
            if (!handler)
                return;

            // Called with error?
            if (error) {
                handler(self, statusCode == 200, session, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                return;
            }

            handler(self, statusCode == 200, session, nil);
        }];
    });
}

- (void)recoverPasswordForEmail:(NSString *)email withCompletionHandler:(void (^)(OBSAccount *, BOOL, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasEmail = email && ![email isEqualToString:[NSString string]];
        if (hasEmail) {
            if (obs_validateEmailFormat(email)) {
                [OBSConnection post_account:self recoveryWithEmail:email queryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                    if (!handler)
                        return;

                    // Called with error?
                    if (error) {
                        handler(self, statusCode == 200, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                        return;
                    }

                    handler(self, statusCode == 200, nil);
                }];
            } else if (handler) {
                NSDictionary *userInfo = @{kOBSErrorUserInfoKeyInvalidParameters: @[@"email", kOBSErrorInvalidParameterReasonBadFormat]};
                // Create an error instace to send to the callback.
                OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                       code:kOBSLocalErrorCodeInvalidParameters
                                                   userInfo:userInfo];
                // Action completed with error.
                handler(self, NO, error);
            }
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:3];
            // Add missing parameters to the array.
            if (!hasEmail) [missingRequiredParameters addObject:@"email"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, NO, error);
        }
    });
}

- (void)changePasswordFrom:(NSString *)oldPassword to:(NSString *)newPassword withCompletionHandler:(void (^)(OBSAccount *, BOOL, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasOld = oldPassword && ![oldPassword isEqualToString:[NSString string]];
        BOOL hasNew = newPassword && ![newPassword isEqualToString:[NSString string]];
        if (hasOld && hasNew) {
            [OBSConnection post_account:self changeFromPassword:oldPassword toPassword:newPassword queryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler)
                    return;
                
                // Called with error?
                if (error) {
                    handler(self, statusCode == 200, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }
                
                handler(self, statusCode == 200, nil);
            }];
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:3];
            // Add missing parameters to the array.
            if (!hasOld) [missingRequiredParameters addObject:@"oldPassword"];
            if (!hasNew) [missingRequiredParameters addObject:@"newPassword"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, NO, error);
        }
    });
}

@end
