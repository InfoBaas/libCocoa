//
//  OBSRealTimeChannel.h
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
#import <UIKit/UIKit.h>

#import "OBSClientProtocol.h"

@class OBSChatRoom;
@class OBSImageFile;
@class OBSError;

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

- (void)postMessageWithChatRoom:(OBSChatRoom *)chatRoom senderId:(NSString *)senderId text:(NSString *)text image:(UIImage *)image withCompletionHandler:(void(^)(BOOL ok, id result, NSString *errorMessage))handler andImageCompletionHandler:(void(^)(BOOL ok, UIImage *image, OBSImageFile *file, OBSError *error))ihandler;

@end
