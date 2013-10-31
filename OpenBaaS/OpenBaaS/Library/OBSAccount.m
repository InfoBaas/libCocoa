//
//  OBSAccount.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 31/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSAccount_.h"

#import "OBSEmailValidation_.h"

#import "OBSApplication_.h"

#import "OBSConnection.h"

@implementation OBSAccount

- (id)init
{
    return nil;
}

- (id)initWithApplication:(OBSApplication *)application
{
    self = [super init];
    if (self) {
        _application = application;
    }
    return self;
}

- (void)dealloc
{
    _application = nil;
}

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password completionHandler:(OBSAccountSignedUp)handler
{
    OBSAssertNO_NotYetImplemented;
}

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile completionHandler:(OBSAccountSignedUp)handler
{
    OBSAssertNO_NotYetImplemented;
}

- (void)signInWithEmail:(NSString *)email password:(NSString *)password completionHandler:(OBSAccountSignedIn)handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasEmail = email && ![email isEqualToString:[NSString string]];
        BOOL hasPassword = password && ![password isEqualToString:[NSString string]];
        if (hasEmail && hasPassword) {
            if (validateEmailFormat(email)) {
                [OBSConnection post_account:self signInWithEmail:email password:password completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
#warning TODO: create session instance (not here)
                    NSLog(@"RESPONSE: %@\nDATA: %@\nERROR: %@",response,data,error);
                }];
            } else if (handler) {
                NSDictionary *userInfo = @{kOBSErrorUserInfoKeyInvalidParameters: @[@"email", kOBSErrorInvalidParameterBadFormat]};
                // Create an error instace to send to the callback.
                OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                       code:kOBSErrorCodeInvalidParameters
                                                   userInfo:userInfo];
                // Action completed with error.
                handler(self, error, nil);
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
                                                   code:kOBSErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, error, nil);
        }
    });
}

- (void)signUpFromSession:(OBSSession *)session withCompletionHandler:(OBSAccountSignedOut)handler
{
    OBSAssertNO_NotYetImplemented;
}

@end
