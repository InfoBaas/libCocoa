//
//  LCAMasterViewController.m
//  SimpleImageGallery-iOS
//
//  Created by Tiago Rodrigues on 17/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCAMasterViewController.h"
#import "LCAAppDelegate.h"
#import "LCADetailViewController.h"

@interface LCAMasterViewController ()
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) NSInteger nextPageToLoad;
@property (nonatomic, strong) NSMutableArray *imageFiles;
- (void)insertNewImage:(id)sender;
- (IBAction)loadMoreImageFiles:(id)sender;

@end

@implementation LCAMasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewImage:)];
    self.navigationItem.rightBarButtonItem = addButton;

    self.imageFiles = [NSMutableArray array];
    self.nextPageToLoad = 1;
}

- (void)insertNewImage:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }

    [imagePicker setDelegate:self];

    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)loadMoreImageFiles:(id)sender
{
    UIButton *button = sender;
    if ([button isKindOfClass:[UIButton class]] && button.tag == 1) {
        UIView *content = [button superview];
        [button setHidden:YES];
        UIActivityIndicatorView *activityIndication = (id)[content viewWithTag:2];
        if ([activityIndication isKindOfClass:[UIActivityIndicatorView class]])
            [activityIndication startAnimating];

//        NSMutableArray *imageFiles = [NSMutableArray array];
//        NSUInteger __block loaded = 0;
//        NSUInteger __block total = 0;

        LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
        OBSApplication *application = [OBSApplication applicationWithClient:delegate];
        OBSMedia *media = [application applicationMedia];
        /*/
        [media getImageFilesWithQueryDictionary:@{OBSQueryParamCollectionPage:@(self.nextPageToLoad)}
                              completionHandler:^(OBSMedia *media, OBSCollectionPage *imageFileIds, OBSError *error) {
                                  if (error) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [button setHidden:NO];
                                          if ([activityIndication isKindOfClass:[UIActivityIndicatorView class]])
                                              [activityIndication stopAnimating];
                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                          [alert show];
                                      });
                                  } else {
                                      NSLog(@"\nPage: %d of %d\nPage size: %d\nNumber of elements: %d\nIndex of first element: %d\nMambos: \n%@", imageFileIds.pageNumber, imageFileIds.pageCount, imageFileIds.pageSize, imageFileIds.elementCount, imageFileIds.firstElement, imageFileIds.elements);
                                      [imageFiles addObjectsFromArray:imageFileIds.elements];
                                      total = imageFileIds.elementCount;
                                  }
                              }
                       elementCompletionHandler:^(OBSMedia *media, NSString *imageFileId, OBSImageFile *imageFile, OBSError *error) {
                           if (error) {
                               NSLog(@"\nError loading image %@: %@", imageFileId, [error description]);
                           } else {
                               NSLog(@"(ID,%@ ; EXTENSION,%@ ; NAME,%@", imageFile.mediaId, imageFile.fileExtension, imageFile.fileName);
                               @synchronized (imageFiles) {
                                   [imageFiles replaceObjectAtIndex:[imageFiles indexOfObject:imageFileId] withObject:imageFile];
                               }
                           }
                           @synchronized (imageFiles) {
                               if (++loaded >= total) {
                                   NSPredicate *success = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                                       return [evaluatedObject isKindOfClass:[OBSImageFile class]];
                                   }];
                                   NSArray *succedded = [imageFiles filteredArrayUsingPredicate:success];

                                   NSPredicate *fail = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                                       return ![evaluatedObject isKindOfClass:[OBSImageFile class]];
                                   }];
                                   NSArray *failed = [imageFiles filteredArrayUsingPredicate:fail];

                                   self.nextPageToLoad++;
                                   [self.imageFiles addObjectsFromArray:succedded];

                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self.tableView reloadData];

                                       [button setHidden:NO];
                                       if ([activityIndication isKindOfClass:[UIActivityIndicatorView class]])
                                           [activityIndication stopAnimating];

                                       if ([failed count]) {
                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%u of %d failed to load.", [failed count], total] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                           [alert show];
                                       }
                                   });
                               }
                           }
                       }];
        /*/
        [media getImageFilesWithQueryDictionary:@{OBSQueryParamCollectionPage:@(self.nextPageToLoad)} completionHandler:^(OBSMedia *media, OBSCollectionPage *imageFiles, OBSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [button setHidden:NO];
                    if ([activityIndication isKindOfClass:[UIActivityIndicatorView class]])
                        [activityIndication stopAnimating];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                });
            } else {
                NSArray *elements = imageFiles.elements;
                
                NSPredicate *success = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    return [evaluatedObject isKindOfClass:[OBSImageFile class]];
                }];
                NSArray *succedded = [elements filteredArrayUsingPredicate:success];
                
                NSPredicate *fail = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    return ![evaluatedObject isKindOfClass:[OBSImageFile class]];
                }];
                NSArray *failed = [elements filteredArrayUsingPredicate:fail];
                
                self.nextPageToLoad++;
                [self.imageFiles addObjectsFromArray:succedded];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    
                    [button setHidden:NO];
                    if ([activityIndication isKindOfClass:[UIActivityIndicatorView class]])
                        [activityIndication stopAnimating];
                    
                    if ([failed count]) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%u of %d failed to load.", [failed count], [elements count]] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                        [alert show];
                    }
                });
            }
        }];
        //*/
    }
}

#pragma mark - Image picker controller delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString *fileName = [NSString stringWithFormat:@"timg.%ld", (long)[[NSDate date] timeIntervalSince1970]];

    // replace add button with an activity indicator
    UIBarButtonItem *addButton = [self.navigationItem rightBarButtonItem];
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityView sizeToFit];
    [activityView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [activityView setColor:[addButton tintColor]];
    UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    [self.navigationItem setRightBarButtonItem:loadingView];

    // upload image
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    OBSMedia *media = [application applicationMedia];
    [media uploadImage:image withFileName:fileName completionHandler:^(OBSMedia *media, OBSImageFile *imageFiles, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // replace activity indicator with the add button
            [self.navigationItem setRightBarButtonItem:addButton];
            // handle upload
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            } else {
#warning YOU ARE HERE
//                NSAssert(NO, @"Not yet Implemented");
            }
        });
    }];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.imageFiles.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.row < self.imageFiles.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Image Id"];
        OBSImageFile *imageFile = self.imageFiles[indexPath.row];
        cell.textLabel.text = imageFile.mediaId;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"More"];
    }
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Segue_2_ImageDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        OBSImageFile *imageFile = self.imageFiles[indexPath.row];
        LCADetailViewController *controller = [segue destinationViewController];
        controller.imageFile = imageFile;
    }
}

@end
