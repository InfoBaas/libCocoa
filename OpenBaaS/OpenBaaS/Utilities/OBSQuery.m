//
//  OBSQuery.m
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

#import "OBSQuery+.h"

NSString *const OBSQueryParamCollectionPage = @"pageNumber";
NSString *const OBSQueryParamCollectionPageSize = @"pageSize";
NSString *const OBSQueryParamCollectionElementIndex = @"elemIndex";
NSString *const OBSQueryParamCollectionElementCount = @"elemCount";
NSString *const OBSQueryParamCollectionDataQuery = @"query";
NSString *const OBSQueryParamCollectionOrderBy = @"orderBy";
NSString *const OBSQueryParamCollectionOrderByDistance = @"_dist";
NSString *const OBSQueryParamCollectionOrderType = @"orderType";
NSString *const OBSQueryParamCollectionOrderTypeAscendent = @"asc";
NSString *const OBSQueryParamCollectionOrderTypeDescendent = @"desc";
NSString *const OBSQueryParamCollectionLatitude = @"lat";
NSString *const OBSQueryParamCollectionLongitude = @"long";
NSString *const OBSQueryParamCollectionRadius = @"radius";
NSString *const OBSQueryParamHide = @"hide";
NSString *const OBSQueryParamShow = @"show";

static NSString *const _kQueryOperationKey = @"oper";
static NSString *const _kQueryLeftOperationKey = @"op1";
static NSString *const _kQueryRightOperationKey = @"op2";
static NSString *const _kQueryPath = @"attribute";
static NSString *const _kQueryValue = @"value";

@implementation OBSQuery

+ (NSDictionary *)operationNotOperation:(NSDictionary *)operation
{
    return @{_kQueryOperationKey: @"not",
             _kQueryLeftOperationKey: operation};
}
+ (NSDictionary *)operationAndOfLeftOperation:(NSDictionary *)lOperation rightOperaton:(NSDictionary *)rOperation
{
    return @{_kQueryOperationKey: @"and",
             _kQueryLeftOperationKey: lOperation,
             _kQueryRightOperationKey: rOperation};
}
+ (NSDictionary *)operationOrOfLeftOperation:(NSDictionary *)lOperation rightOperaton:(NSDictionary *)rOperation
{
    return @{_kQueryOperationKey: @"or",
             _kQueryLeftOperationKey: lOperation,
             _kQueryRightOperationKey: rOperation};
}

+ (NSDictionary *)operationStringAtPath:(NSString *)path containsString:(NSString *)string
{
    return @{_kQueryOperationKey: @"contains",
             _kQueryPath: path,
             _kQueryValue: string};
}
+ (NSDictionary *)operationValueAtPath:(NSString *)path isEqualTo:(id)value
{
    return @{_kQueryOperationKey: @"equals",
             _kQueryPath: path,
             _kQueryValue: value};
}
+ (NSDictionary *)operationValueAtPath:(NSString *)path isGreaterThen:(id)value
{
    return @{_kQueryOperationKey: @"greater",
             _kQueryPath: path,
             _kQueryValue: value};
}
+ (NSDictionary *)operationValueAtPath:(NSString *)path isLesserThen:(id)value
{
    return @{_kQueryOperationKey: @"lesser",
             _kQueryPath: path,
             _kQueryValue: value};
}

@end
