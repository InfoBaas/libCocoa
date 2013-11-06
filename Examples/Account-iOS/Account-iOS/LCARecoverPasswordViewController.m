//
//  LCARecoverPasswordViewController.m
//  Account-iOS
//
//  Created by Tiago Rodrigues on 04/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCARecoverPasswordViewController.h"
#import "LCAAppDelegate.h"

@interface LCARecoverPasswordViewController ()

- (IBAction)recoverPassword:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation LCARecoverPasswordViewController

- (IBAction)recoverPassword:(id)sender
{
    [self.emailTextField resignFirstResponder];

#warning TODO present a wait screen
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    OBSAccount *account = [application applicationAccount];
    [account recoverPasswordForEmail:self.emailTextField.text withCompletionHandler:^(OBSAccount *account, BOOL sent, OBSError *error) {
#warning TODO dismiss the wait screen
        if (sent) {
#warning TODO ask to be dismissed
#warning TODO show confirmation to user
        } else {
#warning TODO show error to user
        }
    }];
}

@end
