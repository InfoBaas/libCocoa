//
//  OBSSettings+.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 06/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSSettings.h"

void _obs_settings_set_sessionInfo (NSString *sessionToken, NSString *userId);
NSString *_obs_settings_get_sessionToken (void);
NSString *_obs_settings_get_userId (void);
