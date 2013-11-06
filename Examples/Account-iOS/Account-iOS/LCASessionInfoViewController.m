//
//  LCASessionInfoViewController.m
//  Account-iOS
//
//  Created by Tiago Rodrigues on 06/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCASessionInfoViewController.h"

@interface LCASessionInfoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userEmailLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *userFileTextView;
- (IBAction)signOut:(id)sender;

@end

@implementation LCASessionInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.userIdLabel.text = [NSString stringWithFormat:@"id: %@", self.session.user.userId];
    self.userEmailLabel.text = [NSString stringWithFormat:@"e-mail: %@", self.session.user.userEmail];
    self.userNameLabel.text = [NSString stringWithFormat:@"name: %@", self.session.user.userName];
    self.userFileTextView.text = self.session.user.userFile;
}

- (IBAction)signOut:(id)sender
{
#warning TODO sign out
}

@end
