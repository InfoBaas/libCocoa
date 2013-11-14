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

/**
 *  The application to which the account is associated.
 */
@property (nonatomic, strong, readonly) OBSApplication *application;

/**
 *  Asynchronous sign up of a new user.
 *
 *  This method calls signUpWithEmail:password:userName:userFile:completionHandler:.
 *
 *  @param email    E-mail address of the user being signed up.
 *
 *                  It must not be `nil` and a valid e-mail address.
 *  @param password Password of the user being signed up.
 *
 *                  It must not be `nil`.
 *  @param handler  The block to be call after attempting this action.
 *
 *  @see signUpWithEmail:password:userName:userFile:completionHandler:
 */
- (void)signUpWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(OBSAccount *account, BOOL signedUp, OBSSession *session, OBSError *error))handler;

/**
 *  Asynchronous sign up of a new user.
 *
 *  @param email    E-mail address of the user being signed up.
 *
 *                  It must not be `nil` and a valid e-mail address.
 *  @param password Password of the user being signed up.
 *
 *                  It must not be `nil`.
 *  @param userName Name of the user being signed up.
 *  @param userFile Additional information string of the user being signed up.
 *  @param handler  The block to be call after attempting this action.
 *
 *                  The block takes four arguments:
 *
 *                  - _account_:
 *                     The receiver of the message that triggered this action.
 *                  - _signedUp_:
 *                     `YES` if the user was signed up successfully,
 *                     `NO` otherwise.
 *                  - _session_:
 *                     A session object, if a new session was initialised. `nil`
 *                     if a session was not opened or an error occurred while
 *                     interpreting the response received from the OpenBaaS.
 *                  - _error_:
 *                     An error, if one occurs. `nil` if no error occurs.
 *
 *  @note If the application requires an e-mail confirmation, a session will not
 *        be opened. In such a case, the handler will run with the argument values
 *        `YES`, `nil` and `nil`, in the defined order.
 *
 *  @see signUpWithEmail:password:completionHandler:
 */
- (void)signUpWithEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile completionHandler:(void(^)(OBSAccount *account, BOOL signedUp, OBSSession *session, OBSError *error))handler;

/**
 *  Asynchronous sign in of a user.
 *
 *  @param email    E-mail address of the user being signed up.
 *
 *                  It must not be `nil` and a valid e-mail address.
 *  @param password Password of the user being signed up.
 *
 *                  It must not be `nil`.
 *  @param handler  The block to be call after attempting this action.
 *
 *                  The block takes four arguments:
 *
 *                  - _account_:
 *                     The receiver of the message that triggered this action.
 *                  - _signedIn_:
 *                     `YES` if the user was signed in successfully,
 *                     `NO` otherwise.
 *                  - _session_:
 *                     A session object, if a new session was initialised. `nil`
 *                     if a session was not opened or an error occurred while
 *                     interpreting the response received from the OpenBaaS.
 *                  - _error_:
 *                     An error, if one occurs. `nil` if no error occurs.
 */
- (void)signInWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void(^)(OBSAccount *account, BOOL signedIn, OBSSession *session, OBSError *error))handler;

/**
 *  Asynchronous sign out of a user.
 *
 *  This method can be used to force OpenBaaS to expire a session, or all.
 *
 *  @param session  The session to be closed, or `nil` to close device's current
 *                  session.
 *  @param closeAll `YES` to close all session related to the user of the
 *                  specified session. `NO` to close only the specified session.
 *  @param handler  The block to be call after attempting this action.
 *
 *                  The block takes four arguments:
 *
 *                  - _account_:
 *                     The receiver of the message that triggered this action.
 *                  - _signedOut_:
 *                     `YES` if the user was signed out successfully,
 *                     `NO` otherwise.
 *                  - _session_:
 *                     The session closed by this action. This is the same
 *                     object received in the parameter `session`.
 *                  - _error_:
 *                     An error, if one occurs. `nil` if no error occurs.
 */
- (void)signOutFromSession:(OBSSession *)session closingAllOthers:(BOOL)closeAll withCompletionHandler:(void(^)(OBSAccount *account, BOOL signedOut, OBSSession *session, OBSError *error))handler;

/**
 *  This method requests OpenBaaS to send a recover password e-mail.
 *
 *  @param email   E-mail address for the password recovery.
 *  @param handler The block to be call after attempting this action.
 *
 *                  The block takes three arguments:
 *
 *                  - _account_:
 *                     The receiver of the message that triggered this action.
 *                  - _sent_:
 *                     `YES` if a recover password e-mail was sent to the
 *                     specified e-mail address, `NO` otherwise.
 *                  - _error_:
 *                     An error, if one occurs. `nil` if no error occurs.
 */
- (void)recoverPasswordForEmail:(NSString *)email withCompletionHandler:(void(^)(OBSAccount *account, BOOL sent, OBSError *error))handler;

@end
