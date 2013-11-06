//
//  LCASignInViewController.m
//  Account-iOS
//
//  Created by Tiago Rodrigues on 04/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCASignInViewController.h"
#import "LCAAppDelegate.h"

@interface LCASignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)signIn:(id)sender;

@end

@implementation LCASignInViewController

- (IBAction)signIn:(id)sender
{
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];

#warning TODO present a wait screen
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    OBSAccount *account = [application applicationAccount];
    [account signInWithEmail:self.emailTextField.text password:self.passwordTextField.text completionHandler:^(OBSAccount *account, OBSSession *session, OBSError *error) {
#warning TODO dismiss the wait screen and show session or error
    }];
}

@end
