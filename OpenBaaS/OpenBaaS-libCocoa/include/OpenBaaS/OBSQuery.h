//
//  OBSQuery.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 17/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const OBSQueryParamCollectionPage;
extern NSString *const OBSQueryParamCollectionPageSize;
extern NSString *const OBSQueryParamCollectionElementIndex;
extern NSString *const OBSQueryParamCollectionElementCount;
extern NSString *const OBSQueryParamCollectionDataQuery;
extern NSString *const OBSQueryParamCollectionOrderBy;
extern NSString *const OBSQueryParamCollectionOrderByDistance;
extern NSString *const OBSQueryParamCollectionOrderType;
extern NSString *const OBSQueryParamCollectionOrderTypeAscendent;
extern NSString *const OBSQueryParamCollectionOrderTypeDescendent;
extern NSString *const OBSQueryParamCollectionLatitude;
extern NSString *const OBSQueryParamCollectionLongitude;
extern NSString *const OBSQueryParamCollectionRadius;
extern NSString *const OBSQueryParamHide;
extern NSString *const OBSQueryParamShow;

@interface OBSQuery : NSObject

+ (NSDictionary *)operationNotOperation:(NSDictionary *)operation;
+ (NSDictionary *)operationAndOfLeftOperation:(NSDictionary *)lOperation rightOperaton:(NSDictionary *)rOperation;
+ (NSDictionary *)operationOrOfLeftOperation:(NSDictionary *)lOperation rightOperaton:(NSDictionary *)rOperation;

+ (NSDictionary *)operationStringAtPath:(NSString *)path containsString:(NSString *)string;
+ (NSDictionary *)operationValueAtPath:(NSString *)path isEqualTo:(id)value;
+ (NSDictionary *)operationValueAtPath:(NSString *)path isGreaterThen:(id)value;
+ (NSDictionary *)operationValueAtPath:(NSString *)path isLesserThen:(id)value;

@end
