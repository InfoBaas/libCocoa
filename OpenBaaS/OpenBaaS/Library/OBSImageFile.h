//
//  OBSImageFile.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 17/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

extern NSString *const OBSImageSizeOriginal;

@interface OBSImageFile : OBSObject

@property (nonatomic, strong) NSString *mediaId;
@property (nonatomic, strong) NSString *fileExtension;
@property (nonatomic, strong) NSString *fileName;

#if TARGET_OS_IPHONE
- (void)downloadImageOfSize:(NSString *)size withCompletionHandler:(void(^)(OBSImageFile *imageFile, UIImage *image, OBSError *error))handler;
#endif

@end
