//
//  OBSSession.h
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

@class OBSSession;
@class OBSUser;

@interface OBSSession : OBSObject

/**
 *  The user associated to the session.
 */
@property (nonatomic, strong, readonly) OBSUser *user;

@property (nonatomic, assign, readonly) UInt32 socketPort;

/**
 *  Sets the receiver as the device's current session.
 *
 *  This method saves the token of the receiver in the user defaults. It does
 *  not save all the information about the session, nor its user.
 */
- (void)setAsCurrentSession;

/**
 *  Returns whether the receiver is the device's current session or not.
 *
 *  @return `YES` if the receiver is the device's current session, `NO` otherwise.
 */
- (BOOL)isCurrentSession;

/**
 *  Opens the device's current session, if possible.
 *
 *  If this method returns `YES`, the device has a current session and an
 *  asynchronous request to OpenBaaS has been done to refresh it.
 *
 *  If this method returns `NO`, the device has no current session available.
 *
 *  When `NO` is returned, the sender should not wait for the handler to be
 *  called. The handler is only called when this method returns `NO`.
 *
 *  @param client  OpenBaaS client to be used to open the session.
 *  @param handler The block to be call after attempting this action.
 *
 *  @return `YES` if a current session was found, `NO` otherwise.
 */
+ (BOOL)openCurrentSessionWithClient:(id<OBSClientProtocol>)client andCompletionHandler:(void(^)(BOOL opened, OBSSession *session, OBSError *error))handler;

/**
 *  Clears the device's current session.
 *
 *  @see forgetIfIsCurrentSession
 */
+ (void)forgetCurrentSession;

/**
 *  Clears the device's current session only if it matches the receiver.
 *
 *  To clear the device's current session regardless of the receiver, see forgetCurrentSession.
 *
 *  @return `YES` if the device's current session was cleared, `NO` if the
 *          receiver didn't match with the device's current session.
 *
 *  @see forgetCurrentSession
 */
- (BOOL)forgetIfIsCurrentSession;

@end
