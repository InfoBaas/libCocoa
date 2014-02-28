//
//  OBSApplication.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBSAccount;
@class OBSChatRoom;
@class OBSMedia;
@class OBSUser;

@class OBSCollectionPage;

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
 *  Method used to retrieve the application's appKey.
 *
 *  This method relies on the client provided during initialisation.
 *
 *  @return An OpenBaaS appKey.
 *
 *  @see [OBSClientProtocol appKey]
 */
- (NSString *)applicationKey;

/**
 *  Returns a newly created instance of OBSAccount.
 *
 *  The created OBSAccount object will be initialise with the same client used
 *  to initialise the receiver.
 *
 *  @return A newly created instance of OBSAccount.
 *
 *  @note An account has a reference to its application. To avoid cycled
 *        references, a new object is created, initialised and returned every
 *        time the application receives an applicationAccount message.
 */
- (OBSAccount *)applicationAccount;

- (OBSMedia *)applicationMedia;

- (void)getUserWithId:(NSString *)userId withCompletionHandler:(void(^)(OBSApplication *application, NSString *userId, OBSUser *user, OBSError *error))handler;

- (void)getUserIdsWithQueryDictionary:(NSDictionary *)query completionHandler:(void(^)(OBSApplication *application, OBSCollectionPage *userIds, OBSError *error))handler;

- (void)getUsersWithQueryDictionary:(NSDictionary *)query completionHandler:(void(^)(OBSApplication *application, OBSCollectionPage *userIds, OBSError *error))handler elementCompletionHandler:(void(^)(OBSApplication *application, NSString *userId, OBSUser *user, OBSError *error))elementHandler;

- (void)getUsersWithQueryDictionary:(NSDictionary *)query completionHandler:(void(^)(OBSApplication *application, OBSCollectionPage *users, OBSError *error))handler;

- (void)getUsersStatesOfUsersWithIds:(NSArray *)userIds includeMisses:(BOOL)includeMisses withQueryDictionary:(NSDictionary *)query completionHandler:(void(^)(OBSApplication *application, NSArray *userIds, NSArray *usersState, OBSError *error))handler;

- (void)getChatRoomWithUsers:(NSArray *)users completionHandler:(void(^)(OBSApplication *application, NSArray *users, OBSChatRoom *chatRoom, OBSError *error))handler;

- (void)getChatRoomWithUserIds:(NSArray *)userIds completionHandler:(void(^)(OBSApplication *application, NSArray *userIds, OBSChatRoom *chatRoom, OBSError *error))handler;

#pragma mark Data

- (void)searchPath:(NSString *)path withQueryDictionary:(NSDictionary *)query completionHandler:(void(^)(OBSApplication *application, NSString *path, OBSCollectionPage *paths, OBSError *error))handler;

- (void)readPath:(NSString *)path withQueryDictionary:(NSDictionary *)query completionHandler:(void(^)(OBSApplication *application, NSString *path, id data, id metadata, OBSError *error))handler;

- (void)insertObject:(NSDictionary *)object atPath:(NSString *)path withCompletionHandler:(void(^)(OBSApplication *application, NSString *path, NSDictionary *object, BOOL inserted, OBSError *error))handler;

- (void)updatePath:(NSString *)path withObject:(NSDictionary *)object completionHandler:(void(^)(OBSApplication *application, NSString *path, NSDictionary *object, BOOL updated, OBSError *error))handler;

- (void)removePath:(NSString *)path withCompletionHandler:(void(^)(OBSApplication *application, NSString *path, BOOL deleted, OBSError *error))handler;

@end
