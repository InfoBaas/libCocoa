//
//  OBSChatRoom.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 26/02/14.
//  Copyright (c) 2014 Infosistema. All rights reserved.
//

#import <OpenBaaS/OpenBaaS.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@class OBSChatMessage;

@interface OBSChatRoom : OBSObject

@property (nonatomic, readonly) NSString *chatRoomId;
@property (nonatomic, readonly) NSNumber *unreadMessages;

- (void)getMessagesFromDate:(NSDate *)date onwards:(BOOL)onwards count:(NSUInteger)count withCompletionHandler:(void(^)(OBSChatRoom *chatRoom, NSArray *messages , OBSError *error))handler;

- (void)postFromUser:(OBSUser *)user text:(NSString *)text withCompletionHandler:(void(^)(OBSChatRoom *chatRoom, OBSUser *user, OBSChatMessage *message , OBSError *error))handler;

#if TARGET_OS_IPHONE
- (void)postFromUser:(OBSUser *)user image:(UIImage *)image withCompletionHandler:(void(^)(OBSChatRoom *chatRoom, OBSUser *user, OBSChatMessage *message, OBSError *error))handler;
#endif

#if TARGET_OS_IPHONE
- (void)postFromUser:(OBSUser *)user text:(NSString *)text image:(UIImage *)image withCompletionHandler:(void(^)(OBSChatRoom *chatRoom, OBSUser *user, OBSChatMessage *message, OBSError *error))handler;
#endif

- (void)markMessages:(NSArray *)messages asReadWithCompletionHandler:(void(^)(OBSChatRoom *chatRoom, NSArray *messages, BOOL marked, OBSError *error))handler;

@end

@interface OBSChatMessage : OBSObject

@property (nonatomic, readonly) OBSChatRoom *chatRoom;

@property (nonatomic, readonly) NSString *chatMessageId;
@property (nonatomic, readonly) NSString *senderId;
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly, getter = isUnread) BOOL unread;

@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSString *imageId;

- (void)markAsReadWithCompletionHandler:(void(^)(OBSChatMessage *message, BOOL marked, OBSError *error))handler;

@end
