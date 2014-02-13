//
//  OBSSettings.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 06/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSSettings+.h"

#define _obs_settings_session_token   @"com.openbaas.settings.session.token"
#define _obs_settings_session_userid   @"com.openbaas.settings.session.userid"

void _obs_settings_set_sessionInfo (NSString *sessionToken, NSString *userId)
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (sessionToken) {
        [standardUserDefaults setObject:sessionToken forKey:_obs_settings_session_token];
    } else {
        [standardUserDefaults removeObjectForKey:_obs_settings_session_token];
    }
    if (userId) {
        [standardUserDefaults setObject:userId forKey:_obs_settings_session_userid];
    } else {
        [standardUserDefaults removeObjectForKey:_obs_settings_session_userid];
    }
    [standardUserDefaults synchronize];
}
NSString *_obs_settings_get_sessionToken (void)
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:_obs_settings_session_token];
}
NSString *_obs_settings_get_userId (void)
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:_obs_settings_session_userid];
}
