//
//  LCADataViewController.m
//  SimpleDataSearch-iOS
//
//  Created by Tiago Rodrigues on 28/01/2014.
//  Copyright (c) 2014 Infosistema. All rights reserved.
//

#import "LCADataViewController.h"
#import "LCAAppDelegate.h"

@interface LCADataViewController ()

@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation LCADataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.data = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showWaitScreen];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *file = [NSData dataWithContentsOfFile:path];
    id data = [NSJSONSerialization JSONObjectWithData:file options:kNilOptions error:nil];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    [application insertObject:data atPath:@"" withCompletionHandler:^(OBSApplication *application, NSString *path, NSDictionary *object, BOOL inserted, OBSError *error) {
        NSDictionary *query = [OBSQuery operationValueAtPath:@"1" isEqualTo:@1];
        [application readPath:@"" withQueryDictionary:@{OBSQueryParamCollectionPage:@1,OBSQueryParamCollectionDataQuery:query} completionHandler:^(OBSApplication *application, NSString *path, id data, id metadata, OBSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate hideWaitScreen];
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                } else {
                    NSLog(@"%@", data);
                }
            });
        }];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.data[indexPath.row];
    
    return cell;
}

@end
