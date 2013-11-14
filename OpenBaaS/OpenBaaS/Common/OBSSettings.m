//
//  OBSSettings.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 06/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSSettings+.h"

#define _obs_settings_session_token   @"com.openbaas.settings.session.token"

void _obs_settings_set_sessionToken (NSString *sessionToken)
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (sessionToken) {
        [standardUserDefaults setObject:sessionToken forKey:_obs_settings_session_token];
    } else {
        [standardUserDefaults removeObjectForKey:_obs_settings_session_token];
    }
    [standardUserDefaults synchronize];
}
NSString *_obs_settings_get_sessionToken (void)
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:_obs_settings_session_token];
}
