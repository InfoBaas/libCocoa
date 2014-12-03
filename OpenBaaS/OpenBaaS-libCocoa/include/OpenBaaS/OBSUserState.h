//
//  OBSUserState.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 06/02/14.
//  Copyright (c) 2014 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBSUserState : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) BOOL online;
@property (nonatomic, strong) NSDate *lastUpdatedAt;

@end
