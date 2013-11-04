//
//  OBSObject.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 01/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBSObject : NSObject

@property (nonatomic, strong, readonly) id<OBSClientProtocol> client;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) NSString *identifier;

@end
