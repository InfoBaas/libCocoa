//
//  OBSApplication.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBSApplication : NSObject

@property (nonatomic, readonly) NSString *appID;

+ (OBSApplication *)applicationWithAppID:(NSString *)appID;

@end
