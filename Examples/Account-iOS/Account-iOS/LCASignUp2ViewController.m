//
//  LCASignUp2ViewController.m
//  Account-iOS
//
//  Created by Tiago Rodrigues on 04/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCASignUp2ViewController.h"
#import "LCAAppDelegate.h"
#import "LCASessionInfoViewController.h"

@interface LCASignUp2ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
- (IBAction)signUp:(id)sender;

@end

@implementation LCASignUp2ViewController

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
    [self.userNameTextField resignFirstResponder];
    [self.phoneNumberTextField resignFirstResponder];
    [self.countryTextField resignFirstResponder];

    if (![self.passwordTextField.text isEqualToString:self.confirmTextField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"password ≠ confirmation" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }

    NSDictionary *userFileDic = @{@"phone number": self.phoneNumberTextField.text,
                                  @"country": self.countryTextField.text};
    NSData *userFileData = [NSJSONSerialization dataWithJSONObject:userFileDic options:kNilOptions error:nil];
    NSString *userFile = [[NSString alloc] initWithData:userFileData encoding:NSUTF8StringEncoding];

    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];

    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    OBSAccount *account = [application applicationAccount];
    [account signUpWithEmail:self.emailTextField.text password:self.passwordTextField.text userName:self.userNameTextField.text userFile:userFile completionHandler:^(OBSAccount *account, BOOL signedUp, OBSSession *session, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            if (signedUp) {
                if (session) {
                    [self performSegueWithIdentifier:@"Segue_2_SessionInfo" sender:session];
                } else if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                } else {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check Your Inbox" message:@"You need to confirm your e-mail." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
        });
    }];
}

@end
