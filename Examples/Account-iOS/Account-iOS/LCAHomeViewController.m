//
//  LCAHomeViewController.m
//  Account-iOS
//
//  Created by Tiago Rodrigues on 04/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCAHomeViewController.h"
#import "LCAAppDelegate.h"

@interface LCAHomeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *appIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *appKeyTextField;

- (IBAction)appIdEditingDidEnd:(id)sender;
- (IBAction)appKeyEditingDidEnd:(id)sender;

- (IBAction)openSavedSession:(id)sender;
- (IBAction)backhome:(UIStoryboardSegue *)sender;

@end

@implementation LCAHomeViewController

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

    [OBSSession openCurrentSessionWithClient:delegate andCompletionHandler:^(BOOL opened, OBSSession *session, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            if (opened && session) {
                [self performSegueWithIdentifier:@"Segue_2_SessionInfo" sender:session];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
        });
    }];
}

- (void)backhome:(UIStoryboardSegue *)sender
{}

@end
