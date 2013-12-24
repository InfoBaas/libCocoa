//
//  LCADataViewController.m
//  SimpleDataTest-iOS
//
//  Created by Tiago Rodrigues on 24/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCADataViewController.h"
#import "LCAAppDelegate.h"

@interface LCADataViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textField;
- (IBAction)close:(id)sender;

@end

@implementation LCADataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textField.text = [NSString string];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    [application readPath:@"" withQueryDictionary:nil completionHandler:^(OBSApplication *application, NSString *path, id data, id metadata, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            } else {
                self.textField.text = [NSString stringWithFormat:@"** DATA\n%@\n** METADATA\n%@", data, metadata];
            }
        });
    }];
}

- (IBAction)close:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
