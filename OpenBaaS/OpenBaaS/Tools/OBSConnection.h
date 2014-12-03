//
//  OBSConnection.h
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

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@class OBSAccount;
@class OBSApplication;
@class OBSChatRoom;
@class OBSImageFile;
@class OBSMedia;
@class OBSSession;
@class OBSUser;

extern NSString *const OBSConnectionResultDataKey;
extern NSString *const OBSConnectionResultMetadataKey;

@interface OBSConnection : NSObject

+ (NSString *)OpenBaaSHTTPAddress;
+ (NSString *)OpenBaaSTCPAddress;

+ (void)sendAsynchronousRequest:(NSURLRequest*) request
                          queue:(NSOperationQueue*) queue
              completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError))handler;
- (void)closeLogEntry;

@end

#pragma mark - GET

@interface OBSConnection (GET)

+ (NSMutableURLRequest *)get_requestForURL:(NSURL *)url;

#pragma mark apps/<appid>/account

+ (void)get_accountSessionWithToken:(NSString *)sessionToken client:(id<OBSClientProtocol>)client queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#pragma mark apps/<appid>/users

+ (void)get_application:(OBSApplication *)application usersWithQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

+ (void)get_application:(OBSApplication *)application userWithId:(NSString *)userId queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#pragma mark apps/<appid>/media/images

+ (void)get_media:(OBSMedia *)media imageFilesWithQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

+ (void)get_media:(OBSMedia *)media imageFileWithId:(NSString *)imageFileId queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

+ (void)get_imageFile:(OBSImageFile *)imageFile imageSize:(NSString *)imageSize queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#pragma mark apps/<appid>/data

+ (void)get_application:(OBSApplication *)application dataPath:(NSString *)path withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#pragma mark apps/<appid>/users/<userid>/data

+ (void)get_user:(OBSUser *)user dataPath:(NSString *)path withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

@end

#pragma mark - POST

@interface OBSConnection (POST)

+ (NSMutableURLRequest *)post_requestForURL:(NSURL *)url;

#pragma mark apps/<appid>/account

+ (void)post_account:(OBSAccount *)account signUpWithEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

+ (void)post_account:(OBSAccount *)account signInWithEmail:(NSString *)email password:(NSString *)password queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

+ (void)post_account:(OBSAccount *)account signOutWithSession:(OBSSession *)session all:(BOOL)all queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

+ (void)post_account:(OBSAccount *)account recoveryWithEmail:(NSString *)email queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

+ (void)post_account:(OBSAccount *)account changeFromPassword:(NSString *)oldPassword toPassword:(NSString *)newPassword queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#pragma mark apps/<appid>/account/integration

+ (void)post_account:(OBSAccount *)account integrationFacebookWithOAuthToken:(NSString *)oauthToken queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#pragma mark apps/<appid>/usersstate

+ (void)post_application:(OBSApplication *)application usersStateWithIds:(NSArray *)userIds includeMisses:(BOOL)includeMisses queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#pragma mark apps/<appid>/media/images

#if TARGET_OS_IPHONE
+ (void)post_media:(OBSMedia *)media image:(UIImage *)image withFileName:(NSString *)fileName queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;
#endif

+ (void)post_media:(OBSMedia *)media image:(UIImage *)image forMessage:(OBSChatMessage *)message withFileName:(NSString *)fileName queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#pragma mark apps/<appid>/chatroom

+ (void)post_application:(OBSApplication *)application openChatRoomWithUserIds:(NSArray *)userIds queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#if TARGET_OS_IPHONE
+ (void)post_chatRoom:(OBSChatRoom *)chatRoom postMessageText:(NSString *)text image:(UIImage *)image fromUser:(OBSUser *)user queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;
#endif

+ (void)post_chatRoom:(OBSChatRoom *)chatRoom getMessagesFromDate:(NSDate *)date onwards:(BOOL)onwards count:(NSUInteger)count withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

+ (void)post_chatRoom:(OBSChatRoom *)chatRoom markMessagesWithIds:(NSArray *)messageIds withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#pragma mark apps/<appid>/settings/notifications/APNS

+ (void)post_application:(OBSApplication *)application registerDeviceToken:(NSString *)deviceToken forNotificationsToClient:(NSString *)client withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

+ (void)post_application:(OBSApplication *)application unregisterDeviceToken:(NSString *)deviceToken forNotificationsToClient:(NSString *)client withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

@end

#pragma mark - PUT

@interface OBSConnection (PUT)

+ (NSMutableURLRequest *)put_requestForURL:(NSURL *)url;

#pragma mark apps/<appid>/data

+ (void)put_application:(OBSApplication *)application dataPath:(NSString *)path withQueryDictionary:(NSDictionary *)query object:(NSDictionary *)object completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#pragma mark apps/<appid>/users/<userid>/data

+ (void)put_user:(OBSUser *)user dataPath:(NSString *)path withQueryDictionary:(NSDictionary *)query object:(NSDictionary *)object completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

@end

#pragma mark - PATCH

@interface OBSConnection (PATCH)

+ (NSMutableURLRequest *)patch_requestForURL:(NSURL *)url;

#pragma mark apps/<appid>/account/session

+ (void)patch_session:(OBSSession *)session withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#pragma mark apps/<appid>/users/<userid>

+ (void)patch_user:(OBSUser *)user data:(NSDictionary *)data withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#pragma mark apps/<appid>/data

+ (void)patch_application:(OBSApplication *)application dataPath:(NSString *)path withQueryDictionary:(NSDictionary *)query object:(NSDictionary *)object completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#pragma mark apps/<appid>/users/<userid>/data

+ (void)patch_user:(OBSUser *)user dataPath:(NSString *)path withQueryDictionary:(NSDictionary *)query object:(NSDictionary *)object completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

@end

#pragma mark - DELETE

@interface OBSConnection (DELETE)

+ (NSMutableURLRequest *)delete_requestForURL:(NSURL *)url;

#pragma mark apps/<appid>/media/images

+ (void)delete_media:(OBSMedia *)media imageFileWithId:(NSString *)imageFileId queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#pragma mark apps/<appid>/data

+ (void)delete_application:(OBSApplication *)application dataPath:(NSString *)path withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

#pragma mark apps/<appid>/users/<userid>/data

+ (void)delete_user:(OBSUser *)user dataPath:(NSString *)path withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler;

@end
