//
//  OBSUserState.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 06/02/14.
//  Copyright (c) 2014 Infosistema. All rights reserved.
//

#import "OBSUserState+.h"

@implementation OBSUserState

+ (OBSUserState *)userStateFromJSONObject:(NSDictionary *)json
{
    if ([json isEqual:[NSNull null]]) {
        json = nil;
    }
    
    NSString *userId = json[@"_id"];
    if (!userId) {
        return nil;
    }
    BOOL online = [json[@"online"] boolValue];
    id date = json[@"lastUpdateDate"];
    if (date) {
        date = [NSDate dateWithTimeIntervalSince1970:[date doubleValue]];
    }
    
    OBSUserState *state = [OBSUserState new];
    state.userId = userId;
    state.online = online;
    state.lastUpdatedAt = date;
    return state;
}

@end
