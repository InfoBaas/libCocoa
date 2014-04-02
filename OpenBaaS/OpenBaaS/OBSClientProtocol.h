//
//  OBSClientProtocol.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 31/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OBSRealTimeChannel.h"

@protocol OBSClientProtocol <NSObject>

- (NSString *)appId;
- (NSString *)appKey;

@optional

- (void)realTimeChannelOpened:(OBSRealTimeChannel *)channel;
- (void)realTimeChannel:(OBSRealTimeChannel *)channel closedWithError:(NSError *)error;

- (void)realTimeChannelWasPinged:(OBSRealTimeChannel *)channel;
- (void)realTimeChannelWasPonged:(OBSRealTimeChannel *)channel;

- (void)realTimeChannel:(OBSRealTimeChannel *)channel receivedMessageWithChatId:(NSString *)chatId senderId:(NSString *)senderId text:(NSString *)text image:(UIImage *)image completionHandler:(void(^)(BOOL ok))handler;

@end
