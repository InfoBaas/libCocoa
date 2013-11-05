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
- (IBAction)backhome:(UIStoryboardSegue *)sender;

@end

@implementation LCAHomeViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LCAAppDelegate *delegate = (LCAAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.appId = self.appIdTextField.text;
}

- (void)backhome:(UIStoryboardSegue *)sender
{}

@end
