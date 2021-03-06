//
//  OBSRealTimeChannel.m
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

#import "OBSRealTimeChannel+.h"
#import "OBSConnection.h"
#import "OBSChatRoom+.h"
#import "OBSApplication+.h"
#import "OBSMedia+.h"
#import "OBSImageFile+.h"
#import "OBSError+.h"

static NSString *const _OBSRealTimeChannel_SocketMessageUUID = @"messageId";
static NSString *const _OBSRealTimeChannel_SocketMessageType = @"type";
static NSString *const _OBSRealTimeChannel_SocketMessageAppId = @"appId";
static NSString *const _OBSRealTimeChannel_SocketMessageSessionToken = @"sessionToken";
static NSString *const _OBSRealTimeChannel_SocketMessageData = @"data";

static NSString *const _OBSRealTimeChannel_TypeOK = @"OK";
static NSString *const _OBSRealTimeChannel_TypeNOK = @"NOK";

static NSString *const _OBSRealTimeChannel_TypeAuthenticate = @"AUTHENTICATE";

static NSString *const _OBSRealTimeChannel_TypePing = @"PING";
static NSString *const _OBSRealTimeChannel_TypePong = @"PONG";

static NSString *const _OBSRealTimeChannel_TypeChatOpenRoom = @"CREATE_CHAT_ROOM";
static NSString *const _OBSRealTimeChannel_TypeSendChatMessage = @"SENT_CHAT_MSG";
static NSString *const _OBSRealTimeChannel_TypeNewChatMessage = @"RECV_CHAT_MSG";

static NSString *const _OBSRealTimeChannel_DataKey_ErrorMessage = @"errorMessage";

static NSString *const _OBSRealTimeChannel_DataKey_ChatRoomId = @"chatRoomId";
static NSString *const _OBSRealTimeChannel_DataKey_Participants = @"participants";
static NSString *const _OBSRealTimeChannel_DataKey_SenderId = @"senderId";
static NSString *const _OBSRealTimeChannel_DataKey_Text = @"text";
static NSString *const _OBSRealTimeChannel_DataKey_ImageBase64 = @"image";
static NSString *const _OBSRealTimeChannel_DataKey_HasImage = @"hasImage";

#define _OBSRTC_ibuffSize       4096

@implementation OBSRealTimeChannel {
    UInt32 _port;
    NSInputStream *_inputStream;
    BOOL _inputStreamOpened;
    NSMutableData *_inputBuffer;
    NSOutputStream *_outputStream;
    BOOL _outputStreamOpened;
    NSMutableDictionary *_outputBuffer;
    NSMutableDictionary *_outputBuffer_messageRooms;
    NSMutableDictionary *_outputBufferLookUp;
    NSMutableArray *_outputQueue;
    NSMutableArray *_outputSentQueue;
    NSMutableDictionary *_messageCompletionHandlers;
    BOOL _isSending;
    unsigned int _openSchedulerIntreval;
    NSMutableData *_outputBufferData;
}

- (id)init
{
    self = [super init];
    if (self) {
        _inputBuffer = [NSMutableData data];
        _outputBuffer = [NSMutableDictionary dictionary];
        _outputBuffer_messageRooms = [NSMutableDictionary dictionary];
        _outputBufferLookUp = [NSMutableDictionary dictionary];
        _outputQueue = [NSMutableArray array];
        _outputSentQueue = [NSMutableArray array];
        _messageCompletionHandlers = [NSMutableDictionary dictionary];
        _outputBufferData = [NSMutableData data];
    }
    return self;
}

+ (OBSRealTimeChannel *)defaultChannel
{
    static OBSRealTimeChannel *channel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        channel = [[self alloc] init];
    });
    return channel;
}

#pragma mark Connection

- (BOOL)connectToPort:(UInt32)port
{
    @synchronized (self)
    {
        _port = port;
        
        if (_inputStream) {
            [_inputStream close];
            _inputStream = nil;
        }
        
        if (_outputStream) {
            [_outputStream close];
            _outputStream = nil;
        }
        
        return [self reconnect];
    }
}

- (BOOL)reconnect
{
    @synchronized (self)
    {
        if (_port) {
            [self _open];
            NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
            [defaultCenter addObserver:self selector:@selector(_applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
            [defaultCenter addObserver:self selector:@selector(_applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        }
        
        return _port != 0;
    }
}

- (void)closeConnection
{
    @synchronized (self)
    {
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        [defaultCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
        [self _close];
    }
}

- (BOOL)isConnected
{
    return _inputStream && _inputStream.streamStatus != NSStreamStatusClosed && _inputStream.streamStatus != NSStreamStatusError
    &&  _outputStream && _outputStream.streamStatus != NSStreamStatusClosed && _outputStream.streamStatus != NSStreamStatusError;
}

#pragma mark Authenticate

- (void)authenticateWithCompletionHandler:(void (^)(BOOL, id, NSString *))handler
{
    NSDictionary *authenticate = @{_OBSRealTimeChannel_SocketMessageType: _OBSRealTimeChannel_TypeAuthenticate};
    [self _queueData:authenticate withCompletionHandler:handler];
}

#pragma mark Ping

- (void)ping
{
    NSDictionary *ping = @{_OBSRealTimeChannel_SocketMessageType: _OBSRealTimeChannel_TypePing};
    [self _queueData:ping withCompletionHandler:nil];
}

- (void)pong
{
    NSDictionary *pong = @{_OBSRealTimeChannel_SocketMessageType: _OBSRealTimeChannel_TypePong};
    [self _queueData:pong withCompletionHandler:nil];
}

#pragma mark Chat

- (void)openChatWithUserIds:(NSArray *)userIds withCompletionHandler:(void (^)(BOOL, id, NSString *))handler
{
    NSDictionary *room = @{_OBSRealTimeChannel_DataKey_Participants: userIds,
                           @"flagNotification": @(YES)};
    
    NSDictionary *data = @{_OBSRealTimeChannel_SocketMessageType: _OBSRealTimeChannel_TypeChatOpenRoom,
                           _OBSRealTimeChannel_SocketMessageData: room};
    
    [self _queueData:data withCompletionHandler:handler];
}

- (void)sendMessageWithChatRoom:(OBSChatRoom *)chatRoom senderId:(NSString *)senderId text:(NSString *)text withCompletionHandler:(void (^)(BOOL, id, NSString *))handler
{
    [self sendMessageWithChatRoom:chatRoom senderId:senderId text:text image:nil withCompletionHandler:handler];
}

- (void)sendMessageWithChatRoom:(OBSChatRoom *)chatRoom senderId:(NSString *)senderId text:(NSString *)text image:(UIImage *)image withCompletionHandler:(void (^)(BOOL, id, NSString *))handler
{
    NSDictionary *message = image
    ? @{_OBSRealTimeChannel_DataKey_ChatRoomId: chatRoom.chatRoomId,
        _OBSRealTimeChannel_DataKey_SenderId: senderId,
        _OBSRealTimeChannel_DataKey_Text: text,
        _OBSRealTimeChannel_DataKey_HasImage: @(YES),
        _OBSRealTimeChannel_DataKey_ImageBase64: [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:kNilOptions]}
    : @{_OBSRealTimeChannel_DataKey_ChatRoomId: chatRoom.chatRoomId,
        _OBSRealTimeChannel_DataKey_SenderId: senderId,
        _OBSRealTimeChannel_DataKey_Text: text,
        _OBSRealTimeChannel_DataKey_HasImage: @(NO)};
    
    NSDictionary *data = @{_OBSRealTimeChannel_SocketMessageType: _OBSRealTimeChannel_TypeSendChatMessage,
                           _OBSRealTimeChannel_SocketMessageData: message};
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSMutableDictionary *mut = [data mutableCopy];
    
    mut[_OBSRealTimeChannel_SocketMessageUUID] = uuid;
    mut[_OBSRealTimeChannel_SocketMessageAppId] = [self.client appId];
    
    NSString *session = _obs_settings_get_sessionToken();
    if (session) {
        mut[_OBSRealTimeChannel_SocketMessageSessionToken] = session;
    }
    
    NSMutableData *bin = [[NSJSONSerialization dataWithJSONObject:mut options:kNilOptions error:nil] mutableCopy];
    [bin appendData:[@"\0" dataUsingEncoding:NSUTF8StringEncoding]];
    @synchronized (_outputBuffer)
    {
        [_outputBuffer_messageRooms setObject:chatRoom forKey:uuid];
        [_outputBuffer setObject:bin forKey:uuid];
        [_outputBufferLookUp setObject:data[_OBSRealTimeChannel_SocketMessageType] forKey:uuid];
        if (handler) {
            [_messageCompletionHandlers setObject:handler forKey:uuid];
        }
        [_outputQueue addObject:uuid];
        [self _send];
    }
}

- (void)postMessageWithChatRoom:(OBSChatRoom *)chatRoom senderId:(NSString *)senderId text:(NSString *)text image:(UIImage *)image withCompletionHandler:(void (^)(BOOL, id, NSString *))handler andImageCompletionHandler:(void (^)(BOOL, UIImage *, OBSImageFile *, OBSError *))ihandler
{
    void (^inner)(BOOL, id, NSString *) = ^(BOOL ok, id result, NSString *errorMessage) {
        handler(ok, result, errorMessage);
        if (ok && image) {
            OBSApplication *app = [OBSApplication applicationWithClient:chatRoom.client];
            OBSMedia *media = [app applicationMedia];
            OBSChatMessage *msg = result;
            [OBSConnection post_media:media image:image forMessage:msg withFileName:@"InthebeginningMancreatedgod" queryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!ihandler)
                    return;
                
                // Called with error?
                if (error) {
                    ihandler(NO, image, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }
                
                // Create image file.
                OBSImageFile *imageFile = nil;
                if ([result isKindOfClass:[NSDictionary class]]) {
                    imageFile = [OBSImageFile imageFileFromDataJSON:result[OBSConnectionResultDataKey] andMetadataJSON:result[OBSConnectionResultMetadataKey] withClient:self.client];
                }
                if (!imageFile) {
                    // Image file wasn't created.
                    ihandler(NO, image, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                    return;
                }
                
                ihandler(YES, image, imageFile, nil);
            }];
        }
    };
    
    NSDictionary *message =  @{_OBSRealTimeChannel_DataKey_ChatRoomId: chatRoom.chatRoomId,
                               _OBSRealTimeChannel_DataKey_SenderId: senderId,
                               _OBSRealTimeChannel_DataKey_Text: text,
                               _OBSRealTimeChannel_DataKey_HasImage: @(image!=nil)};
    
    NSDictionary *data = @{_OBSRealTimeChannel_SocketMessageType: _OBSRealTimeChannel_TypeSendChatMessage,
                           _OBSRealTimeChannel_SocketMessageData: message};
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSMutableDictionary *mut = [data mutableCopy];
    
    mut[_OBSRealTimeChannel_SocketMessageUUID] = uuid;
    mut[_OBSRealTimeChannel_SocketMessageAppId] = [self.client appId];
    
    NSString *session = _obs_settings_get_sessionToken();
    if (session) {
        mut[_OBSRealTimeChannel_SocketMessageSessionToken] = session;
    }
    
    NSMutableData *bin = [[NSJSONSerialization dataWithJSONObject:mut options:kNilOptions error:nil] mutableCopy];
    [bin appendData:[@"\0" dataUsingEncoding:NSUTF8StringEncoding]];
    @synchronized (_outputBuffer)
    {
        [_outputBuffer_messageRooms setObject:chatRoom forKey:uuid];
        [_outputBuffer setObject:bin forKey:uuid];
        [_outputBufferLookUp setObject:data[_OBSRealTimeChannel_SocketMessageType] forKey:uuid];
        if (handler) {
            [_messageCompletionHandlers setObject:inner forKey:uuid];
        }
        [_outputQueue addObject:uuid];
        [self _send];
    }
}

#pragma mark -

- (void)processData:(NSDictionary *)data
{
    NSString *uuid = data[_OBSRealTimeChannel_SocketMessageUUID];
    NSString *type = data[_OBSRealTimeChannel_SocketMessageType];
    
    if ([type isEqualToString:_OBSRealTimeChannel_TypeOK]) {
        if (uuid) {
            @synchronized (_outputBuffer)
            {
                void (^handler)(BOOL, id, NSString *) = [_messageCompletionHandlers objectForKey:uuid];
                if (handler) {
                    NSString *originalType = [_outputBufferLookUp objectForKey:uuid];
                    if ([originalType isEqualToString:_OBSRealTimeChannel_TypeChatOpenRoom]) {
                        NSDictionary *chatRoomData = data[_OBSRealTimeChannel_SocketMessageData];
                        OBSChatRoom *chatRoom = [OBSChatRoom chatRoomFromDataJSON:chatRoomData andMetadataJSON:nil withClient:self.client];
                        
                        handler(chatRoom != nil, chatRoom, nil);
                    } else if ([originalType isEqualToString:_OBSRealTimeChannel_TypeSendChatMessage]) {
                        OBSChatRoom *chatRoom = [_outputBuffer_messageRooms objectForKey:uuid];
                        
                        NSDictionary *chatMessageData = data[_OBSRealTimeChannel_SocketMessageData];
                        OBSChatMessage *chatMessage = [OBSChatMessage chatMessageInRoom:chatRoom fromDataJSON:chatMessageData andMetadataJSON:nil];
                        
                        handler(chatMessage != nil, chatMessage, nil);
                    } else {
                        handler(YES, nil, nil);
                    }
                }
            }
        }
    } else if ([type isEqualToString:_OBSRealTimeChannel_TypeNOK]) {
        if (uuid) {
            @synchronized (_outputBuffer)
            {
                void (^handler)(BOOL, id, NSString *) = [_messageCompletionHandlers objectForKey:uuid];
                if (handler) {
                    NSDictionary *d = data[_OBSRealTimeChannel_SocketMessageData];
                    NSString *error = d[_OBSRealTimeChannel_DataKey_ErrorMessage];
                    handler(NO, nil, error);
                }
            }
        }
    } else if ([type isEqualToString:_OBSRealTimeChannel_TypePing]) {
        if ([self.client respondsToSelector:@selector(realTimeChannelWasPinged:)]) {
            [self.client realTimeChannelWasPinged:self];
        }
    } else if ([type isEqualToString:_OBSRealTimeChannel_TypePong]) {
        if ([self.client respondsToSelector:@selector(realTimeChannelWasPonged:)]) {
            [self.client realTimeChannelWasPonged:self];
        }
    } else if ([type isEqualToString:_OBSRealTimeChannel_TypeNewChatMessage]) {
        if ([self.client respondsToSelector:@selector(realTimeChannel:receivedMessage:completionHandler:)]) {
            NSDictionary *message = data[_OBSRealTimeChannel_SocketMessageData];
            
            NSDictionary *chatRoomData = message[@"chatRoom"];
            OBSChatRoom *chatRoom = [OBSChatRoom chatRoomFromDataJSON:chatRoomData andMetadataJSON:nil withClient:self.client];
            
            NSDictionary *chatMessageData = message[@"message"];
            OBSChatMessage *chatMessage = [OBSChatMessage chatMessageInRoom:chatRoom fromDataJSON:chatMessageData andMetadataJSON:nil];
            
            if (uuid) {
                [self.client realTimeChannel:self receivedMessage:chatMessage completionHandler:^(BOOL isOK) {
                    NSDictionary *ok = @{_OBSRealTimeChannel_SocketMessageType: isOK ? _OBSRealTimeChannel_TypeOK : _OBSRealTimeChannel_TypeNOK};
                    [self _queueData:ok withCompletionHandler:nil];
                }];
            } else {
                [self.client realTimeChannel:self receivedMessage:chatMessage completionHandler:nil];
            }
        }
        return;
    }
    
    if (uuid) {
        @synchronized (_outputBuffer)
        {
            if ([_outputBuffer objectForKey:uuid]) {
                // sent by me
                [_outputSentQueue removeObject:uuid];
                [_outputBuffer removeObjectForKey:uuid];
                [_outputBufferLookUp removeObjectForKey:uuid];
                [_messageCompletionHandlers removeObjectForKey:uuid];
                [_outputBuffer_messageRooms removeObjectForKey:uuid];
            } else {
                // sent to me
                NSDictionary *ok = @{_OBSRealTimeChannel_SocketMessageType: _OBSRealTimeChannel_TypeOK};
                [self _queueData:ok withCompletionHandler:nil];
            }
        }
    }
}

#pragma mark NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
			break;
            
		case NSStreamEventOpenCompleted:
            _openSchedulerIntreval = 0;
            
            if (aStream == _inputStream) {
                _inputStreamOpened = YES;
            } else if (aStream == _outputStream) {
                _outputStreamOpened = YES;
            }
            
            if (_inputStreamOpened && _outputStreamOpened && [self.client respondsToSelector:@selector(realTimeChannelOpened:)]) {
                [self.client realTimeChannelOpened:self];
                [self _send];
            }
			break;
            
		case NSStreamEventHasBytesAvailable:
            if (aStream == _inputStream) {
                uint8_t buff[_OBSRTC_ibuffSize];
                NSUInteger len;
                
                len = [_inputStream read:buff maxLength:sizeof(buff)];
                if (len > 0) {
                    [_inputBuffer appendBytes:buff length:len];
                }
                
                if (![_inputStream hasBytesAvailable]) {
                    NSError *error = nil;
                    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:_inputBuffer options:kNilOptions error:&error];
                    if (error) {
                        [self _close];
                        if ([self.client respondsToSelector:@selector(realTimeChannel:closedWithError:)]) {
                            [self.client realTimeChannel:self closedWithError:error];
                        }
                    } else {
                        [self processData:data];
                        [_inputBuffer setData:[NSData data]];
                    }
                }
            }
			break;
            
        case NSStreamEventHasSpaceAvailable:
            if (aStream == _outputStream) {
                _isSending = NO;
                [self _send];
            }
            break;
            
		case NSStreamEventErrorOccurred:
            if (aStream == _inputStream || aStream == _outputStream) {
                [self _close];
                if ([self.client respondsToSelector:@selector(realTimeChannel:closedWithError:)]) {
                    [self.client realTimeChannel:self closedWithError:aStream.streamError];
                }
                [self _scheduledOpen];
            }
			break;
            
		case NSStreamEventEndEncountered:
            if (aStream == _inputStream || aStream == _outputStream) {
                [self _close];
                if ([self.client respondsToSelector:@selector(realTimeChannel:closedWithError:)]) {
                    [self.client realTimeChannel:self closedWithError:nil];
                }
                [self _scheduledOpen];
            }
			break;
            
		default:
			NSLog(@"Unknown event!");
	}
}

#pragma mark Internals

- (void)_applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    @synchronized (self)
    {
        [self _close];
    }
}

- (void)_applicationWillEnterForegroundNotification:(NSNotification *)notification
{
    @synchronized (self)
    {
        [self _open];
    }
}

- (void)_open
{
    if (!_port) return;
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)[OBSConnection OpenBaaSTCPAddress], _port, &readStream, &writeStream);
    NSInputStream *inputStream = (__bridge NSInputStream *)readStream;
    NSOutputStream *outputStream = (__bridge NSOutputStream *)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    _inputStream = inputStream;
    _outputStream = outputStream;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
        
        [inputStream scheduleInRunLoop:currentRunLoop forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:currentRunLoop forMode:NSDefaultRunLoopMode];
        
        [inputStream open];
        [outputStream open];
        
        [currentRunLoop run];
    });
}

- (void)_queueData:(NSDictionary *)data withCompletionHandler:(void (^)(BOOL, id, NSString *))handler
{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSMutableDictionary *mut = [data mutableCopy];
    
    mut[_OBSRealTimeChannel_SocketMessageUUID] = uuid;
    mut[_OBSRealTimeChannel_SocketMessageAppId] = [self.client appId];
    
    NSString *session = _obs_settings_get_sessionToken();
    if (session) {
        mut[_OBSRealTimeChannel_SocketMessageSessionToken] = session;
    }
    
    NSMutableData *bin = [[NSJSONSerialization dataWithJSONObject:mut options:kNilOptions error:nil] mutableCopy];
    [bin appendData:[@"\0" dataUsingEncoding:NSUTF8StringEncoding]];
    @synchronized (_outputBuffer)
    {
        [_outputBuffer setObject:bin forKey:uuid];
        [_outputBufferLookUp setObject:data[_OBSRealTimeChannel_SocketMessageType] forKey:uuid];
        if (handler) {
            [_messageCompletionHandlers setObject:handler forKey:uuid];
        }
        [_outputQueue addObject:uuid];
        [self _send];
    }
}

- (void)_send
{
    @synchronized (_outputBuffer)
    {
        if (_inputStreamOpened && _outputStreamOpened && !_isSending && [_outputStream hasSpaceAvailable]) {
            if ([_outputBufferData length]) {
                _isSending = YES;
                NSInteger sent = [_outputStream write:[_outputBufferData bytes] maxLength:[_outputBufferData length]];
                if (sent >= 0) {
                    [_outputBufferData replaceBytesInRange:NSMakeRange(0, sent) withBytes:NULL length:0];
                }
            } else {
                if ([_outputQueue count]) {
                    NSString *uuid = [_outputQueue firstObject];
                    NSData *data = [_outputBuffer objectForKey:uuid];
                    [_outputBufferData appendData:data];
                    [_outputQueue removeObjectAtIndex:0];
                    [_outputSentQueue addObject:uuid];
                    [self _send];
                }
            }
        }
    }
}

- (void)_close
{
    [_inputBuffer setData:[NSData data]];
    
    if (_inputStream) {
        [_inputStream close];
        _inputStream = nil;
    }
    
    if (_outputStream) {
        [_outputStream close];
        _outputStream = nil;
    }
    
    _inputStreamOpened = _outputStreamOpened = NO;
    
    @synchronized (_outputBuffer)
    {
        NSUInteger i = [_outputSentQueue count];
        while (i > 0) {
            [_outputQueue insertObject:[_outputSentQueue objectAtIndex:(--i)] atIndex:0];
        }
    }
}

- (void)_scheduledOpen
{
    switch (_openSchedulerIntreval) {
        case 0:
            _openSchedulerIntreval = 1;
            break;
        case 1:
            _openSchedulerIntreval = 3;
            break;
        case 3:
            _openSchedulerIntreval = 5;
            break;
        case 5:
            _openSchedulerIntreval = 10;
            break;
        default:
            break;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_openSchedulerIntreval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _open];
    });
}

@end
