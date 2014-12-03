//
//  OBSChatRoom.h
//  OpenBaaS
//
/*****************************************************************************************
 Infosistema - Lib-Cocoa
 Copyright(C) 2002-2014 Infosistema, S.A.
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU Affero General Public License for more details.
 You should have received a copy of the GNU Affero General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 www.infosistema.com
 info@openbaas.com
 Av. José Gomes Ferreira, 11 3rd floor, s.34
 Miraflores
 1495-139 Algés Portugal
 ****************************************************************************************/

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@class OBSUser;

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
@property (nonatomic, readonly) BOOL hasImage;
@property (nonatomic, strong) NSString *imageId;

- (void)markAsReadWithCompletionHandler:(void(^)(OBSChatMessage *message, BOOL marked, OBSError *error))handler;

@end
