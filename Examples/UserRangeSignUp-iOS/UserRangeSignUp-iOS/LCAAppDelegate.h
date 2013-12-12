//
//  LCAAppDelegate.h
//  UserRangeSignUp-iOS
//
//  Created by Tiago Rodrigues on 12/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCAAppDelegate : UIResponder <UIApplicationDelegate, OBSClientProtocol>

@property (strong, nonatomic) UIWindow *window;
- (void)showWaitScreen;
- (void)hideWaitScreen;

@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *appKey;

@end
