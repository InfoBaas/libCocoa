//
//  OBSRealTimeChannel.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 01/04/14.
//  Copyright (c) 2014 Tiago Rodrigues. All rights reserved.
//

#import "OBSRealTimeChannel+.h"
#import "OBSConnection.h"

static NSString *const _OBSRealTimeChannel_SocketMessageType = @"type";

static NSString *const _OBSRealTimeChannel_TypePing = @"PING";
static NSString *const _OBSRealTimeChannel_TypePong = @"PONG";

@implementation OBSRealTimeChannel {
    UInt32 _port;
    NSInputStream *_inputStream;
    NSMutableData *_inputBuffer;
    NSOutputStream *_outputStream;
    NSMutableArray *_outputBuffer;
    BOOL _isSending;
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
        _outputBuffer = [NSMutableArray array];
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

#pragma mark Ping

- (void)ping
{
    NSDictionary *ping = @{_OBSRealTimeChannel_SocketMessageType: _OBSRealTimeChannel_TypePing};
    [self _queueData:ping];
}

- (void)pong
{
    NSDictionary *pong = @{_OBSRealTimeChannel_SocketMessageType: _OBSRealTimeChannel_TypePong};
    [self _queueData:pong];
}

#pragma mark -

- (void)processData:(NSDictionary *)data
{
    NSString *type = data[_OBSRealTimeChannel_SocketMessageType];
    
    if ([type isEqualToString:_OBSRealTimeChannel_TypePing]) {
        if ([self.client respondsToSelector:@selector(realTimeChannelWasPinged:)]) {
            [self.client realTimeChannelWasPinged:self];
        }
        return;
    }
    
    if ([type isEqualToString:_OBSRealTimeChannel_TypePong]) {
        if ([self.client respondsToSelector:@selector(realTimeChannelWasPinged:)]) {
            [self.client realTimeChannelWasPonged:self];
        }
        return;
    }
    
//    if ([type isEqualToString:<#(NSString *)#>]) {
//        <#statements#>
//        return;
//    }
}

#pragma mark NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
			break;
            
		case NSStreamEventOpenCompleted:
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
            }
			break;
            
		case NSStreamEventEndEncountered:
            if (aStream == _inputStream || aStream == _outputStream) {
                [self _close];
                if ([self.client respondsToSelector:@selector(realTimeChannel:closedWithError:)]) {
                    [self.client realTimeChannel:self closedWithError:nil];
                }
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

- (void)_queueData:(NSDictionary *)data;
{
    NSData *bin = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil];
    @synchronized (_outputBuffer)
    {
        [_outputBuffer addObject:bin];
        [self _send];
    }
}

- (void)_send
{
    @synchronized (_outputBuffer)
    {
        if (!_isSending && [_outputBuffer count]) {
            NSData *data = [_outputBuffer firstObject];
            _isSending = YES;
            if ([_outputStream write:[data bytes] maxLength:[data length]] >= 0) {
                [_outputBuffer removeObjectAtIndex:0];
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
}

@end
