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

NSString *const OBSConnectionResultDataKey = @"data";
NSString *const OBSConnectionResultMetadataKey = @"metadata";

@interface OBSConnection ()

+ (void)setCurrentLocationHeaderFieldToRequest:(NSMutableURLRequest *)request;

+ (NSError *)errorWithResponse:(NSURLResponse *)response andData:(NSData *)data;
+ (void(^)(NSURLResponse *, NSData *, NSError *))innerHandlerWithOuterHandler:(void(^)(id, NSError *))handler;

@end

static NSString *const _OBSRequestHeaderSessionToken = @"sessionToken";
static NSString *const _OBSRequestHeaderLocation = @"location";

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

#pragma mark Extension

+ (void)setCurrentLocationHeaderFieldToRequest:(NSMutableURLRequest *)request
{
    CLLocation *location = [OBSLocationCentre currentLocation];
    if (location) {
        CLLocationCoordinate2D coordinate = [location coordinate];
        NSString *value = [NSString stringWithFormat:@"%lf:%lf", coordinate.latitude, coordinate.longitude];
        [request setValue:value forHTTPHeaderField:_OBSRequestHeaderLocation];
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

+ (void (^)(NSURLResponse *, NSData *, NSError *))innerHandlerWithOuterHandler:(void (^)(id, NSError *))handler
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
        handler(result, error);
    };
}

@end

#pragma mark - GET

@implementation OBSConnection (GET)

+ (NSMutableURLRequest *)get_requestForAddress:(NSString *)address
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:address]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return request;
}

#pragma mark apps/<appid>/account

+ (void)get_accountSessionWithToken:(NSString *)sessionToken client:(id<OBSClientProtocol>)client completionHandler:(void (^)(id result, NSError *error))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/session", [self OpenBaaSAddress], [client appId]];
        NSMutableURLRequest *request = [self get_requestForAddress:address];
        [self setCurrentLocationHeaderFieldToRequest:request];
        [request setValue:sessionToken forHTTPHeaderField:_OBSRequestHeaderSessionToken];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue new]
                               completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

@end

#pragma mark - POST

@implementation OBSConnection (POST)

+ (NSMutableURLRequest *)post_requestForAddress:(NSString *)address
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:address]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return request;
}

+ (void)post_account:(OBSAccount *)account signUpWithEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile completionHandler:(void (^)(id, NSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/signup", [self OpenBaaSAddress], [[account client] appId]];
        NSMutableDictionary *body = [NSMutableDictionary dictionaryWithObjectsAndKeys:email, @"email", password, @"password", nil];
        if (userName) body[@"userName"] = userName;
        if (userFile) body[@"userFile"] = userFile;

        NSMutableURLRequest *request = [self post_requestForAddress:address];

        NSError *error = nil;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error]];
        if (error) {
            handler(nil, error);
            return;
        }

        [self setCurrentLocationHeaderFieldToRequest:request];

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue new]
                               completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

+ (void)post_account:(OBSAccount *)account signInWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(id, NSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/signin", [self OpenBaaSAddress], [[account client] appId]];
        NSDictionary *body = @{@"email": email,
                               @"password": password};

        NSMutableURLRequest *request = [self post_requestForAddress:address];

        NSError *error = nil;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error]];
        if (error) {
            handler(nil, error);
            return;
        }

        [self setCurrentLocationHeaderFieldToRequest:request];

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue new]
                               completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

+ (void)post_accountSignOutWithSession:(OBSSession *)session all:(BOOL)all completionHandler:(void (^)(id, NSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/signout", [self OpenBaaSAddress], [[session client] appId]];
        NSDictionary *body = @{@"all": [NSNumber numberWithBool:all]};

        NSMutableURLRequest *request = [self post_requestForAddress:address];

        NSError *error = nil;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error]];
        if (error) {
            handler(nil, error);
            return;
        }

        [self setCurrentLocationHeaderFieldToRequest:request];
        [request setValue:[session token] forHTTPHeaderField:_OBSRequestHeaderSessionToken];

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue new]
                               completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

+ (void)post_account:(OBSAccount *)account recoveryWithEmail:(NSString *)email completionHandler:(void (^)(id, NSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/recovery", [self OpenBaaSAddress], [[account client] appId]];
        NSDictionary *body = @{@"email": email};

        NSMutableURLRequest *request = [self post_requestForAddress:address];

        NSError *error = nil;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error]];
        if (error) {
            handler(nil, error);
            return;
        }

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue new]
                               completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

@end
