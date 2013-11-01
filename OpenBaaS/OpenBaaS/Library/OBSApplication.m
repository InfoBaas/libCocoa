//
//  OBSApplication.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSApplication+_.h"

#import "OBSAccount+_.h"

@implementation OBSApplication

- (id)init
{
    return nil;
}

- (id)initWithClient:(id<OBSClientProtocol>)client
{
    self = [super init];
    if (self) {
        _client = client;
    }
    return self;
}

- (void)dealloc
{
    _client = nil;
}

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
