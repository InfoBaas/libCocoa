//
//  OBSImageFile+.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 17/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSImageFile.h"

@interface OBSImageFile ()

#if TARGET_OS_IPHONE
@property (nonatomic, strong) UIImage *image;
#endif

+ (NSArray *)nativeFields;

+ (OBSImageFile *)imageFileFromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata withClient:(id<OBSClientProtocol>)client;

@end
