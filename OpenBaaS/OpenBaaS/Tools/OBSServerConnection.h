//
//  OBSServer.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 10/09/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBSServerConnection : NSObject

+ (void)createSessionWithAppId:(NSString *)appId
                         email:(NSString *)email
                      password:(NSString *)password
             completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error))handler;

@end
