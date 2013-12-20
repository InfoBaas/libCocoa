//
//  OBSConnection.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 31/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSConnection.h"

#import "OBSLocationCentre+.h"

#import "OBSAccount+.h"
#import "OBSApplication+.h"
#import "OBSSession+.h"
#import "OBSUser+.h"

NSString *const OBSConnectionResultDataKey = @"data";
NSString *const OBSConnectionResultMetadataKey = @"metadata";

@interface OBSConnection () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

+ (NSString *)queryStringFromParametersDictionary:(NSDictionary *)parameters;
+ (NSURL *)urlWithAddress:(NSString *)address andQueryParametersDictionary:(NSDictionary *)queryDictionary;

+ (void)setAppKeyHeaderField:(NSString *)appKey toRequest:(NSMutableURLRequest *)request;
+ (void)setCurrentLocationHeaderFieldToRequest:(NSMutableURLRequest *)request;
+ (void)setCurrentSessionHeaderFieldToRequest:(NSMutableURLRequest *)request;

+ (NSError *)errorWithResponse:(NSURLResponse *)response andData:(NSData *)data;
+ (void(^)(NSURLResponse *, NSData *, NSError *))innerHandlerWithOuterHandler:(void(^)(id, NSInteger statusCode, NSError *))handler;

#pragma mark NSURLConnection Delegation

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) void(^handler)(NSURLResponse*,NSData*,NSError*);
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSError *error;

@end

static NSString *const _OBSRequestHeaderAppKey = @"appKey";
static NSString *const _OBSRequestHeaderLocation = @"location";
static NSString *const _OBSRequestHeaderSessionToken = @"sessionToken";

static NSMutableSet *_OBSOpenConnections (void)
{
    static NSMutableSet *set = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        set = [NSMutableSet set];
    });
    return set;
}

#pragma mark -

@implementation OBSConnection

+ (NSString *)OpenBaaSAddress
{
    static NSString *address = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        address = [[NSBundle mainBundle] objectForInfoDictionaryKey:OBSConfigURL];
        NSAssert(address, @"\"%@\" key not found in bundle's info dictionary.", OBSConfigURL);
    });
    return address;
}

+ (void)sendAsynchronousRequest:(NSURLRequest *)request
                          queue:(NSOperationQueue *)queue
              completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler
{
    OBSConnection *connection = [self new];

    connection.request = request;
    connection.queue = queue;
    connection.handler = handler;

    connection.data = nil;
    connection.response = nil;

    NSMutableSet *set = _OBSOpenConnections();
    @synchronized (set) {
        [set addObject:connection];
    }

    connection.connection = [[NSURLConnection alloc] initWithRequest:request delegate:connection startImmediately:NO];
    [connection.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [connection.connection start];
}

#pragma mark NSURLConnection Delegation

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (connection == self.connection) {
        [self.queue addOperationWithBlock:^{
            self.handler(nil,nil,error);
        }];
        NSMutableSet *set = _OBSOpenConnections();
        @synchronized (set) {
            [set removeObject:self];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection == self.connection) {
        self.data = [NSMutableData data];
        self.response = response;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == self.connection) {
        [self.data appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == self.connection) {
        [self.queue addOperationWithBlock:^{
            self.handler(self.response,[NSData dataWithData:self.data],nil);
        }];
        NSMutableSet *set = _OBSOpenConnections();
        @synchronized (set) {
            [set removeObject:self];
        }
    }
}

#pragma mark Extension

+ (NSString *)queryStringFromParametersDictionary:(NSDictionary *)parameters
{
    if (!parameters) {
        return nil;
    }

    NSMutableArray *query = [NSMutableArray array];
    for (NSString *param in parameters) {
        NSString *value = [parameters[param] description];
        [query addObject:[NSString stringWithFormat:@"%@=%@", param, [value obs_stringByAddingPercentEscapes]]];
    }
    return [query componentsJoinedByString:@"&"];
}

+ (NSURL *)urlWithAddress:(NSString *)address andQueryParametersDictionary:(NSDictionary *)queryDictionary
{
    if (!address) return nil;
    NSString *query = [self queryStringFromParametersDictionary:queryDictionary];
    NSString *url = query ? [NSString stringWithFormat:@"%@?%@", address, query] : address;
    return [NSURL URLWithString:url];
}

+ (void)setAppKeyHeaderField:(NSString *)appKey toRequest:(NSMutableURLRequest *)request
{
    if (appKey) {
        [request setValue:appKey forHTTPHeaderField:_OBSRequestHeaderAppKey];
    }
}

+ (void)setCurrentLocationHeaderFieldToRequest:(NSMutableURLRequest *)request
{
    CLLocation *location = [OBSLocationCentre currentLocation];
    if (location) {
        CLLocationCoordinate2D coordinate = [location coordinate];
        NSString *value = [NSString stringWithFormat:@"%lf:%lf", coordinate.latitude, coordinate.longitude];
        [request setValue:value forHTTPHeaderField:_OBSRequestHeaderLocation];
    }
}

+ (void)setCurrentSessionHeaderFieldToRequest:(NSMutableURLRequest *)request
{
    NSString *session = _obs_settings_get_sessionToken();
    if (session) {
        [request setValue:session forHTTPHeaderField:_OBSRequestHeaderSessionToken];
    }
}

+ (NSError *)errorWithResponse:(NSURLResponse *)response andData:(NSData *)data
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger statusCode = httpResponse.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
        return nil;
    }

    NSError *error = nil;
    switch (statusCode) {
#warning TODO more errors (not yet stable on the server side)
        default:
            error = [NSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeUnknown userInfo:nil];
            break;
    }
    return error;
}

+ (void (^)(NSURLResponse *, NSData *, NSError *))innerHandlerWithOuterHandler:(void (^)(id, NSInteger statusCode, NSError *))handler
{
    if (!handler)
        return nil;
    return ^(NSURLResponse *response, NSData *data, NSError *error) {
        id result = nil;
        if (data) {
            error = [self errorWithResponse:response andData:data];
            if (!error) {
                if ([data length]) {
                    result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                } else {
                    result = [NSNull null];
                }
            }
        }
        handler(result, [((NSHTTPURLResponse*)response) statusCode], error);
    };
}

@end

#pragma mark - GET

@implementation OBSConnection (GET)

+ (NSMutableURLRequest *)get_requestForURL:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return request;
}

#pragma mark apps/<appid>/account

+ (void)get_accountSessionWithToken:(NSString *)sessionToken client:(id<OBSClientProtocol>)client queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Address
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/sessions", [self OpenBaaSAddress], [client appId]];

        // Request
        NSURL *url = [self urlWithAddress:address andQueryParametersDictionary:query];
        NSMutableURLRequest *request = [self get_requestForURL:url];

        // Header
        [self setAppKeyHeaderField:[client appKey] toRequest:request];
        [self setCurrentLocationHeaderFieldToRequest:request];
        [request setValue:sessionToken forHTTPHeaderField:_OBSRequestHeaderSessionToken];

        // Send
        [self sendAsynchronousRequest:request
                                queue:[NSOperationQueue new]
                    completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

#pragma mark apps/<appid>/users

+ (void)get_application:(OBSApplication *)application usersWithQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Address
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/users", [self OpenBaaSAddress], [application applicationId]];

        // Request
        NSURL *url = [self urlWithAddress:address andQueryParametersDictionary:query];
        NSMutableURLRequest *request = [self get_requestForURL:url];

        // Header
        [self setAppKeyHeaderField:[application applicationKey] toRequest:request];
        [self setCurrentLocationHeaderFieldToRequest:request];
        [self setCurrentSessionHeaderFieldToRequest:request];

        // Send
        [self sendAsynchronousRequest:request
                                queue:[NSOperationQueue new]
                    completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

+ (void)get_application:(OBSApplication *)application userWithId:(NSString *)userId queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Address
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/users/%@", [self OpenBaaSAddress], [application applicationId], userId];

        // Request
        NSURL *url = [self urlWithAddress:address andQueryParametersDictionary:query];
        NSMutableURLRequest *request = [self get_requestForURL:url];

        // Header
        [self setAppKeyHeaderField:[application applicationKey] toRequest:request];
        [self setCurrentLocationHeaderFieldToRequest:request];
        [self setCurrentSessionHeaderFieldToRequest:request];

        // Send
        [self sendAsynchronousRequest:request
                                queue:[NSOperationQueue new]
                    completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

#pragma mark apps/<appid>/media/images

+ (void)get_media:(OBSMedia *)media imageFilesWithQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Address
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/media/images", [self OpenBaaSAddress], [[media client] appId]];

        // Request
        NSURL *url = [self urlWithAddress:address andQueryParametersDictionary:query];
        NSMutableURLRequest *request = [self get_requestForURL:url];

        // Header
        [self setAppKeyHeaderField:[[media client] appKey] toRequest:request];
        [self setCurrentLocationHeaderFieldToRequest:request];
        [self setCurrentSessionHeaderFieldToRequest:request];

        // Send
        [self sendAsynchronousRequest:request
                                queue:[NSOperationQueue new]
                    completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

+ (void)get_media:(OBSMedia *)media imageFileWithId:(NSString *)imageFileId queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Address
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/media/images/%@", [self OpenBaaSAddress], [[media client] appId], imageFileId];

        // Request
        NSURL *url = [self urlWithAddress:address andQueryParametersDictionary:query];
        NSMutableURLRequest *request = [self get_requestForURL:url];

        // Header
        [self setAppKeyHeaderField:[[media client] appKey] toRequest:request];
        [self setCurrentLocationHeaderFieldToRequest:request];
        [self setCurrentSessionHeaderFieldToRequest:request];

        // Send
        [self sendAsynchronousRequest:request
                                queue:[NSOperationQueue new]
                    completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

+ (void)get_imageFile:(OBSImageFile *)imageFile imageSize:(NSString *)imageSize queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Address
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/media/images/%@/%@/download", [self OpenBaaSAddress], [[imageFile client] appId], imageFile.mediaId, imageSize];

        // Request
        NSURL *url = [self urlWithAddress:address andQueryParametersDictionary:query];
        NSMutableURLRequest *request = [self get_requestForURL:url];

        // Header
        [self setAppKeyHeaderField:[[imageFile client] appKey] toRequest:request];
        [self setCurrentLocationHeaderFieldToRequest:request];
        [self setCurrentSessionHeaderFieldToRequest:request];

        // Send
        [self sendAsynchronousRequest:request
                                queue:[NSOperationQueue new]
                    completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                        id result = nil;
                        if (data) {
                            error = [self errorWithResponse:response andData:data];
                            if (!error) {
                                if ([data length]) {
                                    result = data;
                                } else {
                                    result = [NSNull null];
                                }
                            }
                        }
                        handler(result, [((NSHTTPURLResponse*)response) statusCode], error);
                    }];
    });
}

@end

#pragma mark - POST

@implementation OBSConnection (POST)

+ (NSMutableURLRequest *)post_requestForURL:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return request;
}

+ (void)post_account:(OBSAccount *)account signUpWithEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id, NSInteger statusCode, NSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Address
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/signup", [self OpenBaaSAddress], [[account client] appId]];

        // Body
        NSMutableDictionary *body = [NSMutableDictionary dictionaryWithObjectsAndKeys:email, @"email", password, @"password", nil];
        if (userName) body[@"userName"] = userName;
        if (userFile) body[@"userFile"] = userFile;

        // Request
        NSURL *url = [self urlWithAddress:address andQueryParametersDictionary:query];
        NSMutableURLRequest *request = [self post_requestForURL:url];

        NSError *error = nil;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error]];
        if (error) {
            handler(nil, 0, error);
            return;
        }

        // Header
        [self setAppKeyHeaderField:[[account client] appKey] toRequest:request];
        [self setCurrentLocationHeaderFieldToRequest:request];

        // Send
        [self sendAsynchronousRequest:request
                                queue:[NSOperationQueue new]
                    completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

+ (void)post_account:(OBSAccount *)account signInWithEmail:(NSString *)email password:(NSString *)password queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id, NSInteger statusCode, NSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Address
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/signin", [self OpenBaaSAddress], [[account client] appId]];

        // Body
        NSDictionary *body = @{@"email": email,
                               @"password": password};

        // Request
        NSURL *url = [self urlWithAddress:address andQueryParametersDictionary:query];
        NSMutableURLRequest *request = [self post_requestForURL:url];

        NSError *error = nil;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error]];
        if (error) {
            handler(nil, 0, error);
            return;
        }

        // Header
        [self setAppKeyHeaderField:[[account client] appKey] toRequest:request];
        [self setCurrentLocationHeaderFieldToRequest:request];

        // Send
        [self sendAsynchronousRequest:request
                                queue:[NSOperationQueue new]
                    completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

+ (void)post_account:(OBSAccount *)account signOutWithSession:(OBSSession *)session all:(BOOL)all queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id, NSInteger statusCode, NSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Address
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/signout", [self OpenBaaSAddress], [[account client] appId]];

        // Body
        NSDictionary *body = @{@"all": [NSNumber numberWithBool:all]};

        // Request
        NSURL *url = [self urlWithAddress:address andQueryParametersDictionary:query];
        NSMutableURLRequest *request = [self post_requestForURL:url];

        NSError *error = nil;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error]];
        if (error) {
            handler(nil, 0, error);
            return;
        }

        // Header
        [self setAppKeyHeaderField:[[account client] appKey] toRequest:request];
        [self setCurrentLocationHeaderFieldToRequest:request];
        if (session) {
            [request setValue:[session token] forHTTPHeaderField:_OBSRequestHeaderSessionToken];
        } else {
            [self setCurrentSessionHeaderFieldToRequest:request];
        }

        // Send
        [self sendAsynchronousRequest:request
                                queue:[NSOperationQueue new]
                    completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

+ (void)post_account:(OBSAccount *)account recoveryWithEmail:(NSString *)email queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id, NSInteger statusCode, NSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Address
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/recovery", [self OpenBaaSAddress], [[account client] appId]];

        // Body
        NSDictionary *body = @{@"email": email};

        // Request
        NSURL *url = [self urlWithAddress:address andQueryParametersDictionary:query];
        NSMutableURLRequest *request = [self post_requestForURL:url];

        NSError *error = nil;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error]];
        if (error) {
            handler(nil, 0, error);
            return;
        }

        // Header
        [self setAppKeyHeaderField:[[account client] appKey] toRequest:request];

        // Send
        [self sendAsynchronousRequest:request
                                queue:[NSOperationQueue new]
                    completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

+ (void)post_account:(OBSAccount *)account integrationFacebookWithOAuthToken:(NSString *)oauthToken queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Address
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/integration/facebook", [self OpenBaaSAddress], [[account client] appId]];

        // Body
        NSDictionary *body = @{@"fbToken": oauthToken};

        // Request
        NSURL *url = [self urlWithAddress:address andQueryParametersDictionary:query];
        NSMutableURLRequest *request = [self post_requestForURL:url];

        NSError *error = nil;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error]];
        if (error) {
            handler(nil, 0, error);
            return;
        }

        // Header
        [self setAppKeyHeaderField:[[account client] appKey] toRequest:request];
        [self setCurrentLocationHeaderFieldToRequest:request];

        // Send
        [self sendAsynchronousRequest:request
                                queue:[NSOperationQueue new]
                    completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

#pragma mark apps/<appid>/media/images

#if TARGET_OS_IPHONE
+ (void)post_media:(OBSMedia *)media image:(UIImage *)image withFileName:(NSString *)fileName queryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler
#endif
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Address
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/media/images", [self OpenBaaSAddress], [[media client] appId]];

        // Auxiliaries
        NSString *boundary = @"---p37mbyk1q2m164obqcjj-OpenBaaS-libCocoa-";
        NSString *contentType = [NSString stringWithFormat:
                                 @"multipart/form-data; boundary=%@",boundary];

        // Body
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@.png\"\r\nContent-Type: application/octet-stream\r\n\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
#if TARGET_OS_IPHONE
        [body appendData:UIImagePNGRepresentation(image)];
#endif
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

        // Request
        NSURL *url = [self urlWithAddress:address andQueryParametersDictionary:query];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[NSData dataWithData:body]];

        // Header
        [self setAppKeyHeaderField:[[media client] appKey] toRequest:request];
        [self setCurrentLocationHeaderFieldToRequest:request];
        [self setCurrentSessionHeaderFieldToRequest:request];

        // Send
        [self sendAsynchronousRequest:request
                                queue:[NSOperationQueue new]
                    completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

@end

#pragma mark - PATCH

@implementation OBSConnection (PATCH)

+ (NSMutableURLRequest *)patch_requestForURL:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PATCH"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return request;
}

#pragma mark apps/<appid>/account

+ (void)patch_session:(OBSSession *)session withQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(id result, NSInteger statusCode, NSError *error))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Address
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/session", [self OpenBaaSAddress], [[session client] appId]];

        // Request
        NSURL *url = [self urlWithAddress:address andQueryParametersDictionary:query];
        NSMutableURLRequest *request = [self get_requestForURL:url];

        // Header
        [self setAppKeyHeaderField:[[session client] appKey] toRequest:request];
        [self setCurrentLocationHeaderFieldToRequest:request];
        [request setValue:[session token] forHTTPHeaderField:_OBSRequestHeaderSessionToken];

        // Send
        [self sendAsynchronousRequest:request
                                queue:[NSOperationQueue new]
                    completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

@end
