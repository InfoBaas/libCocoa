//
//  OBSUser.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 05/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSUser+.h"

@implementation OBSUser

- (void)dealloc
{
    _userId = nil;
    _userEmail = nil;
    _userName = nil;
    _userFile = nil;
}

+ (OBSUser *)userFromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata withClient:(id<OBSClientProtocol>)client
{
    NSString *userId = data[@"userId"];
    if (!userId || [userId isEqual:[NSNull null]]) {
        return nil; // userId is missing from JSON.
    }
    NSString *userEmail = data[@"email"];
    if (!userEmail || [userEmail isEqual:[NSNull null]]) {
        return nil; // User's e-mail is missing from JSON.
    }
    NSString *userName = data[@"userName"];
    if ([userName isEqual:[NSNull null]]) {
        userName = nil; // User has no name.
    }
    NSString *userFile = data[@"userFile"];
    if ([userFile isEqual:[NSNull null]]) {
        userFile = nil; // User has no file.
    }

    // Create and initialise object.
    OBSUser *user = [[OBSUser alloc] initWithClient:client];
    // Set proprieties.
    user.userId = userId;
    user.userEmail = userEmail;
    user.userName = userName;
    user.userFile = userFile;

    return user;
}

@end
