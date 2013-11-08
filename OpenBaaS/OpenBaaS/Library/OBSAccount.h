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

typedef void (^OBSAccountSignUpCompletionHandler)(OBSAccount *account, BOOL signedUp, OBSSession *session, OBSError *error);
typedef void (^OBSAccountSignInCompletionHandler)(OBSAccount *account, BOOL signedIn, OBSSession *session, OBSError *error);
typedef void (^OBSAccountSignOutCompletionHandler)(OBSAccount *account, BOOL signedOut, OBSSession *session, OBSError *error);
typedef void (^OBSAccountRecoverCompletionHandler)(OBSAccount *account, BOOL sent, OBSError *error);

@interface OBSAccount : OBSObject

@property (nonatomic, strong, readonly) OBSApplication *application;

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password completionHandler:(OBSAccountSignUpCompletionHandler)handler;

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile completionHandler:(OBSAccountSignUpCompletionHandler)handler;

- (void)signInWithEmail:(NSString *)email password:(NSString *)password completionHandler:(OBSAccountSignInCompletionHandler)handler;

- (void)signOutFromSession:(OBSSession *)session closingAllOthers:(BOOL)closeAll withCompletionHandler:(OBSAccountSignOutCompletionHandler)handler;

- (void)recoverPasswordForEmail:(NSString *)email withCompletionHandler:(OBSAccountRecoverCompletionHandler)handler;

@end
