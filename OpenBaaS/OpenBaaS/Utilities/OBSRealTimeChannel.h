//
//  OBSRealTimeChannel.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 01/04/14.
//  Copyright (c) 2014 Tiago Rodrigues. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBSRealTimeChannel : NSObject

+ (OBSRealTimeChannel *)defaultChannel;

#pragma mark Connection

- (BOOL)connectToPort:(UInt32)port;
- (BOOL)reconnect;
- (void)closeConnection;

#pragma mark Ping

- (void)ping;
- (void)pong;

@end
