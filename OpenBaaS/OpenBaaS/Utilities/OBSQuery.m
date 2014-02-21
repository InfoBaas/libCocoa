//
//  OBSQuery.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 17/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

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
