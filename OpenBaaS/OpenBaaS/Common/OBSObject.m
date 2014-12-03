//
//  OBSObject.m
//  OpenBaaS
//
/*****************************************************************************************
 Infosistema - Lib-Cocoa
 Copyright(C) 2002-2014 Infosistema, S.A.
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU Affero General Public License for more details.
 You should have received a copy of the GNU Affero General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 www.infosistema.com
 info@openbaas.com
 Av. José Gomes Ferreira, 11 3rd floor, s.34
 Miraflores
 1495-139 Algés Portugal
 ****************************************************************************************/

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
