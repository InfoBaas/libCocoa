//
//  LCAAppDelegate.h
//  SimpleDataSearch-iOS
//
//  Created by Tiago Rodrigues on 28/01/2014.
//  Copyright (c) 2014 Infosistema. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCAAppDelegate : UIResponder <UIApplicationDelegate, OBSClientProtocol>

@property (strong, nonatomic) UIWindow *window;
- (void)showWaitScreen;
- (void)hideWaitScreen;

@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *appKey;

@end
