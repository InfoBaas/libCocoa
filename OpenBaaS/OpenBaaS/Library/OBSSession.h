//
//  OBSSession.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBSApplication;
@class OBSSession;

typedef void (^OBSSessionSignedUp)(OBSSession *session, OBSError *error);
typedef void (^OBSSessionSignedIn)(OBSSession *session, OBSError *error);
typedef void (^OBSSessionSignedOut)(OBSSession *session, OBSError *error);

@interface OBSSession : NSObject

+ (void)signUpToApplication:(OBSApplication *)app withEmail:(NSString *)email password:(NSString *)password completionHandler:(OBSSessionSignedUp)handler;

+ (void)signUpToApplication:(OBSApplication *)app withEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile completionHandler:(OBSSessionSignedUp)handler;

+ (void)signInToApplication:(OBSApplication *)app withEmail:(NSString *)email password:(NSString *)password completionHandler:(OBSSessionSignedIn)handler;

- (void)signUpWithCompletionHandler:(OBSSessionSignedOut)handler;

@end
