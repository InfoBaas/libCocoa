//
//  OBSLocationCentre.m
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 12/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "OBSLocationCentre+.h"

static NSString *const _didUpdateLocationObservers = @"didUpdateLocation";
static NSString *const _didChangeAuthorizationStatusObservers = @"didChangeAuthorizationStatusObservers";
static NSString *const _didStopWithErrorObservers = @"didStopWithErrorObservers";

@implementation OBSLocationCentre

- (id)init
{
    self = [super init];
    if (self) {
        _observers = @{_didUpdateLocationObservers: [NSMutableSet set],
                       _didChangeAuthorizationStatusObservers: [NSMutableSet set],
                       _didStopWithErrorObservers: [NSMutableSet set]};

        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [locationManager setDistanceFilter:kCLDistanceFilterNone];
        [locationManager setDelegate:self];
        _locationManager = locationManager;

        _currentLocation = nil;

        _running = NO;
#if TARGET_OS_IPHONE
        _bgTask = UIBackgroundTaskInvalid;
        _usingLowPower = NO;
#endif
    }
    return self;
}

+ (OBSLocationCentre *)locationCentre
{
    static OBSLocationCentre *locationCentre = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationCentre = [[self alloc] init];
    });
    return locationCentre;
}

- (void)setRunning:(BOOL)running
{
    @synchronized (self.locationManager) {
        if (_running != running && [CLLocationManager locationServicesEnabled]) {
            _running = running;
#if TARGET_OS_IPHONE
            if (_running) {
                if (self.isUsingLowPower) {
                    [self.locationManager startMonitoringSignificantLocationChanges];
                } else {
                    [self.locationManager startUpdatingLocation];
                }
            } else {
                if (self.isUsingLowPower) {
                    [self.locationManager stopMonitoringSignificantLocationChanges];
                } else {
                    [self.locationManager stopUpdatingLocation];
                }
                [self setCurrentLocation:nil];
            }
#elif TARGET_OS_MAC
            if (_running) {
                [self.locationManager startUpdatingLocation];
            } else {
                [self.locationManager stopUpdatingLocation];
                [self setCurrentLocation:nil];
            }
#endif
        }
    }
}

#if TARGET_OS_IPHONE
- (void)applicationDidEnterBackground
{
    [self setUsingLowPower:YES];
}

- (void)applicationDidBecomeActive
{
    [self setUsingLowPower:NO];
}

- (void)setUsingLowPower:(BOOL)usingLowPower
{
    @synchronized (self.locationManager) {
        if (_usingLowPower != usingLowPower && [CLLocationManager significantLocationChangeMonitoringAvailable]) {
            _usingLowPower = usingLowPower;
            if (self.isRunning) {
                if (_usingLowPower) {
                    [self.locationManager stopUpdatingLocation];
                    [self.locationManager startMonitoringSignificantLocationChanges];
                } else {
                    [self.locationManager stopMonitoringSignificantLocationChanges];
                    [self didUpdateLocation:_currentLocation];
                    [self.locationManager startUpdatingLocation];
                }
            }
        } else if (!usingLowPower && self.isRunning) {
            [self didUpdateLocation:_currentLocation];
        }
    }
}
#endif

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self didChangeAuthorizationStatus:status];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        [self setRunning:NO];
        [self didStopWithError:error];
    }
    [self setCurrentLocation:nil];
    [self didUpdateLocation:_currentLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (!self.isRunning)
        return;

#if TARGET_OS_IPHONE
    _bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
    }];
#endif

    CLLocation *currentLocation = [self currentLocation];
    CLLocation *lastLocation = [locations lastObject];
    [self setCurrentLocation:lastLocation];

    if (obs_settings_get_sendLocationUpdates()) {
        CLLocationCoordinate2D lastCoordinates = [lastLocation coordinate];
        CLLocationCoordinate2D currentCoordinates = [currentLocation coordinate];
        if (lastCoordinates.latitude != currentCoordinates.latitude || lastCoordinates.longitude != currentCoordinates.longitude) {
#warning TODO: send location (synch in iOS -- asynch in OS X)
            OBS_NotYetImplemented
        }
    }

    [self didUpdateLocation:_currentLocation];

#if TARGET_OS_IPHONE
    if (_bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    }
#endif
}

#pragma mark - OBSLocationCentreObserver

- (void)didUpdateLocation:(CLLocation *)location
{
#if TARGET_OS_IPHONE
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
#endif
    {
        @synchronized (_observers) {
            NSSet *observers = _observers[_didUpdateLocationObservers];
            for (id<OBSLocationCentreObserver> observer in observers) {
                [observer didUpdateLocation:location];
            }
        }
    }
}

- (void)didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
#if TARGET_OS_IPHONE
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
#endif
    {
        @synchronized (_observers) {
            NSSet *observers = _observers[_didChangeAuthorizationStatusObservers];
            for (id<OBSLocationCentreObserver> observer in observers) {
                [observer didChangeAuthorizationStatus:status];
            }
        }
    }
}

- (void)didStopWithError:(NSError *)error
{
#if TARGET_OS_IPHONE
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
#endif
    {
        @synchronized (_observers) {
            NSSet *observers = _observers[_didStopWithErrorObservers];
            for (id<OBSLocationCentreObserver> observer in observers) {
                [observer didStopWithError:error];
            }
        }
    }
}

#pragma mark - Public

+ (CLLocation *)currentLocation
{
    return [[self locationCentre] currentLocation];
}

+ (void)addObserver:(id<OBSLocationCentreObserver>)observer
{
    OBSLocationCentre *locationCentre = [self locationCentre];
    @synchronized (locationCentre->_observers) {
        if ([observer respondsToSelector:@selector(didUpdateLocation:)])
            [((NSMutableSet *) locationCentre->_observers[_didUpdateLocationObservers]) addObject:observer];

        if ([observer respondsToSelector:@selector(didChangeAuthorizationStatus:)])
            [((NSMutableSet *) locationCentre->_observers[_didChangeAuthorizationStatusObservers]) addObject:observer];

        if ([observer respondsToSelector:@selector(didStopWithError:)])
            [((NSMutableSet *) locationCentre->_observers[_didStopWithErrorObservers]) addObject:observer];
    }
}
+ (void)removeObserver:(id<OBSLocationCentreObserver>)observer
{
    OBSLocationCentre *locationCentre = [self locationCentre];
    @synchronized (locationCentre->_observers) {
        [((NSMutableSet *) locationCentre->_observers[_didUpdateLocationObservers]) removeObject:observer];
        [((NSMutableSet *) locationCentre->_observers[_didChangeAuthorizationStatusObservers]) removeObject:observer];
        [((NSMutableSet *) locationCentre->_observers[_didStopWithErrorObservers]) removeObject:observer];
    }
}

#pragma mark Availability of Services

+ (BOOL)locationServicesEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

+ (BOOL)significantLocationChangeMonitoringAvailable
{
    return [CLLocationManager significantLocationChangeMonitoringAvailable];
}

+ (CLAuthorizationStatus)authorizationStatus
{
    return [CLLocationManager authorizationStatus];
}

#pragma mark Settings

+ (CLLocationAccuracy)desiredAccuracy
{
    return [[[self locationCentre] locationManager] desiredAccuracy];
}
+ (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy
{
    [[[self locationCentre] locationManager] setDesiredAccuracy:desiredAccuracy];
}

+ (CLLocationDistance)distanceFilter
{
    return [[[self locationCentre] locationManager] distanceFilter];
}
+ (void)setDistanceFilter:(CLLocationDistance)distanceFilter
{
    [[[self locationCentre] locationManager] setDistanceFilter:distanceFilter];
}

#pragma mark Update Management

+ (void)startUpdatingLocation
{
    [[self locationCentre] setRunning:YES];
}

+ (void)stopUpdatingLocation
{
    [[self locationCentre] setRunning:NO];
}

#if TARGET_OS_IPHONE

+ (void)setUseLowPowerModeWhenInBackground:(BOOL)useLowPowerMode
{
    OBSLocationCentre *locationCentre = [self locationCentre];
    NSNotificationCenter *notificationCentre = [NSNotificationCenter defaultCenter];

    [notificationCentre removeObserver:locationCentre];

    if (useLowPowerMode) {
        [notificationCentre addObserver:locationCentre selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [notificationCentre addObserver:locationCentre selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
}

#endif

@end
