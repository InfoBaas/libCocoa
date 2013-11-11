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

@interface OBSAccount : OBSObject

@property (nonatomic, strong, readonly) OBSApplication *application;

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(OBSAccount *account, BOOL signedUp, OBSSession *session, OBSError *error))handler;

- (void)signUpWithEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile completionHandler:(void(^)(OBSAccount *account, BOOL signedUp, OBSSession *session, OBSError *error))handler;

- (void)signInWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(OBSAccount *account, BOOL signedIn, OBSSession *session, OBSError *error))handler;

- (void)signOutFromSession:(OBSSession *)session closingAllOthers:(BOOL)closeAll withCompletionHandler:(void(^)(OBSAccount *account, BOOL signedOut, OBSSession *session, OBSError *error))handler;

- (void)recoverPasswordForEmail:(NSString *)email withCompletionHandler:(void(^)(OBSAccount *account, BOOL sent, OBSError *error))handler;

@end
