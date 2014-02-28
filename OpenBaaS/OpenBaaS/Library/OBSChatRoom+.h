//
//  OBSChatRoom+.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 26/02/14.
//  Copyright (c) 2014 Infosistema. All rights reserved.
//

#import "OBSChatRoom.h"

@interface OBSChatRoom ()

@property (nonatomic, strong) NSString *chatRoomId;

+ (OBSChatRoom *)chatRoomFromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata withClient:(id<OBSClientProtocol>)client;

@end

@interface OBSChatMessage ()

@property (nonatomic, strong) OBSChatRoom *chatRoom;

@property (nonatomic, strong) NSString *chatMessageId;
@property (nonatomic, strong) NSString *senderId;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *imageId;

+ (OBSChatMessage *)chatMessageInRoom:(OBSChatRoom *)room fromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata;

@end
