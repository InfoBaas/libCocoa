//
//  OBSSettings+.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 06/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSSettings.h"

// ARC does not allow structs with object pointers :(
@interface _obs_settings_session_t : NSObject

@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userEmail;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userFile;

@end

void _obs_settings_set_session (_obs_settings_session_t *session);
_obs_settings_session_t *_obs_settings_get_session (void);
NSString *_obs_settings_get_sessionToken (void);
