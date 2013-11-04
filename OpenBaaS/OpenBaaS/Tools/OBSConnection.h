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

@interface OBSConnection : NSObject

+ (NSString *)OpenBaaSAddress;

@end

#pragma mark - POST

@interface OBSConnection (POST)

+ (NSMutableURLRequest *)post_requestForAddress:(NSString *)address;

#pragma mark apps/<appid>/account

+ (void)post_account:(OBSAccount *)account signUpWithEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error))handler;

+ (void)post_account:(OBSAccount *)account signInWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error))handler;

+ (void)post_accountSignOutWithSession:(OBSSession *)session all:(BOOL)all completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error))handler;

+ (void)post_account:(OBSAccount *)account recoveryWithEmail:(NSString *)email completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error))handler;

@end
