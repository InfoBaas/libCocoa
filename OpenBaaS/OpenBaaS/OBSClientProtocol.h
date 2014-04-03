//
//  OBSClientProtocol.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 31/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBSRealTimeChannel;
@class OBSChatMessage;

@protocol OBSClientProtocol <NSObject>

- (NSString *)appId;
- (NSString *)appKey;

@optional

- (void)realTimeChannelOpened:(OBSRealTimeChannel *)channel;
- (void)realTimeChannel:(OBSRealTimeChannel *)channel closedWithError:(NSError *)error;

- (void)realTimeChannelWasPinged:(OBSRealTimeChannel *)channel;
- (void)realTimeChannelWasPonged:(OBSRealTimeChannel *)channel;

- (void)realTimeChannel:(OBSRealTimeChannel *)channel receivedMessage:(OBSChatMessage *)message completionHandler:(void(^)(BOOL ok))handler;

@end
