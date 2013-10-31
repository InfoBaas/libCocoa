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

- (id)initWithAppID:(NSString *)appID
{
    self = [super init];
    if (self) {
        _appID = appID;
    }
    return self;
}

- (void)dealloc
{
    _appID = nil;
}

+ (OBSApplication *)applicationWithAppID:(NSString *)appID
{
    return [[self alloc] initWithAppID:appID];
}

- (OBSAccount *)applicationAccount
{
    return [[OBSAccount alloc] initWithApplication:self];
}

@end
