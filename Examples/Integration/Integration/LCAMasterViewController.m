//
//  LCAMasterViewController.m
//  Integration
//
//  Created by Tiago Rodrigues on 09/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCAMasterViewController.h"
#import <Accounts/Accounts.h>
#import "LCAAppDelegate.h"
#import "LCAActionSheet.h"
#import "LCADetailViewController.h"

@interface LCAMasterViewController ()
<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITextField *appIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *appKeyTextField;

- (IBAction)appIdEditingDidEnd:(id)sender;
- (IBAction)appKeyEditingDidEnd:(id)sender;

- (IBAction)openSavedSession:(id)sender;
- (IBAction)backhome:(UIStoryboardSegue *)sender;

#pragma mark Integration

@property (strong, readonly) ACAccountStore *accountStore;
- (void)accessToAccountsWithType:(ACAccountType *)accountType wasGranted:(BOOL)granted error:(NSError *)error;
- (void)signInWithAccount:(ACAccount *)account;

- (void)signInWithFacebook;

@end

#pragma mark -

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
#define _LCA_NETWORK_FACEBOOK       0

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Segue_2_SessionInfo"]) {
        LCADetailViewController *controller = [segue destinationViewController];
        controller.session = sender;
    }
}

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
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showWaitScreen];

    switch (indexPath.row) {
        case _LCA_NETWORK_FACEBOOK:
            [self signInWithFacebook];
            break;

        default:
            [delegate hideWaitScreen];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"unknown social network" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            break;
    }
}

#pragma mark Integration

- (ACAccountStore *)accountStore
{
    static ACAccountStore *_accountStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _accountStore = [[ACAccountStore alloc] init];
    });
    return _accountStore;
}

- (void)accessToAccountsWithType:(ACAccountType *)accountType wasGranted:(BOOL)granted error:(NSError *)error
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger code = error ? [error code] : ~ACErrorAccountNotFound;

    if (granted) {
        NSArray *accounts = [self.accountStore accountsWithAccountType:accountType];
        if ([accounts count] > 0) {
            if ([accounts count] > 1) {
                LCAActionSheet *accountSheet = [[LCAActionSheet alloc] initWithTitle:@"Choose the Account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                for (ACAccount *acc in accounts) {
                    [accountSheet addButtonWithTitle:acc.username];
                }
                [accountSheet addButtonWithTitle:@"Cancel"];
                [accountSheet setCancelButtonIndex:[accounts count]];
                accountSheet.actionSheetOptions = accounts;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [accountSheet showInView:self.view];
                });
            } else {
                [self signInWithAccount:[accounts lastObject]];
            }
            code = ~ACErrorAccountNotFound;
        } else {
            // no accounts configured on the device
            code = ACErrorAccountNotFound;
        }
    }

    if (code == ACErrorAccountNotFound) {
        [delegate hideWaitScreen];
        NSString *message = [NSString stringWithFormat:@"This device has no %@ account configured.\nYou can configure an account on the Settings app.", accountType.accountTypeDescription];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void)signInWithAccount:(ACAccount *)account
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *accountTypeIdentifier = account.accountType.identifier;
    if ([accountTypeIdentifier isEqualToString:ACAccountTypeIdentifierFacebook]) {
        NSString *oauthToken = [[account credential] oauthToken];
        OBSApplication *application = [OBSApplication applicationWithClient:delegate];
        OBSAccount *appAccount = [application applicationAccount];
        [appAccount signInWithFacebookOAuthToken:oauthToken completionHandler:^(OBSAccount *account, BOOL signedUp, BOOL signedIn, OBSSession *session, OBSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate hideWaitScreen];
                if ((signedUp || signedIn) && session) {
                    [self performSegueWithIdentifier:@"Segue_2_SessionInfo" sender:session];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                }
            });
        }];
    }
}

- (void)signInWithFacebook
{
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *facebookOptions = @{ACFacebookAppIdKey: @"236595649848814", ACFacebookPermissionsKey: @[@"email"]};
    [self.accountStore requestAccessToAccountsWithType:accountType options:facebookOptions completion:^(BOOL granted, NSError *error) {
        [self accessToAccountsWithType:accountType wasGranted:granted error:error];
    }];
}

#pragma mark - Action Sheet

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([actionSheet isKindOfClass:[LCAActionSheet class]]) {
        LCAActionSheet *lcaActionSheet = (LCAActionSheet *)actionSheet;
        if (buttonIndex < [lcaActionSheet.actionSheetOptions count]) {
            ACAccount *acc = lcaActionSheet.actionSheetOptions[buttonIndex];
            [self signInWithAccount:acc];
        }
    }
}

@end
