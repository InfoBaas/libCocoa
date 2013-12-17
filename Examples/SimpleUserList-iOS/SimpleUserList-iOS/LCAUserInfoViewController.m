//
//  LCAUserInfoViewController.m
//  SimpleUserList-iOS
//
//  Created by Tiago Rodrigues on 17/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCAUserInfoViewController.h"

@interface LCAUserInfoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *fileTextView;

@end

@implementation LCAUserInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.user.userId;
    self.emailLabel.text = self.user.userEmail;
    self.nameLabel.text = self.user.userName;
    self.fileTextView.text = self.user.userFile;
}

@end
