//
//  OBSQuery.h
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
