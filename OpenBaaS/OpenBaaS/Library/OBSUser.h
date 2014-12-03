//
//  OBSUser.h
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
#import <CoreLocation/CoreLocation.h>

@interface OBSUser : OBSObject

@property (nonatomic, strong, readonly) NSString *userId;
@property (nonatomic, strong, readonly) NSString *userEmail;
@property (nonatomic, strong, readonly) NSString *userName;
@property (nonatomic, strong, readonly) NSString *userFile;

@property (nonatomic, assign, readonly) BOOL online;

@property (nonatomic, strong, readonly) CLLocation *userLastLocation;
@property (nonatomic, strong, readonly) CLLocation *userBaseLocation;
@property (nonatomic, assign, readonly) BOOL usesBaseLocation;

@property (nonatomic, strong, readonly) NSDate *lastUpdatedAt;

- (void)updateUserWithCompletionHandler:(void(^)(OBSUser *user, OBSError *error))handler;

- (void)setUserName:(NSString *)userName andFile:(NSString *)userFile withCompletionHandler:(void(^)(OBSUser *user, OBSError *error))handler;

- (void)setBaseLocation:(CLLocation *)location withCompletionHandler:(void(^)(OBSUser *user, CLLocation *location, OBSError *error))handler;

- (void)useBaseLocation:(BOOL)useBaseLocation withCompletionHandler:(void(^)(OBSUser *user, BOOL useBaseLocation, OBSError *error))handler;

#pragma mark Data

- (void)searchPath:(NSString *)path withQueryDictionary:(NSDictionary *)query completionHandler:(void(^)(OBSUser *user, NSString *path, OBSCollectionPage *paths, OBSError *error))handler;

- (void)readPath:(NSString *)path withQueryDictionary:(NSDictionary *)query completionHandler:(void(^)(OBSUser *user, NSString *path, id data, id metadata, OBSError *error))handler;

- (void)insertObject:(NSDictionary *)object atPath:(NSString *)path withCompletionHandler:(void(^)(OBSUser *user, NSString *path, NSDictionary *object, BOOL inserted, OBSError *error))handler;

- (void)updatePath:(NSString *)path withObject:(NSDictionary *)object completionHandler:(void(^)(OBSUser *user, NSString *path, NSDictionary *object, BOOL updated, OBSError *error))handler;

- (void)removePath:(NSString *)path withCompletionHandler:(void(^)(OBSUser *user, NSString *path, BOOL deleted, OBSError *error))handler;

@end
