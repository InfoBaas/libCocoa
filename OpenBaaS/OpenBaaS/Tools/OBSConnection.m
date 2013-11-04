//
//  OBSConnection.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 31/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSConnection.h"

#import "OBSAccount+_.h"
#import "OBSApplication+_.h"
#import "OBSSession+_.h"

#pragma mark -

@implementation OBSConnection

+ (NSString *)OpenBaaSAddress
{
    static NSString *address = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        address = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"OpenBaaS.URL"];
    });
    return address;
}

@end

#pragma mark - POST

@implementation OBSConnection (POST)

+ (NSMutableURLRequest *)post_requestForAddress:(NSString *)address
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:address]];
    [request setHTTPMethod:@"POST"];
    return request;
}

+ (void)post_account:(OBSAccount *)account signUpWithEmail:(NSString *)email password:(NSString *)password userName:(NSString *)userName userFile:(NSString *)userFile completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler
{
    NSOperationQueue *queue = [NSOperationQueue currentQueue];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/signup", [self OpenBaaSAddress], [[account client] appId]];
        NSMutableDictionary *body = [NSMutableDictionary dictionaryWithObjectsAndKeys:email, @"email", password, @"password", nil];
        if (userName) body[@"userName"] = userName;
        if (userFile) body[@"userFile"] = userFile;

        NSMutableURLRequest *request = [self post_requestForAddress:address];

        NSError *error = nil;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error]];
        if (error) {
            handler(nil, nil, error);
            return;
        }

#warning Missing Header Fields: location=<latitude>:<longitude>

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:queue
                               completionHandler:handler];
    });
}

+ (void)post_account:(OBSAccount *)account signInWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler
{
    NSOperationQueue *queue = [NSOperationQueue currentQueue];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/signin", [self OpenBaaSAddress], [[account client] appId]];
        NSDictionary *body = @{@"email": email,
                               @"password": password};

        NSMutableURLRequest *request = [self post_requestForAddress:address];

        NSError *error = nil;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error]];
        if (error) {
            handler(nil, nil, error);
            return;
        }

#warning Missing Header Fields: location=<latitude>:<longitude>

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:queue
                               completionHandler:handler];
    });
}

+ (void)post_accountSignOutWithSession:(OBSSession *)session all:(BOOL)all completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler
{
    NSOperationQueue *queue = [NSOperationQueue currentQueue];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/signout/%@", [self OpenBaaSAddress], [[session client] appId], [session token]];
        NSDictionary *body = @{@"all": [NSNumber numberWithBool:all]};

        NSMutableURLRequest *request = [self post_requestForAddress:address];

        NSError *error = nil;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error]];
        if (error) {
            handler(nil, nil, error);
            return;
        }

#warning Missing Header Fields: location=<latitude>:<longitude>

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:queue
                               completionHandler:handler];
    });
}

+ (void)post_account:(OBSAccount *)account recoveryWithEmail:(NSString *)email completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler
{
    NSOperationQueue *queue = [NSOperationQueue currentQueue];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *address = [NSString stringWithFormat:@"%@/apps/%@/account/recovery", [self OpenBaaSAddress], [[account client] appId]];
        NSDictionary *body = @{@"email": email};

        NSMutableURLRequest *request = [self post_requestForAddress:address];

        NSError *error = nil;
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error]];
        if (error) {
            handler(nil, nil, error);
            return;
        }

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:queue
                               completionHandler:handler];
    });
}

@end
