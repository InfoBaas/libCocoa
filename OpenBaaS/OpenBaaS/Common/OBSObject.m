//
//  OBSObject.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 01/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSObject+.h"

@implementation OBSObject

- (id)init
{
    return nil;
}

- (id)initWithClient:(id<OBSClientProtocol>)client
{
    self = [super init];
    if (self) {
        _client = client;
        _tag = 0;
        _identifier = nil;
    }
    return self;
}

- (void)dealloc
{
    _client = nil;
}

@end
