//
//  OBSImageFile.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 17/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSImageFile+.h"

#import "OBSConnection.h"

NSString *const OBSImageSizeOriginal = @"original";

@implementation OBSImageFile

+ (NSSet *)allSizes
{
    static NSSet *allSizes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allSizes = [NSSet setWithArray:@[OBSImageSizeOriginal]];
    });
    return allSizes;
}

+ (NSArray *)nativeFields
{
    return @[@"_id", @"fileExtension", @"fileName"];
}

+ (OBSImageFile *)imageFileFromDataJSON:(NSDictionary *)data andMetadataJSON:(NSDictionary *)metadata withClient:(id<OBSClientProtocol>)client
{
    if ([data isEqual:[NSNull null]]) {
        data = nil;
    }
    if ([metadata isEqual:[NSNull null]]) {
        metadata = nil;
    }
    
    NSString *mediaId = data[@"_id"];
    if (!mediaId || [mediaId isEqual:[NSNull null]]) {
        return nil;
    }
    NSString *fileExtension = data[@"fileExtension"];
    if ([fileExtension isEqual:[NSNull null]]) {
        fileExtension = nil;
    }
    NSString *fileName = data[@"fileName"];
    if ([fileName isEqual:[NSNull null]]) {
        fileName = nil;
    }

    // Create and initialise object.
    OBSImageFile *imageFile = [[OBSImageFile alloc] initWithClient:client];
    // Set proprieties.
    imageFile.mediaId = mediaId;
    imageFile.fileExtension = fileExtension;
    imageFile.fileName = fileName;

    return imageFile;
}

#if TARGET_OS_IPHONE
- (void)downloadImageOfSize:(NSString *)size withCompletionHandler:(void(^)(OBSImageFile *imageFile, UIImage *image, OBSError *error))handler
#endif
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *imageSize = size;
        if (![[OBSImageFile allSizes] containsObject:imageSize]) {
            imageSize = OBSImageSizeOriginal;
        }
        [OBSConnection get_imageFile:self imageSize:imageSize queryDictionary:nil completionHandler:^(id result, NSInteger statusCode, NSError *error) {
            if (!handler)
                return;

            // Called with error?
            if (error) {
                handler(self, nil, [OBSError errorWithDomain:error.domain code:error.code userInfo:error.userInfo]);
                return;
            }

            // Create image.
#if TARGET_OS_IPHONE
            UIImage *image = nil;
#endif
            if ([result isKindOfClass:[NSData class]]) {
#if TARGET_OS_IPHONE
                image = [UIImage imageWithData:result];
#endif
            }
            if (!image) {
                // Image wasn't created.
                handler(self, nil, [OBSError errorWithDomain:kOBSErrorDomainRemote code:kOBSRemoteErrorCodeResultDataIllFormed userInfo:nil]);
                return;
            }

            handler(self, image, nil);
        }];
    });
}

@end
