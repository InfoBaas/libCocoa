//
//  OBSUser+.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 05/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSUserState.h"

@interface OBSUserState ()

+ (OBSUserState *)userStateFromJSONObject:(NSDictionary *)json;

@end
