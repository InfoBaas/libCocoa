//
//  OBSObject.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 01/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSObject+.h"

static NSString *const _OBSObject_Tag = @"com.openbaas.object.tag";
static NSString *const _OBSObject_Identifier = @"com.openbaas.object.identifier";

@implementation OBSObject

+ (id)newWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation andClient:(id<OBSClientProtocol>)client
{
    return [[self alloc] initWithDictionaryRepresentation:dictionaryRepresentation andClient:client];
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation andClient:(id<OBSClientProtocol>)client
{
    self = [super init];
    if (self) {
        _client = client;
        _tag = [dictionaryRepresentation[_OBSObject_Tag] integerValue];
        _identifier = dictionaryRepresentation[_OBSObject_Identifier];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    return _identifier
    ? @{_OBSObject_Tag: @(_tag),
        _OBSObject_Identifier: _identifier}
    : @{_OBSObject_Tag: @(_tag)};
}

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
