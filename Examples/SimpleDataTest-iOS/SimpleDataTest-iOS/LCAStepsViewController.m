//
//  LCAStepsViewController.m
//  SimpleDataTest-iOS
//
//  Created by Tiago Rodrigues on 24/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCAStepsViewController.h"
#import "LCAAppDelegate.h"

@interface LCAStepsViewController ()

- (IBAction)nextStep:(id)sender;

// Step #1
@property (strong, nonatomic) NSDictionary *data1;
@property (weak, nonatomic) IBOutlet UITextView *textField1;
- (IBAction)step1:(id)sender;

// Step #2
@property (strong, nonatomic) NSDictionary *data2;
@property (weak, nonatomic) IBOutlet UITextView *textField2;
- (IBAction)step2:(id)sender;

// Step #3
- (IBAction)step3:(id)sender;

// Step #4
- (IBAction)step4:(id)sender;

// Step #5
@property (strong, nonatomic) NSDictionary *data5;
@property (weak, nonatomic) IBOutlet UITextView *textField5;
- (IBAction)step5:(id)sender;

// Step #6
@property (strong, nonatomic) NSDictionary *data6;
@property (weak, nonatomic) IBOutlet UITextView *textField6;
- (IBAction)step6:(id)sender;

// Step #7
@property (strong, nonatomic) NSDictionary *data7;
@property (weak, nonatomic) IBOutlet UITextView *textField7;
- (IBAction)step7:(id)sender;

// Step #8
@property (strong, nonatomic) NSDictionary *data8;
@property (weak, nonatomic) IBOutlet UITextView *textField8;
- (IBAction)step8:(id)sender;

// Step #9
- (IBAction)step9:(id)sender;

@end

@implementation LCAStepsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"1-put-a_b_c" ofType:@"json"];
    NSData *file1 = [NSData dataWithContentsOfFile:path1];
    self.data1 = [NSJSONSerialization JSONObjectWithData:file1 options:kNilOptions error:nil];
    self.textField1.text = self.data1.description;

    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"2-patch-a_b" ofType:@"json"];
    NSData *file2 = [NSData dataWithContentsOfFile:path2];
    self.data2 = [NSJSONSerialization JSONObjectWithData:file2 options:kNilOptions error:nil];
    self.textField2.text = self.data2.description;

    NSString *path5 = [[NSBundle mainBundle] pathForResource:@"5-put-a_b_c_d" ofType:@"json"];
    NSData *file5 = [NSData dataWithContentsOfFile:path5];
    self.data5 = [NSJSONSerialization JSONObjectWithData:file5 options:kNilOptions error:nil];
    self.textField5.text = self.data5.description;

    NSString *path6 = [[NSBundle mainBundle] pathForResource:@"6-patch-a_b_c" ofType:@"json"];
    NSData *file6 = [NSData dataWithContentsOfFile:path6];
    self.data6 = [NSJSONSerialization JSONObjectWithData:file6 options:kNilOptions error:nil];
    self.textField6.text = self.data6.description;

    NSString *path7 = [[NSBundle mainBundle] pathForResource:@"7-put-a_b_i" ofType:@"json"];
    NSData *file7 = [NSData dataWithContentsOfFile:path7];
    self.data7 = [NSJSONSerialization JSONObjectWithData:file7 options:kNilOptions error:nil];
    self.textField7.text = self.data7.description;

    NSString *path8 = [[NSBundle mainBundle] pathForResource:@"8-put-a" ofType:@"json"];
    NSData *file8 = [NSData dataWithContentsOfFile:path8];
    self.data8 = [NSJSONSerialization JSONObjectWithData:file8 options:kNilOptions error:nil];
    self.textField8.text = self.data8.description;
}

- (IBAction)nextStep:(id)sender
{
    [self performSegueWithIdentifier:@"Segue_2_NextStep" sender:self];
}

- (IBAction)step1:(id)sender
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    [application insertObject:self.data1 atPath:@"a/b/c" withCompletionHandler:^(OBSApplication *application, NSString *path, NSDictionary *object, BOOL inserted, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            UIAlertView *alert = inserted
            ? [[UIAlertView alloc] initWithTitle:@"OK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil]
            : [[UIAlertView alloc] initWithTitle:@"NOK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        });
    }];
}

- (IBAction)step2:(id)sender
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    [application updatePath:@"a/b" withObject:self.data2 completionHandler:^(OBSApplication *application, NSString *path, NSDictionary *object, BOOL updated, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            UIAlertView *alert = updated
            ? [[UIAlertView alloc] initWithTitle:@"OK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil]
            : [[UIAlertView alloc] initWithTitle:@"NOK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        });
    }];
}

- (IBAction)step3:(id)sender
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    [application removePath:@"a/b/c/e/f" withCompletionHandler:^(OBSApplication *application, NSString *path, BOOL deleted, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            UIAlertView *alert = deleted
            ? [[UIAlertView alloc] initWithTitle:@"OK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil]
            : [[UIAlertView alloc] initWithTitle:@"NOK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        });
    }];
}

- (IBAction)step4:(id)sender
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    [application removePath:@"a/b/c/e" withCompletionHandler:^(OBSApplication *application, NSString *path, BOOL deleted, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            UIAlertView *alert = deleted
            ? [[UIAlertView alloc] initWithTitle:@"OK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil]
            : [[UIAlertView alloc] initWithTitle:@"NOK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        });
    }];
}

- (IBAction)step5:(id)sender
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    [application insertObject:self.data5 atPath:@"a/b/c/d" withCompletionHandler:^(OBSApplication *application, NSString *path, NSDictionary *object, BOOL inserted, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            UIAlertView *alert = inserted
            ? [[UIAlertView alloc] initWithTitle:@"OK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil]
            : [[UIAlertView alloc] initWithTitle:@"NOK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        });
    }];
}

- (IBAction)step6:(id)sender
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    [application updatePath:@"a/b/c" withObject:self.data6 completionHandler:^(OBSApplication *application, NSString *path, NSDictionary *object, BOOL updated, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            UIAlertView *alert = updated
            ? [[UIAlertView alloc] initWithTitle:@"OK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil]
            : [[UIAlertView alloc] initWithTitle:@"NOK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        });
    }];
}

- (IBAction)step7:(id)sender
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    [application insertObject:self.data7 atPath:@"a/b/i" withCompletionHandler:^(OBSApplication *application, NSString *path, NSDictionary *object, BOOL inserted, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            UIAlertView *alert = inserted
            ? [[UIAlertView alloc] initWithTitle:@"OK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil]
            : [[UIAlertView alloc] initWithTitle:@"NOK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        });
    }];
}

- (IBAction)step8:(id)sender
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    [application insertObject:self.data8 atPath:@"a" withCompletionHandler:^(OBSApplication *application, NSString *path, NSDictionary *object, BOOL inserted, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            UIAlertView *alert = inserted
            ? [[UIAlertView alloc] initWithTitle:@"OK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil]
            : [[UIAlertView alloc] initWithTitle:@"NOK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        });
    }];
}

- (IBAction)step9:(id)sender
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate showWaitScreen];

    OBSApplication *application = [OBSApplication applicationWithClient:delegate];
    [application removePath:@"" withCompletionHandler:^(OBSApplication *application, NSString *path, BOOL deleted, OBSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate hideWaitScreen];
            UIAlertView *alert = deleted
            ? [[UIAlertView alloc] initWithTitle:@"OK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil]
            : [[UIAlertView alloc] initWithTitle:@"NOK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        });
    }];
}

@end
