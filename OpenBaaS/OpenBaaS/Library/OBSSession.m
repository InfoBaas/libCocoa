//
//  OBSSession.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSSession+.h"

#import "OBSUser+.h"

#import "OBSConnection.h"

static NSString *const _OBSSession_OBSObject = @"com.openbaas.session.-";
static NSString *const _OBSSession_Token = @"com.openbaas.session.token";
static NSString *const _OBSSession_User = @"com.openbaas.session.user";

@implementation OBSSession

- (void)dealloc
{
    _user = nil;
    _token = nil;
}

+ (OBSSession *)sessionFromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata withClient:(id<OBSClientProtocol>)client
{
    if ([data isEqual:[NSNull null]]) {
        data = nil;
    }
    if ([metadata isEqual:[NSNull null]]) {
        metadata = nil;
    }
    
    NSString *sessionToken = data[@"returnToken"];
    if (!sessionToken || [sessionToken isEqual:[NSNull null]]) {
        return nil; // JSON does not contain a session token.
    }

    // Create user.
    OBSUser *user = [OBSUser userFromDataJSON:data andMetadataJSON:metadata withClient:client];
    if (!user) {
        // User wasn't created.
        return nil;
    }

    // Create and initialise object.
    OBSSession *session = [[OBSSession alloc] initWithClient:client];
    // Set proprieties.
    session.token = sessionToken;
    session.user = user;

    return session;
}

- (void)setAsCurrentSession
{
    _obs_settings_set_sessionInfo(self.token, self.user.userId);
}

- (BOOL)isCurrentSession
{
    return [_obs_settings_get_sessionToken() isEqualToString:self.token];
}

+ (BOOL)openCurrentSessionWithClient:(id<OBSClientProtocol>)client andCompletionHandler:(void (^)(BOOL, OBSSession *, OBSError *))handler
{
    NSString *sessionToken = _obs_settings_get_sessionToken();
    if (!sessionToken) {
        return NO; // No current session.
    }

    [OBSConnection get_accountSessionWithToken:sessionToken client:client queryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
        // Called with error?
        if (error) {
            handler(NO, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
            return;
        }

        // Create session.
        OBSSession *session = nil;
        if ([result isKindOfClass:[NSDictionary class]]) {
            session = [self sessionFromDataJSON:result[OBSConnectionResultDataKey] andMetadataJSON:result[OBSConnectionResultMetadataKey] withClient:client];
        }
        if (!session) {
            // Session wasn't created.
            handler(YES, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
            return;
        }

        handler(YES, session, nil);
    }];

    return YES;
}

+ (void)forgetCurrentSession
{
    _obs_settings_set_sessionInfo(nil, nil);
}

- (BOOL)forgetIfIsCurrentSession
{
    if ([self isCurrentSession]) {
        _obs_settings_set_sessionInfo(nil, nil);
        return YES;
    }
    return NO;
}

#pragma mark -

+ (id)newWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation andClient:(id<OBSClientProtocol>)client
{
    return [[self alloc] initWithDictionaryRepresentation:dictionaryRepresentation andClient:client];
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation andClient:(id<OBSClientProtocol>)client
{
    self = [super initWithDictionaryRepresentation:dictionaryRepresentation[_OBSSession_OBSObject] andClient:client];
    if (self) {
        _token = dictionaryRepresentation[_OBSSession_Token];
        _user = [OBSUser newWithDictionaryRepresentation:dictionaryRepresentation[_OBSSession_User] andClient:client];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{_OBSSession_OBSObject: [super dictionaryRepresentation],
             _OBSSession_Token: _token,
             _OBSSession_User: [_user dictionaryRepresentation]};
}

@end
