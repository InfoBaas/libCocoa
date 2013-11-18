//
//  OBSConnection.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 31/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBSAccount;
@class OBSApplication;
@class OBSSession;
@class OBSUser;

extern NSString *const OBSConnectionResultDataKey;
extern NSString *const OBSConnectionResultMetadataKey;

#warning Query - e.g., lat=38.748392&long=-9.233534&radius=10000&pageNumber=1&pageSize=10&orderBy=_id&orderType=desc

@interface OBSConnection : NSObject

+ (NSString *)OpenBaaSAddress;

@end

#pragma mark - GET

@interface OBSConnection (GET)

+ (NSMutableURLRequest *)get_requestForURL:(NSURL *)url;

#pragma mark apps/<appid>/account

+ (void)get_accountSessionWithToken:(NSString *)sessionToken client:(id<OBSClientProtocol>)client queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSError *error))handler;

#pragma mark apps/<appid>/users

+ (void)get_application:(OBSApplication *)application usersWithQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSError *error))handler;

+ (void)get_application:(OBSApplication *)application userWithId:(NSString *)userId queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSError *error))handler;

@end

#pragma mark - POST

@interface OBSConnection (POST)

+ (NSMutableURLRequest *)post_requestForURL:(NSURL *)url;

#pragma mark apps/<appid>/account

+ (void)post_account:(OBSAccount *)account signUpWithEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSError *error))handler;

+ (void)post_account:(OBSAccount *)account signInWithEmail:(NSString *)email password:(NSString *)password queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSError *error))handler;

+ (void)post_account:(OBSAccount *)account signOutWithSession:(OBSSession *)session all:(BOOL)all queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSError *error))handler;

+ (void)post_account:(OBSAccount *)account recoveryWithEmail:(NSString *)email queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSError *error))handler;

@end

#pragma mark - PATCH

@interface OBSConnection (PATCH)

+ (NSMutableURLRequest *)patch_requestForURL:(NSURL *)url;

#pragma mark apps/<appid>/account/session

+ (void)patch_session:(OBSSession *)session withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSError *error))handler;

@end
