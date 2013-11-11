//
//  OBSApplication.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBSAccount;

@interface OBSApplication : OBSObject

/**
 *  Returns a newly created instance of OBSApplication with the specified object
 *  as the OpenBaaS client.
 *
 *  The object used as `client` must implement the protocol OBSClientProtocol.
 *
 *  The diffrence between using this method instead of initWithClient:, is that
 *  this method will not initiate an instance if `nil` is specified as client.
 *
 *  @param client The object to be used as OpenBaaS client.
 *
 *  @return A newly created OBSApplication object, or `nil`, if no client is
 *          specified.
 */
+ (OBSApplication *)applicationWithClient:(id<OBSClientProtocol>)client;

/**
 *  Method used to retrieve the application's appId.
 *
 *  This method relies on the client provided during initialisation.
 *
 *  @return An OpenBaaS appId.
 *
 *  @see [OBSClientProtocol appId]
 */
- (NSString *)applicationId;

/**
 *  Returns a newly created instance of OBSAccount.
 *
 *  The created OBSAccount object will be initialise with the same client used
 *  to initialise the receiver.
 *
 *  @return A newly created instance of OBSAccount.
 *
 *  @warning An account has a reference to its application. To avoid cycled
 *           references, a new object is created, initialised and returned every
 *           time the application receives an applicationAccount message.
 */
- (OBSAccount *)applicationAccount;

@end
