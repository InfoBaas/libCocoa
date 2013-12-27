//
//  OBSUser.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 05/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <OpenBaaS/OpenBaaS.h>

@interface OBSUser : OBSObject

@property (nonatomic, strong, readonly) NSString *userId;
@property (nonatomic, strong, readonly) NSString *userEmail;
@property (nonatomic, strong, readonly) NSString *userName;
@property (nonatomic, strong, readonly) NSString *userFile;

- (void)updateUserWithCompletionHandler:(void(^)(OBSUser *user, OBSError *error))handler;

#pragma mark Data

- (void)readPath:(NSString *)path withQueryDictionary:(NSDictionary *)query completionHandler:(void(^)(OBSUser *user, NSString *path, id data, id metadata, OBSError *error))handler;

- (void)insertObject:(NSDictionary *)object atPath:(NSString *)path withCompletionHandler:(void(^)(OBSUser *user, NSString *path, NSDictionary *object, BOOL inserted, OBSError *error))handler;

- (void)updatePath:(NSString *)path withObject:(NSDictionary *)object completionHandler:(void(^)(OBSUser *user, NSString *path, NSDictionary *object, BOOL updated, OBSError *error))handler;

- (void)removePath:(NSString *)path withCompletionHandler:(void(^)(OBSUser *user, NSString *path, BOOL deleted, OBSError *error))handler;

@end
