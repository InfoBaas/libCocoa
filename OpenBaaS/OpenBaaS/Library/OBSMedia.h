//
//  OBSMedia.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 17/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <OpenBaaS/OpenBaaS.h>

@class OBSImageFile;

@interface OBSMedia : OBSObject

@property (nonatomic, strong, readonly) OBSApplication *application;

#pragma mark Images

- (void)getImageFileWithId:(NSString *)imageFileId withCompletionHandler:(void(^)(OBSMedia *media, NSString *imageFileId, OBSImageFile *imageFile, OBSError *error))handler;

- (void)getImageFileIdsWithQueryDictionary:(NSDictionary *)query completionHandler:(void(^)(OBSMedia *media, OBSCollectionPage *imageFileIds, OBSError *error))handler;

- (void)getImageFilesWithQueryDictionary:(NSDictionary *)query completionHandler:(void(^)(OBSMedia *media, OBSCollectionPage *imageFileIds, OBSError *error))handler elementCompletionHandler:(void(^)(OBSMedia *media, NSString *imageFileId, OBSImageFile *imageFile, OBSError *error))elementHandler;

@end
