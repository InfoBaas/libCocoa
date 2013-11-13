//
//  OBSLocationCentre.h
//  OpenBaaS
//
//  Created by Tiago Rodrigues on 12/11/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#pragma mark - OBSLocationCentreObserver
@protocol OBSLocationCentreObserver <NSObject>

@optional

/**
 *  Tells the observer that a new location is available.
 *
 *  Implementation of this method is optional but recommended.
 *
 *  @param location The new location data.
 *
 *  @note On iOS, location centre will not call this method if the application
 *        is running in the backgroung. Call applicationDidBecomeActive after the
 *        application becomes active if you need to trigger a call to this method.
 */
- (void)didUpdateLocation:(CLLocation *)location;

/**
 *  Tells the observer that the authorization status for the application changed.
 *
 *  This method is called whenever the application’s ability to use location
 *  services changes. Changes can occur because the user allowed or denied the
 *  use of location services for your application or for the system as a whole.
 *
 *  @param status The new authorization status for the application.
 *
 *  @note On iOS, location centre will not call this method if the application
 *        is running in the backgroung.
 */
- (void)didChangeAuthorizationStatus:(CLAuthorizationStatus)status;

/**
 *  Tells the observer that the location centre has stopped updating locations
 *  due to the occurrence of an error.
 *
 *  If the user denies your application’s use of the location service, this
 *  method reports a kCLErrorDenied error. Upon receiving such an error, you
 *  should stop the location service.
 *
 *  @param error The error object containing the reason updatings have stopped.
 *
 *  @note On iOS, location centre will not call this method if the application
 *        is running in the backgroung.
 */
- (void)didStopWithError:(NSError *)error;

@end

#pragma mark - OBSLocationCentre
@interface OBSLocationCentre : NSObject

/**
 *  Returns an object with the device's current location.
 *
 *  @return The current location of the device, or `nil` if the current location
 *          is unknown.
 */
+ (CLLocation *)currentLocation;

/**
 *  Adds an observer to location centre.
 *
 *  @param observer The observer to be added.
 */
+ (void)addObserver:(id<OBSLocationCentreObserver>)observer;

/**
 *  Removes an observer to location centre.
 *
 *  @param observer The observer to be removed.
 */
+ (void)removeObserver:(id<OBSLocationCentreObserver>)observer;

#pragma mark Availability of Services

/**
 *  Returns a Boolean value indicating whether location services are enabled on
 *  the device.
 *
 *  @return YES if location services are enabled; NO if they are not.
 */
+ (BOOL)locationServicesEnabled;

/**
 *  Returns a Boolean value indicating whether significant location change
 *  tracking is available.
 *
 *  @return YES if location change monitoring is available; NO if it is not.
 */
+ (BOOL)significantLocationChangeMonitoringAvailable;

/**
 *  Returns the application's authorization status for using location services.
 *
 *  @return A value indicating whether the application is authorized to use
 *          location services.
 */
+ (CLAuthorizationStatus)authorizationStatus;

#pragma mark Settings

/**
 *  The desired location accuracy.
 *
 *  The location centre will try to achieve your desired accuracy. However, it
 *  is not guaranteed.
 *
 *  To optimize power performance, be sure to specify an appropriate accuracy
 *  for your usage scenario (eg, use a large accuracy value when only a coarse
 *  location is needed). Use kCLLocationAccuracyBest to achieve the best
 *  possible accuracy. Use kCLLocationAccuracyBestForNavigation for navigation.
 *  By default, kCLLocationAccuracyNearestTenMeters is used.
 *
 *  @return The desired location accuracy.
 */
+ (CLLocationAccuracy)desiredAccuracy;

/**
 *  Sets the desired location accuracy.
 *
 *  @param desiredAccuracy The desired location accuracy.
 */
+ (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy;

/**
 *  The minimum distance (measured in meters) a device must move horizontally
 *  before an update event is generated.
 *
 *  This distance is measured relative to the previously delivered location.
 *  Use the value kCLDistanceFilterNone to be notified of all movements. The
 *  default value of this property is kCLDistanceFilterNone.
 *
 *  @return The minimum distance of horizontal movement needed before an update
 *          event is generated.
 */
+ (CLLocationDistance)distanceFilter;

/**
 *  Sets the minimum distance (measured in meters) a device must move
 *  horizontally before an update event is generated.
 *
 *  @param distanceFilter The minimum distance of horizontal movement needed before an update
 *          event is generated.
 */
+ (void)setDistanceFilter:(CLLocationDistance)distanceFilter;

#pragma mark Update Management

/**
 *  Starts the generation of updates that report the user’s current location.
 *
 *  If you start this service and your application is suspended, the system
 *  stops the delivery of events until your application starts running again
 *  (either in the foreground or background). If your application is terminated,
 *  the delivery of new location events stops altogether. Therefore, if your
 *  application needs to receive location events while in the background, it
 *  must include the `UIBackgroundModes` key (with the `location` value) in its
 *  Info.plist file
 *
 *  @note On iOS, observers will not be notified of location updates if the
 *        application is running in the background.
 *
 *        To trigger a notification after the application becomes active call
 *        applicationDidBecomeActive.
 *
 *  @warning Location services can drain the devices battery very quickly. For
 *           iOS applications that do not need a regular stream of location
 *           events, consider using useLowPowerModeWhenInBackground:.
 */
+ (void)startUpdatingLocation;

/**
 *  Stops the generation of updates that report the user’s current location.
 */
+ (void)stopUpdatingLocation;

#if TARGET_OS_IPHONE

/**
 *  Call this method to set whether location centre should or shouldn't use low
 *  power mode when the application is running in the background.
 *
 *  @param useLowPowerMode Whether location centre should or shouldn't use low
 *         power mode when running in the background
 *
 *  @note Apps can expect a notification as soon as the device moves 500 meters
 *        or more from its previous notification. It should not expect
 *        notifications more frequently than once every five minutes. If the
 *        device is able to retrieve data from the network, the location manager
 *        is much more likely to deliver notifications in a timely manner.
 *
 *  @available iOS
 */
+ (void)setUseLowPowerModeWhenInBackground:(BOOL)useLowPowerMode;

#endif

@end
