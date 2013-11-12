//
//  OBSAccount.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 31/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

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
                [OBSConnection post_account:self signUpWithEmail:email password:password userName:userName userFile:userFile completionHandler:^(NSData *data, NSError *error) {
                    // Called with error?
                    if (error) {
                        handler(self, NO, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                        return;
                    }

                    // Is data empty?
                    if (![data length]) {
                        handler(self, YES, nil, nil);
                    }

                    // Valid JSON?
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    if (error) {
                        handler(self, YES, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                        return;
                    }

                    // Create session.
                    OBSSession *session = [OBSSession sessionFromJSON:json withClient:self.client];
                    if (!session) {
                        // Session wasn't created.
                        handler(self, YES, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                        return;
                    }

                    handler(self, YES, session, nil);
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
                [OBSConnection post_account:self signInWithEmail:email password:password completionHandler:^(NSData *data, NSError *error) {
                    // Called with error?
                    if (error) {
                        handler(self, NO, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                        return;
                    }

                    // Valid JSON?
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    if (error) {
                        handler(self, YES, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                        return;
                    }

                    // Create session.
                    OBSSession *session = [OBSSession sessionFromJSON:json withClient:self.client];
                    if (!session) {
                        // Session wasn't created.
                        handler(self, YES, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                        return;
                    }

                    handler(self, YES, session, nil);
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

- (void)signOutFromSession:(OBSSession *)session closingAllOthers:(BOOL)closeAll withCompletionHandler:(void (^)(OBSAccount *, BOOL, OBSSession *, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [OBSConnection post_accountSignOutWithSession:session all:closeAll completionHandler:^(NSData *data, NSError *error) {
            // Called with error?
            if (error) {
                handler(self, NO, session, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                return;
            }

            handler(self, YES, session, nil);
        }];
    });
}

- (void)recoverPasswordForEmail:(NSString *)email withCompletionHandler:(void (^)(OBSAccount *, BOOL, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasEmail = email && ![email isEqualToString:[NSString string]];
        if (hasEmail) {
            if (obs_validateEmailFormat(email)) {
                [OBSConnection post_account:self recoveryWithEmail:email completionHandler:^(NSData *data, NSError *error) {
                    // Called with error?
                    if (error) {
                        handler(self, NO, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                        return;
                    }

                    handler(self, YES, nil);
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

@end
