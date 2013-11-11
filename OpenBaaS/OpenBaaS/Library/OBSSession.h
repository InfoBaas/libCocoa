//
//  OBSSession.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBSSession;
@class OBSUser;

@interface OBSSession : OBSObject

@property (nonatomic, strong, readonly) OBSUser *user;

- (void)saveAsCurrentSession;
- (BOOL)isCurrentSession;
- (BOOL)forgetIfIsCurrentSession;
+ (BOOL)openCurrentSessionWithClient:(id<OBSClientProtocol>)client andCompletionHandler:(void(^)(BOOL opened, OBSSession *session, OBSError *error))handler;
+ (void)forgetCurrentSession;

@end
