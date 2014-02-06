//
//  OBSConnection.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 31/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@class OBSAccount;
@class OBSApplication;
@class OBSImageFile;
@class OBSMedia;
@class OBSSession;
@class OBSUser;

extern NSString *const OBSConnectionResultDataKey;
extern NSString *const OBSConnectionResultMetadataKey;

#warning Query - e.g., lat=38.748392&long=-9.233534&radius=10000&pageNumber=1&pageSize=10&orderBy=_id&orderType=desc

@interface OBSConnection : NSObject

+ (NSString *)OpenBaaSAddress;

+ (void)sendAsynchronousRequest:(NSURLRequest*) request
                          queue:(NSOperationQueue*) queue
              completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError))handler;

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
