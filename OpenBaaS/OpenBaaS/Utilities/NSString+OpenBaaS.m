//
//  NSString+OpenBaaS.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 06/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "NSString+OpenBaaS.h"

@implementation NSString (OpenBaaS)

- (NSString *)obs_stringByAddingPercentEscapes
{
    CFStringRef str = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) self, NULL, (CFStringRef)@":/?#[]@!$&'()*+,;=", kCFStringEncodingUTF8);
    NSString *ret = (__bridge NSString *)str;
    CFRelease(str);
    return ret;
}

@end
