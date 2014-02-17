//
//  LCAUserListViewController.m
//  SimpleUserList-iOS
//
//  Created by Tiago Rodrigues on 12/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCAUserListViewController.h"
#import "LCAAppDelegate.h"
#import "LCAUserInfoViewController.h"

@interface LCAUserListViewController ()

@property (nonatomic, assign) NSInteger nextPageToLoad;
@property (nonatomic, strong) NSMutableArray *users;
- (IBAction)loadMoreUsers:(id)sender;

@end

@implementation LCAUserListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.users = [NSMutableArray array];
    self.nextPageToLoad = 1;
}

- (IBAction)loadMoreUsers:(id)sender
{
    UIButton *button = sender;
    if ([button isKindOfClass:[UIButton class]] && button.tag == 1) {
        UIView *content = [button superview];
        [button setHidden:YES];
        UIActivityIndicatorView *activityIndication = (id)[content viewWithTag:2];
        if ([activityIndication isKindOfClass:[UIActivityIndicatorView class]])
            [activityIndication startAnimating];

//        NSMutableArray *users = [NSMutableArray array];
//        NSUInteger __block loaded = 0;
//        NSUInteger __block total = 0;

        LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
        OBSApplication *application = [OBSApplication applicationWithClient:delegate];
        /*/
        [application getUsersWithQueryDictionary:@{OBSQueryParamCollectionPage:@(self.nextPageToLoad)}
                               completionHandler:^(OBSApplication *application, OBSCollectionPage *userIds, OBSError *error) {
                                   if (error) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [button setHidden:NO];
                                           if ([activityIndication isKindOfClass:[UIActivityIndicatorView class]])
                                               [activityIndication stopAnimating];
                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                           [alert show];
                                       });
                                   } else {
                                       NSLog(@"\nPage: %d of %d\nPage size: %d\nNumber of elements: %d\nIndex of first element: %d\nMambos: \n%@", userIds.pageNumber, userIds.pageCount, userIds.pageSize, userIds.elementCount, userIds.firstElement, userIds.elements);
                                       [users addObjectsFromArray:userIds.elements];
                                       total = userIds.elementCount;
                                   }
                               }
                        elementCompletionHandler:^(OBSApplication *application, NSString *userId, OBSUser *user, OBSError *error) {
                            if (error) {
                                NSLog(@"\nError loading user %@: %@", userId, [error description]);
                            } else {
                                NSLog(@"(ID,%@ ; E-MAIL,%@ ; NAME,%@ ; FILE,%@", user.userId, user.userEmail, user.userName, user.userFile);
                                @synchronized (users) {
                                    [users replaceObjectAtIndex:[users indexOfObject:userId] withObject:user];
                                }
                            }
                            @synchronized (users) {
                                if (++loaded >= total) {
                                    NSPredicate *success = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                                        return [evaluatedObject isKindOfClass:[OBSUser class]];
                                    }];
                                    NSArray *succedded = [users filteredArrayUsingPredicate:success];

                                    NSPredicate *fail = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                                        return ![evaluatedObject isKindOfClass:[OBSUser class]];
                                    }];
                                    NSArray *failed = [users filteredArrayUsingPredicate:fail];

                                    self.nextPageToLoad++;
                                    [self.users addObjectsFromArray:succedded];

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
        [application getUsersWithQueryDictionary:@{OBSQueryParamCollectionPage:@(self.nextPageToLoad)} completionHandler:^(OBSApplication *application, OBSCollectionPage *users, OBSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [button setHidden:NO];
                    if ([activityIndication isKindOfClass:[UIActivityIndicatorView class]])
                        [activityIndication stopAnimating];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                });
            } else {
                NSArray *elements = users.elements;
                
                NSPredicate *success = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    return [evaluatedObject isKindOfClass:[OBSUser class]];
                }];
                NSArray *succedded = [elements filteredArrayUsingPredicate:success];
                
                NSPredicate *fail = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    return ![evaluatedObject isKindOfClass:[OBSUser class]];
                }];
                NSArray *failed = [elements filteredArrayUsingPredicate:fail];
                
                self.nextPageToLoad++;
                [self.users addObjectsFromArray:succedded];
                
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.row < self.users.count) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"User Id"];
        OBSUser *user = self.users[indexPath.row];
        cell.textLabel.text = user.userId;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"More"];
    }
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Segue_2_User"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        OBSUser *user = self.users[indexPath.row];
        LCAUserInfoViewController *controller = [segue destinationViewController];
        controller.user = user;
    }
}

@end
