//
//  LCAAppDelegate.h
//  Account-iOS
//
//  Created by Tiago Rodrigues on 04/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCAAppDelegate : UIResponder <UIApplicationDelegate, OBSClientProtocol>

@property (strong, nonatomic) UIWindow *window;
- (void)showWaitScreen;
- (void)hideWaitScreen;

@property (strong, nonatomic) NSString *appId;

@end
