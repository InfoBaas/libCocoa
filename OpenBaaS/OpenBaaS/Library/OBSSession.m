//
//  OBSSession.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSSession+_.h"

#import "OBSUser+_.h"

#import "OBSConnection.h"

@interface OBSSession ()
{
    NSString *_token;
}

@end

@implementation OBSSession

- (NSString *)token
{
    return _token;
}

- (void)setToken:(NSString *)token
{
    _token = token;
}

- (void)setUser:(OBSUser *)user
{
    _user = user;
}

- (void)saveAsCurrentSession
{
    _obs_settings_session_t *session = [_obs_settings_session_t new];
    session.token = self.token;
    session.userId = self.user.userId;
    session.userEmail = self.user.userEmail;
    session.userName = self.user.userName;
    session.userFile = self.user.userFile;
    _obs_settings_set_session(session);
}

+ (OBSSession *)openCurrentSessionWithClient:(id<OBSClientProtocol>)client andCompletionHandler:(OBSSessionOpenCompletionHandler)handler
{
    _obs_settings_session_t *sessionInSettings = nil;
    _obs_settings_get_session(&sessionInSettings);
    if (!sessionInSettings) {
        return nil;
    }

    OBSUser *user = [[OBSUser alloc] initWithClient:client];
    user.userId = sessionInSettings.userId;
    user.userEmail = sessionInSettings.userEmail;
    user.userName = sessionInSettings.userName;
    user.userFile = sessionInSettings.userFile;

    OBSSession *session = [[OBSSession alloc] initWithClient:client];
    session.token = sessionInSettings.token;
    session.user = user;

#warning TODO: open session

    return session;
}

@end
