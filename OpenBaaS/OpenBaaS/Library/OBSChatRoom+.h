//
//  OBSChatRoom+.h
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

#import "OBSChatRoom.h"

@interface OBSChatRoom ()

@property (nonatomic, strong) NSString *chatRoomId;
@property (nonatomic, strong) NSNumber *unreadMessages;

+ (OBSChatRoom *)chatRoomFromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata withClient:(id<OBSClientProtocol>)client;

@end

@interface OBSChatMessage ()

@property (nonatomic, strong) OBSChatRoom *chatRoom;

@property (nonatomic, strong) NSString *chatMessageId;
@property (nonatomic, strong) NSString *senderId;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) BOOL unread;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) BOOL hasImage;

+ (OBSChatMessage *)chatMessageInRoom:(OBSChatRoom *)room fromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata;

@end
