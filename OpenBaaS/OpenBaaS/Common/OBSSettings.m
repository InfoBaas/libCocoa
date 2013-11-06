//
//  OBSSettings.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 06/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSSettings+.h"

#define _obs_settings_session_token   @"com.openbaas.session.token"
#define _obs_settings_session_userId   @"com.openbaas.session.userId"
#define _obs_settings_session_userEmail   @"com.openbaas.session.userEmail"
#define _obs_settings_session_userName   @"com.openbaas.session.userName"
#define _obs_settings_session_userFile   @"com.openbaas.session.userFile"

@implementation _obs_settings_session_t @end

void _obs_settings_set_session (_obs_settings_session_t *session)
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (session) {
        [standardUserDefaults setObject:session.token forKey:_obs_settings_session_token];
        [standardUserDefaults setObject:session.userId forKey:_obs_settings_session_userId];
        [standardUserDefaults setObject:session.userEmail forKey:_obs_settings_session_userEmail];
        if (session.userName) {
            [standardUserDefaults setObject:session.userName forKey:_obs_settings_session_userName];
        } else {
            [standardUserDefaults removeObjectForKey:_obs_settings_session_userName];
        }
        if (session.userFile) {
            [standardUserDefaults setObject:session.userFile forKey:_obs_settings_session_userFile];
        } else {
            [standardUserDefaults removeObjectForKey:_obs_settings_session_userFile];
        }
    } else {
        [standardUserDefaults removeObjectForKey:_obs_settings_session_token];
        [standardUserDefaults removeObjectForKey:_obs_settings_session_userId];
        [standardUserDefaults removeObjectForKey:_obs_settings_session_userEmail];
        [standardUserDefaults removeObjectForKey:_obs_settings_session_userName];
        [standardUserDefaults removeObjectForKey:_obs_settings_session_userFile];
    }
    [standardUserDefaults synchronize];
}
_obs_settings_session_t *_obs_settings_get_session (void)
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [standardUserDefaults objectForKey:_obs_settings_session_token];
    if (!token) {
        return nil;
    }
    _obs_settings_session_t *session = [_obs_settings_session_t new];
    session.token = token;
    session.userId = [standardUserDefaults objectForKey:_obs_settings_session_userId];
    session.userEmail = [standardUserDefaults objectForKey:_obs_settings_session_userEmail];
    session.userName = [standardUserDefaults objectForKey:_obs_settings_session_userName];
    session.userFile = [standardUserDefaults objectForKey:_obs_settings_session_userFile];
    return session;
}
NSString *_obs_settings_get_sessionToken (void)
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:_obs_settings_session_token];
}
