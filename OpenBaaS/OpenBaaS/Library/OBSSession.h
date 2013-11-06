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

typedef void (^OBSSessionOpenCompletionHandler)(OBSSession *session, BOOL opened, OBSError *error);

@interface OBSSession : OBSObject

@property (nonatomic, strong, readonly) OBSUser *user;

- (void)saveAsCurrentSession;
+ (OBSSession *)openCurrentSessionWithClient:(id<OBSClientProtocol>)client andCompletionHandler:(OBSSessionOpenCompletionHandler)handler;

@end
