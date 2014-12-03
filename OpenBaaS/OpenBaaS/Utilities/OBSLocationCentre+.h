//
//  OBSLocationCentre+.h
//  OpenBaaS
//
/*****************************************************************************************
 Infosistema - Lib-Cocoa
 Copyright(C) 2002-2014 Infosistema, S.A.
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU Affero General Public License for more details.
 You should have received a copy of the GNU Affero General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 www.infosistema.com
 info@openbaas.com
 Av. José Gomes Ferreira, 11 3rd floor, s.34
 Miraflores
 1495-139 Algés Portugal
 ****************************************************************************************/

#import "OBSLocationCentre.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@class OBSSession;

@interface OBSLocationCentre ()
<OBSLocationCentreObserver,CLLocationManagerDelegate>
{
#if TARGET_OS_IPHONE
    UIBackgroundTaskIdentifier _bgTask;
#endif

    CLLocation *_currentLocation;

    NSDictionary *_observers;
}

@property (nonatomic, strong) OBSSession *trackedSession;

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
