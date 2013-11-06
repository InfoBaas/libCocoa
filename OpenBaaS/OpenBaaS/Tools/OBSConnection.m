//
//  OBSConnection.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 31/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSConnection.h"

#import "OBSAccount+.h"
#import "OBSApplication+.h"
#import "OBSSession+.h"

@interface OBSConnection ()

+ (NSError *)errorWithResponse:(NSURLResponse *)response andData:(NSData *)data;
+ (void(^)(NSURLResponse *, NSData *, NSError *))innerHandlerWithOuterHandler:(void(^)(NSData *, NSError *))handler;

@end

#pragma mark -

@implementation OBSConnection

+ (NSString *)OpenBaaSAddress
{
    static NSString *address = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        address = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"OpenBaaS.URL"];
        NSAssert(address, @"\"OpenBaaS.URL\" key not found in bundle's info dictionary.");
    });
    return address;
}

#pragma mark Extension

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

+ (void (^)(NSURLResponse *, NSData *, NSError *))innerHandlerWithOuterHandler:(void (^)(NSData *, NSError *))handler
{
    return ^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) {
            error = [self errorWithResponse:response andData:data];
            if (error) data = nil;
        }
        handler(data, error);
    };
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

+ (void)post_account:(OBSAccount *)account signUpWithEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile completionHandler:(void (^)(NSData *, NSError *))handler
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

#warning Missing Header Fields: location=<latitude>:<longitude>

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue new]
                               completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

+ (void)post_account:(OBSAccount *)account signInWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(NSData *, NSError *))handler
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

#warning Missing Header Fields: location=<latitude>:<longitude>

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue new]
                               completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

+ (void)post_accountSignOutWithSession:(OBSSession *)session all:(BOOL)all completionHandler:(void (^)(NSData *, NSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/signout/%@", [self OpenBaaSAddress], [[session client] appId], [session token]];
        NSDictionary *body = @{@"all": [NSNumber numberWithBool:all]};

        NSMutableURLRequest *request = [self post_requestForAddress:address];

        NSError *error = nil;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error]];
        if (error) {
            handler(nil, error);
            return;
        }

#warning Missing Header Fields: location=<latitude>:<longitude>

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue new]
                               completionHandler:[self innerHandlerWithOuterHandler:handler]];
    });
}

+ (void)post_account:(OBSAccount *)account recoveryWithEmail:(NSString *)email completionHandler:(void (^)(NSData *, NSError *))handler
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
