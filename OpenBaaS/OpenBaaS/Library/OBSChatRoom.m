//
//  OBSChatRoom.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 26/02/14.
//  Copyright (c) 2014 Infosistema. All rights reserved.
//

#import "OBSChatRoom+.h"

#import "OBSConnection.h"

static NSString *const _OBSChatRoom_OBSObject = @"com.openbaas.chat-room.-";

static NSString *const _OBSChatRoom_ChatRoomId = @"com.openbaas.chat-room.chat-room-id";

@implementation OBSChatRoom

+ (OBSChatRoom *)chatRoomFromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata withClient:(id<OBSClientProtocol>)client
{
    if ([data isEqual:[NSNull null]]) {
        data = nil;
    }
    if ([metadata isEqual:[NSNull null]]) {
        metadata = nil;
    }
    
    NSString *chatRoomId = data[@"_id"];
    if (!chatRoomId) {
        return nil;
    }
    
    OBSChatRoom *chatRoom = [[self alloc] initWithClient:client];
    chatRoom.chatRoomId = chatRoomId;
    return chatRoom;
}

- (void)getMessagesFromDate:(NSDate *)date onwards:(BOOL)onwards count:(NSUInteger)count withCompletionHandler:(void(^)(OBSChatRoom *chatRoom, NSArray *messages , OBSError *error))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasDate = date && [date isKindOfClass:[NSDate class]];
        if (hasDate) {
            [OBSConnection post_chatRoom:self getMessagesFromDate:date onwards:onwards count:count withQueryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler) {
                    return;
                }
                
                // Called with error?
                if (error) {
                    handler(self, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }
                
                // Check result.
                NSArray *array = result;
                if (![array isKindOfClass:[NSArray class]]) {
                    // Result not valid.
                    handler(self, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                    return;
                }
                
                // Process result.
                NSMutableArray *messages = [NSMutableArray arrayWithCapacity:[array count]];
                for (NSDictionary *data in array) {
                    OBSChatMessage *chatMessage = [OBSChatMessage chatMessageInRoom:self fromDataJSON:data andMetadataJSON:nil];
                    if (!chatMessage) {
                        // Result not valid.
                        handler(self, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                        return;
                    }
                    [messages addObject:chatMessage];
                }
                handler(self, [NSArray arrayWithArray:messages], nil);
            }];
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:1];
            // Add missing parameters to the array.
            if (!hasDate) [missingRequiredParameters addObject:@"date"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, nil, error);
        }
    });
}

- (void)postFromUser:(OBSUser *)user text:(NSString *)text withCompletionHandler:(void (^)(OBSChatRoom *, OBSUser *, OBSChatMessage *, OBSError *))handler
{
#if TARGET_OS_IPHONE
    [self postFromUser:user text:text image:nil withCompletionHandler:handler];
#endif
}

#if TARGET_OS_IPHONE
- (void)postFromUser:(OBSUser *)user image:(UIImage *)image withCompletionHandler:(void (^)(OBSChatRoom *, OBSUser *, OBSChatMessage *, OBSError *))handler
{
    [self postFromUser:user text:nil image:image withCompletionHandler:handler];
}
#endif

#if TARGET_OS_IPHONE
- (void)postFromUser:(OBSUser *)user text:(NSString *)text image:(UIImage *)image withCompletionHandler:(void (^)(OBSChatRoom *, OBSUser *, OBSChatMessage *, OBSError *))handler
#endif
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasUser = user && [user isKindOfClass:[OBSUser class]];
        if (hasUser) {
            [OBSConnection post_chatRoom:self postMessageText:text image:image fromUser:user queryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler) {
                    return;
                }
                
                // Called with error?
                if (error) {
                    handler(self, user, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }
                
                // Create chat message.
                OBSChatMessage *chatMessage = nil;
                if ([result isKindOfClass:[NSDictionary class]]) {
                    chatMessage = [OBSChatMessage chatMessageInRoom:self fromDataJSON:result andMetadataJSON:nil];
                }
                if (!chatMessage) {
                    // User wasn't created.
                    handler(self, user, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                    return;
                }
                
                handler(self, user, chatMessage, nil);
            }];
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:1];
            // Add missing parameters to the array.
            if (!hasUser) [missingRequiredParameters addObject:@"user"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, user, nil, error);
        }
    });
}

- (void)markMessages:(NSArray *)messages asReadWithCompletionHandler:(void (^)(OBSChatRoom *, NSArray *, BOOL, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasMessages = messages && [messages isKindOfClass:[NSArray class]];
        if (hasMessages) {
            NSArray *chats = [messages valueForKey:@"chatMessageId"];
            if ([chats count] == [messages count]) {
                [OBSConnection post_chatRoom:self markMessagesWithIds:chats withQueryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                    if (!handler) {
                        return;
                    }
                    
                    if (error) {
                        handler(self, messages, NO, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    } else {
                        handler(self, messages, YES, nil);
                    }
                }];
            } else if (handler) {
                // Create userInfo dictionary.
                NSDictionary *userInfo = @{kOBSErrorUserInfoKeyInvalidParameters: @[@"messages"]};
                // Create an error instace to send to the callback.
                OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                       code:kOBSLocalErrorCodeInvalidParameters
                                                   userInfo:userInfo];
                // Action completed with error.
                handler(self, messages, NO, error);
            }
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:1];
            // Add missing parameters to the array.
            if (!hasMessages) [missingRequiredParameters addObject:@"messages"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, messages, NO, error);
        }
    });
}

#pragma mark -

+ (id)newWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation andClient:(id<OBSClientProtocol>)client
{
    return [[self alloc] initWithDictionaryRepresentation:dictionaryRepresentation andClient:client];
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation andClient:(id<OBSClientProtocol>)client
{
    self = [super initWithDictionaryRepresentation:dictionaryRepresentation[_OBSChatRoom_OBSObject] andClient:client];
    if (self) {
        _chatRoomId = dictionaryRepresentation[_OBSChatRoom_ChatRoomId];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    dictionary[_OBSChatRoom_OBSObject] = [super dictionaryRepresentation];
    
    if (_chatRoomId) {
        dictionary[_OBSChatRoom_ChatRoomId] = _chatRoomId;
    }

    return [NSDictionary dictionaryWithDictionary:dictionary];
}

@end

#pragma mark -

@implementation OBSChatMessage

+ (OBSChatMessage *)chatMessageInRoom:(OBSChatRoom *)room fromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata
{
    if ([data isEqual:[NSNull null]]) {
        data = nil;
    }
    if ([metadata isEqual:[NSNull null]]) {
        metadata = nil;
    }
    
    NSString *chatMessageId = data[@"_id"];
    if (!chatMessageId || [chatMessageId isEqual:[NSNull null]]) {
        return nil;
    }
    
    NSString *senderId = data[@"sender"];
    if (!senderId || [senderId isEqual:[NSNull null]]) {
        return nil;
    }
    
    NSDate *date = nil;
    NSNumber *milli = data[@"date"];
    if (milli && ![milli isEqual:[NSNull null]]) {
        date = [NSDate dateWithTimeIntervalSince1970:([milli doubleValue]/1000)];
    }
    
    NSNumber *read = data[@"read"];
    if (read && [read isEqual:[NSNull null]]) {
        read = nil;
    }
    
    NSString *text = data[@"messageText"];
    if ([text isEqual:[NSNull null]]) {
        text = nil;
    }
    
    NSString *imageId = data[@"imageId"];
    if ([imageId isEqual:[NSNull null]] || [imageId isEqualToString:[NSString string]]) {
        imageId = nil;
    }
    
    OBSChatMessage *chatMessage = [[self alloc] initWithClient:room.client];
    chatMessage.chatRoom = room;
    
    chatMessage.chatMessageId = chatMessageId;
    chatMessage.senderId = senderId;
    chatMessage.date = date;
    chatMessage.unread = ![read boolValue];
    
    chatMessage.text = text;
    chatMessage.imageId = imageId;
    
    return chatMessage;
}

- (void)markAsReadWithCompletionHandler:(void (^)(OBSChatMessage *, BOOL, OBSError *))handler
{
    if (self.isUnread) {
        if (handler) {
            [self.chatRoom markMessages:@[self] asReadWithCompletionHandler:^(OBSChatRoom *chatRoom, NSArray *messages, BOOL marked, OBSError *error) {
                handler(self, marked, error);
            }];
        } else {
            [self.chatRoom markMessages:@[self] asReadWithCompletionHandler:nil];
        }
    }
}

@end
