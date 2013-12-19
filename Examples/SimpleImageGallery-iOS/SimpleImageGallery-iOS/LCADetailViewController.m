//
//  LCADetailViewController.m
//  SimpleImageGallery-iOS
//
//  Created by Tiago Rodrigues on 17/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCADetailViewController.h"

@interface LCADetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileExtensionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LCADetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.imageFile.mediaId;
    self.fileNameLabel.text = self.imageFile.fileName;
    self.fileExtensionLabel.text = self.imageFile.fileExtension;
    [self.imageFile downloadImageOfSize:OBSImageSizeOriginal withCompletionHandler:^(OBSImageFile *imageFile, UIImage *image, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            if (image) {
                self.imageView.image = image;
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
        });
    }];
}

@end
