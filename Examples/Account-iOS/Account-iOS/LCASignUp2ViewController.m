//
//  LCASignUp2ViewController.m
//  Account-iOS
//
//  Created by Tiago Rodrigues on 04/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCASignUp2ViewController.h"
#import "LCAAppDelegate.h"

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

#warning TODO present a wait screen
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    OBSAccount *account = [application applicationAccount];
    [account signUpWithEmail:self.emailTextField.text password:self.passwordTextField.text userName:self.userNameTextField.text userFile:userFile completionHandler:^(OBSAccount *account, OBSSession *session, OBSError *error) {
#warning TODO dismiss the wait screen and show session or error
    }];
}

@end
