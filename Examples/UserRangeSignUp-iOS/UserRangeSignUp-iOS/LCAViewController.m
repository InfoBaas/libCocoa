//
//  LCAViewController.m
//  UserRangeSignUp-iOS
//
//  Created by Tiago Rodrigues on 12/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCAViewController.h"
#import "LCAAppDelegate.h"

@interface LCAViewController ()
<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *appIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *appKeyTextField;

- (IBAction)appIdEditingDidEnd:(id)sender;
- (IBAction)appKeyEditingDidEnd:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *prefixTextField;
@property (weak, nonatomic) IBOutlet UITextField *domainTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmTextField;

@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;

@property (weak, nonatomic) IBOutlet UIStepper *fromStepper;
@property (weak, nonatomic) IBOutlet UIStepper *toStepper;

@property (assign, nonatomic) NSUInteger from;
@property (assign, nonatomic) NSUInteger to;

- (IBAction)updateFromValue:(id)sender;
- (IBAction)updateToValue:(id)sender;

- (IBAction)signUpRange:(id)sender;

@end

@implementation LCAViewController

- (void)setFrom:(NSUInteger)from
{
    _from = from;
    self.fromLabel.text = [NSString stringWithFormat:@"%u", _from];
    self.toStepper.minimumValue = _from;
}

- (void)setTo:(NSUInteger)to
{
    _to = to;
    self.toLabel.text = [NSString stringWithFormat:@"%u", _to];
    self.fromStepper.maximumValue = _to;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appIdTextField.text = delegate.appId;
    self.appKeyTextField.text = delegate.appKey;

    self.fromStepper.minimumValue = 0;
    self.toStepper.maximumValue = 9999;
    self.from = self.fromStepper.value = 0;
    self.to = self.toStepper.value = 99;
    self.fromStepper.stepValue = 1;
    self.toStepper.stepValue = 1;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (IBAction)updateFromValue:(id)sender
{
    self.from = self.fromStepper.value;
}

- (IBAction)updateToValue:(id)sender
{
    self.to = self.toStepper.value;
}

- (IBAction)signUpRange:(id)sender
{
    if (![self.passwordTextField.text isEqualToString:self.confirmTextField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"password ≠ confirmation" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }

    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];

    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    OBSAccount *account = [application applicationAccount];

    NSUInteger __block total = self.to - self.from + 1;
    NSUInteger __block ok = 0;
    NSUInteger __block nok = 0;
    NSMutableSet *set = [NSMutableSet setWithCapacity:total];

    for (NSUInteger i = self.from; i <= self.to; i++) {
        NSString *email = [NSString stringWithFormat:@"%@%u@%@", self.prefixTextField.text, i, self.domainTextField.text];
        NSString *name = [NSString stringWithFormat:@"J. %u Doe", i];
        [account signUpWithEmail:email password:self.passwordTextField.text userName:name userFile:nil completionHandler:^(OBSAccount *account, BOOL signedUp, OBSSession *session, OBSError *error) {
            @synchronized (set) {
                [set addObject:@{@"email": email, @"sign up": @(signedUp)}];
                if (signedUp)
                    ok++;
                else
                    nok++;
                if (--total == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:@"DONE" message:[NSString stringWithFormat:@"OK\n%u\n\nNOK\n%u", ok, nok] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
                        NSLog(@"%@", set);
                        [delegate hideWaitScreen];
                    });
                }
            }
        }];
    }
}

@end
