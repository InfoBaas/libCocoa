//
//  OBSRealTimeChannel.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 01/04/14.
//  Copyright (c) 2014 Tiago Rodrigues. All rights reserved.
//

#import "OBSRealTimeChannel+.h"
#import "OBSConnection.h"

static NSString *const _OBSRealTimeChannel_SocketMessageUUID = @"uuid";
static NSString *const _OBSRealTimeChannel_SocketMessageType = @"type";
static NSString *const _OBSRealTimeChannel_SocketMessageAppId = @"appId";
static NSString *const _OBSRealTimeChannel_SocketMessageSessionToken = @"sessionToken";
static NSString *const _OBSRealTimeChannel_SocketMessageData = @"data";

static NSString *const _OBSRealTimeChannel_TypeOK = @"OK";
static NSString *const _OBSRealTimeChannel_TypeNOK = @"NOK";

static NSString *const _OBSRealTimeChannel_TypeAuthenticate = @"AUTHENTICATE";

static NSString *const _OBSRealTimeChannel_TypePing = @"PING";
static NSString *const _OBSRealTimeChannel_TypePong = @"PONG";

static NSString *const _OBSRealTimeChannel_TypeChatMessage = @"RECV_CHAT_MSG";

static NSString *const _OBSRealTimeChannel_DataKey_ErrorMessage = @"errorMessage";

static NSString *const _OBSRealTimeChannel_DataKey_ChatRoomId = @"chatRoomId";
static NSString *const _OBSRealTimeChannel_DataKey_SenderId = @"senderId";
static NSString *const _OBSRealTimeChannel_DataKey_Text = @"text";
static NSString *const _OBSRealTimeChannel_DataKey_ImageBase64 = @"image";

@implementation OBSRealTimeChannel {
    UInt32 _port;
    NSInputStream *_inputStream;
    NSMutableData *_inputBuffer;
    NSOutputStream *_outputStream;
    NSMutableDictionary *_outputBuffer;
    NSMutableArray *_outputQueue;
    NSMutableArray *_outputSentQueue;
    NSMutableDictionary *_messageTargets;
    NSMutableDictionary *_messageOriginals;
    BOOL _isSending;
    unsigned int _openSchedulerIntreval;
}

- (void)setClient:(id<OBSClientProtocol>)client
{
    _client = client;
}

- (id)init
{
    self = [super init];
    if (self) {
        _inputBuffer = [NSMutableData data];
        _outputBuffer = [NSMutableDictionary dictionary];
        _outputQueue = [NSMutableArray array];
        _outputSentQueue = [NSMutableArray array];
        _messageTargets = [NSMutableDictionary dictionary];
        _messageOriginals = [NSMutableDictionary dictionary];
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

- (void)authenticateWithTarget:(id)target
{
    NSDictionary *authenticate = @{_OBSRealTimeChannel_SocketMessageType: _OBSRealTimeChannel_TypeAuthenticate};
    [self _queueData:authenticate withMessageTarget:target originalMessage:nil];
}

#pragma mark Ping

- (void)ping
{
    NSDictionary *ping = @{_OBSRealTimeChannel_SocketMessageType: _OBSRealTimeChannel_TypePing};
    [self _queueData:ping withMessageTarget:nil originalMessage:nil];
}

- (void)pong
{
    NSDictionary *pong = @{_OBSRealTimeChannel_SocketMessageType: _OBSRealTimeChannel_TypePong};
    [self _queueData:pong withMessageTarget:nil originalMessage:nil];
}

#pragma mark Chat

- (NSDictionary *)target:(id)target sendsMessageWithChatId:(NSString *)chatId senderId:(NSString *)senderId text:(NSString *)text
{
    return [self target:target sendsMessageWithChatId:chatId senderId:senderId text:target image:nil];
}

- (NSDictionary *)target:(id)target sendsMessageWithChatId:(NSString *)chatId senderId:(NSString *)senderId text:(NSString *)text image:(UIImage *)image
{
    NSDictionary *message = @{_OBSRealTimeChannel_DataKey_ChatRoomId: chatId,
                              _OBSRealTimeChannel_DataKey_SenderId: senderId,
                              _OBSRealTimeChannel_DataKey_Text: text,
                              _OBSRealTimeChannel_DataKey_ImageBase64: [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:kNilOptions]};
    
    NSDictionary *data = @{_OBSRealTimeChannel_SocketMessageType: _OBSRealTimeChannel_TypeChatMessage,
                           _OBSRealTimeChannel_SocketMessageData: message};
    
    [self _queueData:data withMessageTarget:target originalMessage:message];
    
    return message;
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
                id<OBSRealTimeChannelMessageTarget> target = [_messageTargets objectForKey:uuid];
                if (target) {
                    id message = [_messageOriginals objectForKey:uuid];
                    if (message) {
                        if ([target respondsToSelector:@selector(realTimeChannel:receivedAnOKForMessage:)]) {
                            [target realTimeChannel:self receivedAnOKForMessage:message];
                        }
                    } else {
                        if ([target respondsToSelector:@selector(realTimeChannel:hasBeenAuthenticated:)]) {
                            [target realTimeChannel:self hasBeenAuthenticated:YES];
                        }
                    }
                }
            }
        }
    } else if ([type isEqualToString:_OBSRealTimeChannel_TypeNOK]) {
        if (uuid) {
            @synchronized (_outputBuffer)
            {
                id<OBSRealTimeChannelMessageTarget> target = [_messageTargets objectForKey:uuid];
                if (target) {
                    id message = [_messageOriginals objectForKey:uuid];
                    if (message) {
                        if ([target respondsToSelector:@selector(realTimeChannel:receivedAnErrorMessage:forMessage:)]) {
                            NSDictionary *d = data[_OBSRealTimeChannel_SocketMessageData];
                            NSString *error = d[_OBSRealTimeChannel_DataKey_ErrorMessage];
                            [target realTimeChannel:self receivedAnErrorMessage:error forMessage:message];
                        }
                    } else {
                        if ([target respondsToSelector:@selector(realTimeChannel:hasBeenAuthenticated:)]) {
                            [target realTimeChannel:self hasBeenAuthenticated:NO];
                        }
                    }
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
    } else if ([type isEqualToString:_OBSRealTimeChannel_TypeChatMessage]) {
        BOOL isOK = YES;
        if ([self.client respondsToSelector:@selector(realTimeChannel:receivedMessageWithChatId:senderId:text:image:)]) {
            NSDictionary *message = data[_OBSRealTimeChannel_SocketMessageData];
            NSString *chatId = message[_OBSRealTimeChannel_DataKey_ChatRoomId];
            NSString *senderId = message[_OBSRealTimeChannel_DataKey_SenderId];
            NSString *text = message[_OBSRealTimeChannel_DataKey_Text];
            NSString *image64 = message[_OBSRealTimeChannel_DataKey_ImageBase64];
            UIImage *image = nil;
            if (image64 && [self.client respondsToSelector:@selector(realTimeChannel:receivedMessageWithChatId:senderId:text:image:)]) {
                image = [UIImage imageWithData:[[NSData alloc] initWithBase64EncodedString:image64 options:kNilOptions]];
            }
            isOK = [self.client realTimeChannel:self receivedMessageWithChatId:chatId senderId:senderId text:text image:image];
        }
        if (uuid) {
            NSDictionary *ok = @{_OBSRealTimeChannel_SocketMessageType: isOK ? _OBSRealTimeChannel_TypeOK : _OBSRealTimeChannel_TypeNOK};
            [self _queueData:ok withMessageTarget:nil originalMessage:nil];
        }
        return;
    }
    
    if (uuid) {
        @synchronized (_outputBuffer)
        {
            [_outputSentQueue removeObject:uuid];
            [_outputBuffer removeObjectForKey:uuid];
            [_messageTargets removeObjectForKey:uuid];
            [_messageOriginals removeObjectForKey:uuid];
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
            if ([self.client respondsToSelector:@selector(realTimeChannelOpened:)]) {
                [self.client realTimeChannelOpened:self];
            }
			break;
            
		case NSStreamEventHasBytesAvailable:
            if (aStream == _inputStream) {
                uint8_t buff[1024];
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
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)[OBSConnection OpenBaaSAddress], _port, &readStream, &writeStream);
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
    
    [self _send];
}

- (void)_queueData:(NSDictionary *)data withMessageTarget:(id)target originalMessage:(id)message
{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSMutableDictionary *mut = [data mutableCopy];
    
    mut[_OBSRealTimeChannel_SocketMessageUUID] = uuid;
    mut[_OBSRealTimeChannel_SocketMessageAppId] = [self.client appId];
    
    NSString *session = _obs_settings_get_sessionToken();
    if (session) {
        mut[_OBSRealTimeChannel_SocketMessageSessionToken] = session;
    }
    
    NSData *bin = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil];
    @synchronized (_outputBuffer)
    {
        [_outputBuffer setObject:bin forKey:uuid];
        if (target) {
            [_messageTargets setObject:target forKey:uuid];
            if (message) {
                [_messageOriginals setObject:message forKey:uuid];
            }
        }
        [_outputQueue addObject:uuid];
        [self _send];
    }
}

- (void)_send
{
    @synchronized (_outputBuffer)
    {
        if (!_isSending && [_outputBuffer count]) {
            NSString *uuid = [_outputQueue firstObject];
            NSData *data = [_outputBuffer objectForKey:uuid];
            _isSending = YES;
            if ([_outputStream write:[data bytes] maxLength:[data length]] >= 0) {
                [_outputQueue removeObjectAtIndex:0];
                [_outputSentQueue addObject:uuid];
            }
        }
    }
}

- (void)_close
{
    if (_inputStream) {
        [_inputStream close];
        _inputStream = nil;
    }
    
    if (_outputStream) {
        [_outputStream close];
        _outputStream = nil;
    }
    
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
