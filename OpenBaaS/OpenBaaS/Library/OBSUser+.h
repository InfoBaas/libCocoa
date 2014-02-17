//
//  OBSUser+.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 05/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSUser.h"

@interface OBSUser ()

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userFile;

@property (nonatomic, assign) BOOL online;

@property (nonatomic, strong) CLLocation *userLastLocation;
@property (nonatomic, strong) CLLocation *userBaseLocation;
@property (nonatomic, assign) BOOL usesBaseLocation;

@property (nonatomic, strong) NSDate *lastUpdatedAt;

+ (NSArray *)nativeFields;

+ (OBSUser *)userFromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata withClient:(id<OBSClientProtocol>)client;

@end
