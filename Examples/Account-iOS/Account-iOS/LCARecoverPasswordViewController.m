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

    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];

    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    OBSAccount *account = [application applicationAccount];
    [account recoverPasswordForEmail:self.emailTextField.text withCompletionHandler:^(OBSAccount *account, BOOL sent, OBSError *error) {
        [delegate hideWaitScreen];
        if (sent) {
            [self performSegueWithIdentifier:@"Unwind_backhome" sender:self];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check Your Inbox" message:@"A recovery e-mail has been sent to your e-mail." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
}

@end
