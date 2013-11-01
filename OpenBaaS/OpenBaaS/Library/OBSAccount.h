//
//  OBSAccount.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 31/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBSAccount;
@class OBSApplication;
@class OBSSession;

typedef void (^OBSAccountSignedUp)(OBSAccount *account, OBSError *error, OBSSession *session);
typedef void (^OBSAccountSignedIn)(OBSAccount *account, OBSError *error, OBSSession *session);
typedef void (^OBSAccountSignedOut)(OBSAccount *account, OBSError *error, OBSSession *session);

@interface OBSAccount : OBSObject

@property (nonatomic, readonly) OBSApplication *application;

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password completionHandler:(OBSAccountSignedUp)handler;

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile completionHandler:(OBSAccountSignedUp)handler;

- (void)signInWithEmail:(NSString *)email password:(NSString *)password completionHandler:(OBSAccountSignedIn)handler;

- (void)signUpFromSession:(OBSSession *)session withCompletionHandler:(OBSAccountSignedOut)handler;

@end
