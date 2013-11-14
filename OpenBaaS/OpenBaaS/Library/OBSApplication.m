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

- (void)getUserIdsWithCompletionHandler:(void(^)(OBSApplication *application, NSArray *userIds, OBSError *error))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [OBSConnection get_usersWithCompletionHandler:^(id result, NSError *error) {
#warning Not Yet Implemented
            OBS_NotYetImplemented
        }];
    });
}

- (void)getUserWithId:(NSString *)userId withCompletionHandler:(void(^)(OBSApplication *application, OBSUser *user, OBSError *error))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#warning Not Yet Implemented
        OBS_NotYetImplemented
    });
}

- (void)getUsersWithCompletionHandler:(void(^)(OBSApplication *application, NSArray *userIds, OBSError *error))handler andElementCompletionHandler:(void (^)(OBSApplication *, OBSUser *, OBSError *))elementHandler
{
    [self getUserIdsWithCompletionHandler:^(OBSApplication *application, NSArray *userIds, OBSError *error) {
        handler(application, userIds, error);
        if (!error) {
            for (NSString *userId in userIds) {
                [self getUserWithId:userId withCompletionHandler:elementHandler];
            }
        }
    }];
}

@end
