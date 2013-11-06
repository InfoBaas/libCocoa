//
//  OBSApplication.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSApplication+.h"

#import "OBSAccount+.h"

@implementation OBSApplication

+ (OBSApplication *)applicationWithClient:(id<OBSClientProtocol>)client
{
    return [[self alloc] initWithClient:client];
}

- (NSString *)applicationId
{
    return [self.client appId];
}

- (OBSAccount *)applicationAccount
{
    return [[OBSAccount alloc] initWithApplication:self];
}

@end
