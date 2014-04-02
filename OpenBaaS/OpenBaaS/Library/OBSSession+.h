//
//  OBSSession+.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 31/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSSession.h"

@interface OBSSession ()

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) OBSUser *user;
@property (nonatomic, assign) UInt32 socketPort;

+ (OBSSession *)sessionFromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata withClient:(id<OBSClientProtocol>)client;

@end
