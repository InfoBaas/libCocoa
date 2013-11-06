//
//  OBSUser+_.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 05/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSUser.h"

@interface OBSUser (_)

- (void)setUserId:(NSString *)userId;
- (void)setUserEmail:(NSString *)userEmail;
- (void)setUserName:(NSString *)userName;
- (void)setUserFile:(NSString *)userFile;

@end
