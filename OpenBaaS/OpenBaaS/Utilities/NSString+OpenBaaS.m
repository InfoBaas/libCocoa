//
//  NSString+OpenBaaS.m
//  OpenBaaS
//
/*****************************************************************************************
 Infosistema - Lib-Cocoa
 Copyright(C) 2002-2014 Infosistema, S.A.
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU Affero General Public License for more details.
 You should have received a copy of the GNU Affero General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 www.infosistema.com
 info@openbaas.com
 Av. José Gomes Ferreira, 11 3rd floor, s.34
 Miraflores
 1495-139 Algés Portugal
 ****************************************************************************************/

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
