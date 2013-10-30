//
//  OBSSession.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSSession.h"

#import "OBSApplication.h"

#import "OBSEmailValidation.h"

#import "OBSServerConnection.h"

@implementation OBSSession

+ (void)signUpToApplication:(OBSApplication *)app withEmail:(NSString *)email password:(NSString *)password completionHandler:(OBSSessionSignedUp)handler
{}

+ (void)signUpToApplication:(OBSApplication *)app withEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile completionHandler:(OBSSessionSignedUp)handler
{}

+ (void)signInToApplication:(OBSApplication *)app withEmail:(NSString *)email password:(NSString *)password completionHandler:(OBSSessionSignedIn)handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasEmail = email && ![email isEqualToString:[NSString string]];
        BOOL hasPassword = password && ![password isEqualToString:[NSString string]];
        if (hasEmail && hasPassword) {
            if (validateEmailFormat(email)) {
                [OBSServerConnection createSessionWithAppId:app.appID
                                                      email:email
                                                   password:password
                                          completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
#warning TODO: create session instance (OBSServer)
                                              NSLog(@"RESPONSE: %@\nDATA: %@\nERROR: %@",response,data,error);
                                          }];
            } else if (handler) {
                NSDictionary *userInfo = @{kOBSErrorUserInfoKeyInvalidParameters: @[@"email", kOBSErrorInvalidParameterBadFormat]};
                // Create an error instace to send to the callback.
                OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                       code:kOBSErrorCodeInvalidParameters
                                                   userInfo:userInfo];
                // Action completed with error.
                handler(nil, error);
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
            handler(nil, error);
        }
    });
}

- (void)signUpWithCompletionHandler:(OBSSessionSignedOut)handler
{}

@end
