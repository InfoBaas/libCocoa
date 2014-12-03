//
//  OBSImageFile.m
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

#import "OBSImageFile+.h"

#import "OBSConnection.h"

NSString *const OBSImageSizeOriginal = @"original";

@implementation OBSImageFile

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
        if (!imageSize) {
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
