//
//  OBSSession+_.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 31/10/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSSession.h"

@interface OBSSession (_)

@property (nonatomic, strong) NSString *token;
- (void)setUser:(OBSUser *)user;

@end
