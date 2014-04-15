//
//  OBSRealTimeChannel.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 01/04/14.
//  Copyright (c) 2014 Tiago Rodrigues. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "OBSClientProtocol.h"

@class OBSChatRoom;

NSString *OBSRealTimeChannelNotificationMessageImagePostSucceeded(NSString *messageId);
NSString *OBSRealTimeChannelNotificationMessageImagePostFailed(NSString *messageId);

@interface OBSRealTimeChannel : NSObject

+ (OBSRealTimeChannel *)defaultChannel;

- (void)setClient:(id<OBSClientProtocol>)client;

#pragma mark Connection

- (BOOL)connectToPort:(UInt32)port;
- (BOOL)reconnect;
- (void)closeConnection;
- (BOOL)isConnected;

#pragma mark Authenticate

- (void)authenticateWithCompletionHandler:(void(^)(BOOL ok, id result, NSString *errorMessage))handler;

#pragma mark Ping

- (void)ping;
- (void)pong;

#pragma mark Chat

- (void)openChatWithUserIds:(NSArray *)userIds withCompletionHandler:(void(^)(BOOL ok, id result, NSString *errorMessage))handler;

- (void)sendMessageWithChatRoom:(OBSChatRoom *)chatRoom senderId:(NSString *)senderId text:(NSString *)text withCompletionHandler:(void(^)(BOOL ok, id result, NSString *errorMessage))handler;
- (void)sendMessageWithChatRoom:(OBSChatRoom *)chatRoom senderId:(NSString *)senderId text:(NSString *)text image:(UIImage *)image withCompletionHandler:(void(^)(BOOL ok, id result, NSString *errorMessage))handler;

- (void)postMessageWithChatRoom:(OBSChatRoom *)chatRoom senderId:(NSString *)senderId text:(NSString *)text image:(UIImage *)image withCompletionHandler:(void(^)(BOOL ok, id result, NSString *errorMessage))handler;

@end
