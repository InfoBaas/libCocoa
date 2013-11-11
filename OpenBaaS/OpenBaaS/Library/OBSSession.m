//
//  OBSSession.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSSession+.h"

#import "OBSUser+.h"

#import "OBSConnection.h"

@implementation OBSSession

+ (OBSSession *)sessionFromJSON:(NSDictionary *)json withClient:(id<OBSClientProtocol>)client
{
    NSString *sessionToken = json[@"returnToken"];
    if (!sessionToken || [sessionToken isEqual:[NSNull null]]) {
        return nil;
    }

    OBSUser *user = [OBSUser userFromJSON:json withClient:client];
    if (!user) {
        return nil;
    }

    OBSSession *session = [[OBSSession alloc] initWithClient:client];
    session.token = sessionToken;
    session.user = user;

    return session;
}

- (void)saveAsCurrentSession
{
    _obs_settings_set_sessionToken(self.token);
}

- (BOOL)isCurrentSession
{
    return [_obs_settings_get_sessionToken() isEqualToString:self.token];
}

- (BOOL)forgetIfIsCurrentSession
{
    if ([self isCurrentSession]) {
        _obs_settings_set_sessionToken(nil);
        return YES;
    }
    return NO;
}

+ (BOOL)openCurrentSessionWithClient:(id<OBSClientProtocol>)client andCompletionHandler:(void (^)(BOOL, OBSSession *, OBSError *))handler
{
    NSString *sessionToken = _obs_settings_get_sessionToken();
    if (!sessionToken) {
        return NO;
    }

#warning TODO: open session
    OBS_NotYetImplemented

    return YES;
}

+ (void)forgetCurrentSession
{
    _obs_settings_set_sessionToken(nil);
}

@end
