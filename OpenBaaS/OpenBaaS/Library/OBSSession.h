//
//  OBSSession.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 30/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBSUser;

@interface OBSSession : OBSObject

@property (nonatomic, strong, readonly) OBSUser *user;

@end
