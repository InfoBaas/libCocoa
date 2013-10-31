//
//  OBSConnection.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 31/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBSAccount;
@class OBSApplication;
@class OBSSession;

@interface OBSConnection : NSObject

@end

#pragma mark - POST

@interface OBSConnection (POST)

+ (void)post_account:(OBSAccount *)account signInWithEmail:(NSString *)email password:(NSString *)password completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error))handler;

@end
