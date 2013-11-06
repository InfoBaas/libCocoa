//
//  LCASignUp1ViewController.m
//  Account-iOS
//
//  Created by Tiago Rodrigues on 04/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCASignUp1ViewController.h"
#import "LCAAppDelegate.h"
#import "LCASessionInfoViewController.h"

@interface LCASignUp1ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmTextField;
- (IBAction)signUp:(id)sender;

@end

@implementation LCASignUp1ViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Segue_2_SessionInfo"]) {
        LCASessionInfoViewController *controller = [segue destinationViewController];
        controller.session = sender;
    }
}

- (IBAction)signUp:(id)sender
{
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmTextField resignFirstResponder];

    if (![self.passwordTextField.text isEqualToString:self.confirmTextField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"password ≠ confirmation" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }

    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];

    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    OBSAccount *account = [application applicationAccount];
    [account signUpWithEmail:self.emailTextField.text password:self.passwordTextField.text completionHandler:^(OBSAccount *account, OBSSession *session, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            if (session) {
                [self performSegueWithIdentifier:@"Segue_2_SessionInfo" sender:session];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
        });
    }];
}

@end
