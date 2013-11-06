//
//  OBSUser.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 05/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSUser+.h"

@implementation OBSUser

+ (OBSUser *)userFromJSON:(NSDictionary *)json withClient:(id<OBSClientProtocol>)client
{
    NSString *userId = json[@"userId"];
    NSString *userEmail = json[@"email"];
    NSString *userName = json[@"userName"];
    if ([userName isEqual:[NSNull null]]) {
        userName = nil;
    }
    NSString *userFile = json[@""];
    if ([userFile isEqual:[NSNull null]]) {
        userFile = nil;
    }
    OBSUser *user = [[OBSUser alloc] initWithClient:client];
    user.userId = userId;
    user.userEmail = userEmail;
    user.userName = userName;
    user.userFile = userFile;
    return user;
}

@end
