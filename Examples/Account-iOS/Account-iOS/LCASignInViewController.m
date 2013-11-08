//
//  LCASignInViewController.m
//  Account-iOS
//
//  Created by Tiago Rodrigues on 04/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCASignInViewController.h"
#import "LCAAppDelegate.h"
#import "LCASessionInfoViewController.h"

@interface LCASignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)signIn:(id)sender;

@end

@implementation LCASignInViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Segue_2_SessionInfo"]) {
        LCASessionInfoViewController *controller = [segue destinationViewController];
        controller.session = sender;
    }
}

- (IBAction)signIn:(id)sender
{
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];

    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];

    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    OBSAccount *account = [application applicationAccount];
    [account signInWithEmail:self.emailTextField.text password:self.passwordTextField.text completionHandler:^(OBSAccount *account, BOOL signedIn, OBSSession *session, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            if (signedIn && session) {
                [self performSegueWithIdentifier:@"Segue_2_SessionInfo" sender:session];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
        });
    }];
}

@end
