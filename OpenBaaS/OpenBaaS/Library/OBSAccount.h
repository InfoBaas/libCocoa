//
//  OBSAccount.h
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

- (void)signInWithFacebookOAuthToken:(NSString *)oauthToken completionHandler:(void(^)(OBSAccount *account, BOOL signedUp, BOOL signedIn, OBSSession *session, OBSError *error))handler;

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

- (void)changePasswordFrom:(NSString *)oldPassword to:(NSString *)newPassword withCompletionHandler:(void(^)(OBSAccount *account, BOOL changed, OBSError *error))handler;

@end
