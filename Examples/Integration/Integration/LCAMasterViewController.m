//
//  LCAMasterViewController.m
//  Integration
//
//  Created by Tiago Rodrigues on 09/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCAMasterViewController.h"
#import "LCAAppDelegate.h"

#import "LCADetailViewController.h"

@interface LCAMasterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *appIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *appKeyTextField;

- (IBAction)appIdEditingDidEnd:(id)sender;
- (IBAction)appKeyEditingDidEnd:(id)sender;

- (IBAction)openSavedSession:(id)sender;
- (IBAction)backhome:(UIStoryboardSegue *)sender;

@end

static NSString *_networkName = @"network";
static NSString *_networkImage = @"logo";
static NSArray *_networks (void)
{
    static NSArray *networks = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIImage *facebook = [UIImage imageNamed:@"fb"];
        networks = @[@{_networkName: @"Facebook", _networkImage: facebook}];
    });
    return networks;
}

@implementation LCAMasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appIdTextField.text = delegate.appId;
    self.appKeyTextField.text = delegate.appKey;
}

- (IBAction)appIdEditingDidEnd:(id)sender
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.appId = self.appIdTextField.text;
}

- (IBAction)appKeyEditingDidEnd:(id)sender
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.appKey = self.appKeyTextField.text;
}

- (IBAction)openSavedSession:(id)sender
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];

    [delegate showWaitScreen];

    if (![OBSSession openCurrentSessionWithClient:delegate andCompletionHandler:^(BOOL opened, OBSSession *session, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            if (opened && session) {
                [self performSegueWithIdentifier:@"Segue_2_SessionInfo" sender:session];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
        });
    }]) {
        [delegate hideWaitScreen];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"no session saved" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void)backhome:(UIStoryboardSegue *)sender
{}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_networks() count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *network = _networks()[indexPath.row];
    cell.textLabel.text = network[_networkName];
    cell.imageView.image = network[_networkImage];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
