//
//  OBSLocationCentre+.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 12/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSLocationCentre.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@interface OBSLocationCentre ()
<OBSLocationCentreObserver,CLLocationManagerDelegate>
{
#if TARGET_OS_IPHONE
    UIBackgroundTaskIdentifier _bgTask;
#endif

    CLLocation *_currentLocation;

    NSDictionary *_observers;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign, getter = isRunning) BOOL running;

#if TARGET_OS_IPHONE
@property (nonatomic, assign, getter = isUsingLowPower) BOOL usingLowPower;
#endif

@property (nonatomic, strong) CLLocation *currentLocation;

+ (OBSLocationCentre *)locationCentre;

#if TARGET_OS_IPHONE
- (void)applicationDidEnterBackground;
- (void)applicationDidBecomeActive;
#endif

@end
