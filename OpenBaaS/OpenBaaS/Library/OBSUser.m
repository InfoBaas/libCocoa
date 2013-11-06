//
//  OBSUser.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 05/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSUser+_.h"

@implementation OBSUser

- (void)setUserId:(NSString *)userId
{
    _userId = userId;
}
- (void)setUserEmail:(NSString *)userEmail
{
    _userEmail = userEmail;
}
- (void)setUserName:(NSString *)userName
{
    _userName = userName;
}
- (void)setUserFile:(NSString *)userFile
{
    _userFile = userFile;
}

@end
