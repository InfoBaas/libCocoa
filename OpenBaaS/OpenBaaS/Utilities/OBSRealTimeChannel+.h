//
//  OBSRealTimeChannel+.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 01/04/14.
//  Copyright (c) 2014 Tiago Rodrigues. All rights reserved.
//

#import "OBSRealTimeChannel.h"

@interface OBSRealTimeChannel () <NSStreamDelegate>

@property (nonatomic, strong) id<OBSClientProtocol> client;

- (void)processData:(NSDictionary *)data;

@end
