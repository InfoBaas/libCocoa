//
//  OBSConnection.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 31/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSConnection.h"

@implementation OBSConnection

@end

#pragma mark - POST

@implementation OBSConnection (POST)

+ (void)post_account:(OBSAccount *)account signInWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler
{
    NSOperationQueue *queue = [NSOperationQueue currentQueue];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#warning TODO
        //        [NSURLConnection sendAsynchronousRequest:request
        //                                           queue:queue
        //                               completionHandler:handler];
        handler(nil, @"aSessionToken", nil);
    });
}

@end
