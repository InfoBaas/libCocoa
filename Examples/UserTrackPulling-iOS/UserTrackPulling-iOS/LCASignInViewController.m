//
//  LCASignInViewController.m
//  UserTrackPulling-iOS
//
//  Created by Tiago Rodrigues on 26/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCASignInViewController.h"
#import "LCAAppDelegate.h"
#import "LCATrackSessionViewController.h"

@interface LCASignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *appIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *appKeyTextField;

- (IBAction)appIdEditingDidEnd:(id)sender;
- (IBAction)appKeyEditingDidEnd:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)signIn:(id)sender;

@end

@implementation LCASignInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appIdTextField.text = delegate.appId;
    self.appKeyTextField.text = delegate.appKey;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Segue_2_Tracking"]) {
        LCATrackSessionViewController *controller = [segue destinationViewController];
        controller.session = sender;
    }
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

- (IBAction)signIn:(id)sender
{
    [self.appIdTextField resignFirstResponder];
    [self.appKeyTextField resignFirstResponder];
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
                [session setAsCurrentSession];
                [self performSegueWithIdentifier:@"Segue_2_Tracking" sender:session];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
        });
    }];
}

@end
