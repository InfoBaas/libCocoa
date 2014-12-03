//
//  OBSMedia.m
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

#import "OBSMedia+.h"

#import "OBSQuery+.h"

#import "OBSApplication+.h"
#import "OBSImageFile+.h"

#import "OBSConnection.h"

@implementation OBSMedia

- (id)initWithApplication:(OBSApplication *)application
{
    self = [super initWithClient:application.client];
    if (self) {
        _application = application;
    }
    return self;
}

- (void)dealloc
{
    _application = nil;
}

#pragma mark Images

- (void)deleteImageFileWithId:(NSString *)imageFileId withCompletionHandler:(void (^)(OBSMedia *, NSString *, BOOL, OBSError *))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasImageFileId = imageFileId && [imageFileId isKindOfClass:[NSString class]];
        if (hasImageFileId) {
            [OBSConnection delete_media:self imageFileWithId:imageFileId queryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler)
                    return;
                
                // Called with error?
                if (error) {
                    handler(self, imageFileId, NO, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }
                
                handler(self, imageFileId, YES, nil);
            }];
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:3];
            // Add missing parameters to the array.
            if (!hasImageFileId) [missingRequiredParameters addObject:@"imageFileId"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, imageFileId, NO, error);
        }
    });
}

- (void)getImageFileWithId:(NSString *)imageFileId withCompletionHandler:(void(^)(OBSMedia *media, NSString *imageFileId, OBSImageFile *imageFile, OBSError *error))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL hasImageFileId = imageFileId && [imageFileId isKindOfClass:[NSString class]];
        if (hasImageFileId) {
            [OBSConnection get_media:self imageFileWithId:imageFileId queryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler)
                    return;

                // Called with error?
                if (error) {
                    handler(self, imageFileId, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }

                // Create image file.
                OBSImageFile *imageFile = nil;
                if ([result isKindOfClass:[NSDictionary class]]) {
                    imageFile = [OBSImageFile imageFileFromDataJSON:result[OBSConnectionResultDataKey] andMetadataJSON:result[OBSConnectionResultMetadataKey] withClient:self.client];
                }
                if (!imageFile) {
                    // Image file wasn't created.
                    handler(self, imageFileId, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                    return;
                }

                handler(self, imageFileId, imageFile, nil);
            }];
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:3];
            // Add missing parameters to the array.
            if (!hasImageFileId) [missingRequiredParameters addObject:@"imageFileId"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, imageFileId, nil, error);
        }
    });
}

- (void)getImageFileIdsWithQueryDictionary:(NSDictionary *)query completionHandler:(void(^)(OBSMedia *media, OBSCollectionPage *imageFileIds, OBSError *error))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [OBSConnection get_media:self imageFilesWithQueryDictionary:query completionHandler:^(id result, NSInteger statusCode, NSError *error) {
            if (!handler)
                return;

            // Called with error?
            if (error) {
                handler(self, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                return;
            }

            // Create collection page.
            OBSCollectionPage *collectionPage = nil;
            if ([result isKindOfClass:[NSDictionary class]]) {
                collectionPage = [OBSCollectionPage collectionPageFromDataJSON:result andMetadataJSON:nil];
            }
            if (!collectionPage) {
                // Collection page wasn't created.
                handler(self, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                return;
            }

            handler(self, collectionPage, nil);
        }];
    });
}

- (void)getImageFilesWithQueryDictionary:(NSDictionary *)query completionHandler:(void(^)(OBSMedia *media, OBSCollectionPage *imageFileIds, OBSError *error))handler elementCompletionHandler:(void(^)(OBSMedia *media, NSString *imageFileId, OBSImageFile *imageFile, OBSError *error))elementHandler
{
    [self getImageFileIdsWithQueryDictionary:query completionHandler:^(OBSMedia *media, OBSCollectionPage *imageFileIds, OBSError *error) {
        if (handler)
            handler(media, imageFileIds, error);

        if (!error) {
            for (NSString *imageFileId in [imageFileIds elements]) {
                [self getImageFileWithId:imageFileId withCompletionHandler:elementHandler];
            }
        }
    }];
}

- (void)getImageFilesWithQueryDictionary:(NSDictionary *)query completionHandler:(void (^)(OBSMedia *, OBSCollectionPage *, OBSError *))handler
{
    NSArray *show = query[OBSQueryParamShow];
    if (!show)
        show = @[];
    
    NSArray *userNativeFields = [OBSImageFile nativeFields];
    show = [show arrayByAddingObjectsFromArray:userNativeFields];
    
    if (query) {
        NSMutableDictionary *mutableQuery = [query mutableCopy];
        mutableQuery[OBSQueryParamShow] = show;
        query = mutableQuery;
    } else {
        query = @{OBSQueryParamShow: show};
    }
    
    [self getImageFileIdsWithQueryDictionary:query completionHandler:^(OBSMedia *media, OBSCollectionPage *imageFiles, OBSError *error) {
        if (error) {
            handler(media, nil, error);
        } else {
            NSArray *elements = imageFiles.elements;
            NSUInteger count = [elements count];
            NSMutableArray *imageFileObjects = [NSMutableArray arrayWithCapacity:count];
            for (NSUInteger e = 0; e < count; e++) {
                OBSCollectionPageElement *elementObject = elements[e];
                NSDictionary *data = elementObject.data;
                NSDictionary *metadata = elementObject.metadata;
                OBSImageFile *imageFile = [OBSImageFile imageFileFromDataJSON:data andMetadataJSON:metadata withClient:media.client];
                if (imageFile) {
                    [imageFileObjects addObject:imageFile];
                } else {
                    [imageFileObjects addObject:[NSNull null]];
                }
            }
            imageFiles.elements = [NSArray arrayWithArray:imageFileObjects];
            handler(media, imageFiles, nil);
        }
    }];
}

#if TARGET_OS_IPHONE
- (void)uploadImage:(UIImage *)image withFileName:(NSString *)fileName completionHandler:(void(^)(OBSMedia *media, OBSImageFile *imageFiles, OBSError *error))handler
#endif
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#if TARGET_OS_IPHONE
        BOOL hasImage = image && [image isKindOfClass:[UIImage class]];
#endif
        BOOL hasFileName = fileName && [fileName isKindOfClass:[NSString class]];
        if (hasImage && hasFileName) {
            [OBSConnection post_media:self image:image withFileName:fileName queryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
                if (!handler)
                    return;

                // Called with error?
                if (error) {
                    handler(self, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                    return;
                }

                // Create image file.
                OBSImageFile *imageFile = nil;
                if ([result isKindOfClass:[NSDictionary class]]) {
                    imageFile = [OBSImageFile imageFileFromDataJSON:result[OBSConnectionResultDataKey] andMetadataJSON:result[OBSConnectionResultMetadataKey] withClient:self.client];
                }
                if (!imageFile) {
                    // Image file wasn't created.
                    handler(self, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                    return;
                }

                handler(self, imageFile, nil);
            }];
        } else if (handler) {
            //// Some or all the required parameters are missing
            // Create an array to hold the missing parameters' names.
            NSMutableArray *missingRequiredParameters = [NSMutableArray arrayWithCapacity:3];
            // Add missing parameters to the array.
            if (!hasImage) [missingRequiredParameters addObject:@"image"];
            if (!hasFileName) [missingRequiredParameters addObject:@"fileName"];
            // Create userInfo dictionary.
            NSDictionary *userInfo = @{kOBSErrorUserInfoKeyMissingRequiredParameters: [NSArray arrayWithArray:missingRequiredParameters]};
            // Create an error instace to send to the callback.
            OBSError *error = [OBSError errorWithDomain:kOBSErrorDomainLocal
                                                   code:kOBSLocalErrorCodeMissingRequiredParameters
                                               userInfo:userInfo];
            // Action completed with error.
            handler(self, nil, error);
        }
    });
}

@end
