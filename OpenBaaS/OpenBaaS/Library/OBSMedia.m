//
//  OBSMedia.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 17/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSMedia+.h"

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
//            [self getImageFileWithId:[[imageFileIds elements] lastObject] withCompletionHandler:elementHandler];
        }
    }];
}

@end
