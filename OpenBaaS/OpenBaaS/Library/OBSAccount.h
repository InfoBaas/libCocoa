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

typedef void (^OBSAccountSignUp)(OBSAccount *account, OBSError *error, OBSSession *session);
typedef void (^OBSAccountSignIn)(OBSAccount *account, OBSError *error, OBSSession *session);
typedef void (^OBSAccountSignOut)(OBSAccount *account, OBSError *error, OBSSession *session);
typedef void (^OBSAccountRecover)(OBSAccount *account, OBSError *error, BOOL sent);

@interface OBSAccount : OBSObject

@property (nonatomic, strong, readonly) OBSApplication *application;

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password completionHandler:(OBSAccountSignUp)handler;

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile completionHandler:(OBSAccountSignUp)handler;

- (void)signInWithEmail:(NSString *)email password:(NSString *)password completionHandler:(OBSAccountSignIn)handler;

- (void)signOutFromSession:(OBSSession *)session closingAllOthers:(BOOL)closeAll withCompletionHandler:(OBSAccountSignOut)handler;

- (void)recoverPasswordForEmail:(NSString *)email withCompletionHandler:(OBSAccountRecover)handler;

@end
