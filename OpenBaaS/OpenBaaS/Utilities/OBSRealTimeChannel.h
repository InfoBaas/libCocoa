//
//  OBSRealTimeChannel.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 01/04/14.
//  Copyright (c) 2014 Tiago Rodrigues. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OBSRealTimeChannel : NSObject

+ (OBSRealTimeChannel *)defaultChannel;

#pragma mark Connection

- (BOOL)connectToPort:(UInt32)port;
- (BOOL)reconnect;
- (void)closeConnection;
- (BOOL)isConnected;

#pragma mark Authenticate

- (void)authenticateWithTarget:(id)target;

#pragma mark Ping

- (void)ping;
- (void)pong;

#pragma mark Chat

- (NSDictionary *)target:(id)target openChatWithUserIds:(NSArray *)userIds;

- (NSDictionary *)target:(id)target sendsMessageWithChatId:(NSString *)chatId senderId:(NSString *)senderId text:(NSString *)text;
- (NSDictionary *)target:(id)target sendsMessageWithChatId:(NSString *)chatId senderId:(NSString *)senderId text:(NSString *)text image:(UIImage *)image;

@end

#pragma mark - Informal Protocol

@protocol OBSRealTimeChannelMessageTarget <NSObject>

@optional

- (void)realTimeChannel:(OBSRealTimeChannel *)channel hasBeenAuthenticated:(BOOL)authenticated;

- (void)realTimeChannel:(OBSRealTimeChannel *)channel receivedAnOKForMessage:(id)message;
- (void)realTimeChannel:(OBSRealTimeChannel *)channel receivedAnErrorMessage:(NSString *)error forMessage:(id)message;
                         
@end
