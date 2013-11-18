//
//  OBSApplication.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSApplication+.h"

#import "OBSAccount+.h"
#import "OBSUser+.h"

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

- (OBSAccount *)applicationAccount
{
    return [[OBSAccount alloc] initWithApplication:self];
}

- (void)getUserIdsWithCompletionHandler:(void (^)(OBSApplication *, NSArray *, NSInteger, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [OBSConnection get_application:self usersWithQueryDictionary:nil completionHandler:^(id result, NSError *error) {
            if (!handler)
                return;

            // Called with error?
            if (error) {
                handler(self, nil, NSNotFound, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                return;
            }

#warning Not Yet Implemented
            OBS_NotYetImplemented
        }];
    });
}

- (void)getUserWithId:(NSString *)userId withCompletionHandler:(void (^)(OBSApplication *, OBSUser *, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasUserId = userId && [userId isKindOfClass:[NSString class]];
        if (hasUserId) {
            [OBSConnection get_application:self userWithId:userId queryDictionary:nil completionHandler:^(id result, NSError *error) {
                if (!handler)
                    return;

                // Called with error?
                if (error) {
                    handler(self, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }

                // Create user.
                OBSUser *user = nil;
                if ([result isKindOfClass:[NSDictionary class]]) {
                    user = [OBSUser userFromDataJSON:result[OBSConnectionResultDataKey] andMetadataJSON:result[OBSConnectionResultMetadataKey] withClient:self.client];
                }
                if (!user) {
                    // User wasn't created.
                    handler(self, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                    return;
                }

                handler(self, user, nil);
            }];
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:3];
            // Add missing parameters to the array.
            if (!hasUserId) [missingRequiredParameters addObject:@"userId"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, nil, error);
        }
    });
}

- (void)getUsersWithCompletionHandler:(void (^)(OBSApplication *, NSArray *, NSInteger, OBSError *))handler andElementCompletionHandler:(void (^)(OBSApplication *, OBSUser *, OBSError *))elementHandler
{
    [self getUserIdsWithCompletionHandler:^(OBSApplication *application, NSArray *userIds, NSInteger firstElementIndex, OBSError *error) {
        handler(application, userIds, firstElementIndex, error);
        if (!error) {
            for (NSString *userId in userIds) {
                [self getUserWithId:userId withCompletionHandler:elementHandler];
            }
        }
    }];
}

@end
