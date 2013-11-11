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

/**
 *  The user associated to the session.
 */
@property (nonatomic, strong, readonly) OBSUser *user;

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
 *
 *  @bug This method is yet not fully implemented.
 *
 *       A call to this method that would result in the return of `YES` will
 *       raise an NSInternalInconsistencyException.
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
