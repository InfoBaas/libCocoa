//
//  LCASessionInfoViewController.m
//  Account-iOS
//
//  Created by Tiago Rodrigues on 06/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCASessionInfoViewController.h"
#import "LCAAppDelegate.h"

@interface LCASessionInfoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userEmailLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *userFileTextView;
- (IBAction)signOut:(id)sender;
- (IBAction)saveSession:(id)sender;

@end

@implementation LCASessionInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.userIdLabel.text = [NSString stringWithFormat:@"id: %@", self.session.user.userId];
    self.userEmailLabel.text = [NSString stringWithFormat:@"e-mail: %@", self.session.user.userEmail];
    self.userNameLabel.text = [NSString stringWithFormat:@"name: %@", self.session.user.userName];
    self.userFileTextView.text = [NSString stringWithFormat:@"%@", self.session.user.userFile];
}

- (IBAction)signOut:(id)sender
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];

    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    OBSAccount *account = [application applicationAccount];
    [account signOutFromSession:self.session closingAllOthers:YES withCompletionHandler:^(OBSAccount *account, BOOL signedOut, OBSSession *session, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            if (signedOut) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
        });
    }];
}

- (IBAction)saveSession:(id)sender
{
    [self.session setAsCurrentSession];
}

@end
