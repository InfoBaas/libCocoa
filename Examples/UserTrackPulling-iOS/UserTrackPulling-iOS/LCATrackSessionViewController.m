//
//  LCATrackSessionViewController.m
//  UserTrackPulling-iOS
//
//  Created by Tiago Rodrigues on 26/12/2013.
//  Copyright (c) 2013 Infosistema. All rights reserved.
//

#import "LCATrackSessionViewController.h"

@interface LCATrackSessionViewController ()
<OBSLocationCentreObserver>

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *baseLabel;
@property (weak, nonatomic) IBOutlet UISwitch *useBaseSwitch;

- (IBAction)useCurrentAsBase:(id)sender;
- (IBAction)forgetBase:(id)sender;
- (IBAction)useBase:(id)sender;

@property (strong, nonatomic) NSCondition *condition;
@property (assign, nonatomic) BOOL run;

@end

@implementation LCATrackSessionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setRun:YES];
    [self setCondition:[[NSCondition alloc] init]];

    [OBSLocationCentre setUseLowPowerModeWhenInBackground:YES];
    [OBSLocationCentre setSessionToTrack:self.session];
//    [OBSLocationCentre addObserver:self];
    [OBSLocationCentre startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSCondition *condition = self.condition;
        while ([self run]) {
            NSLog(@"1");
            [condition lock];
            [self.session.user updateUserWithCompletionHandler:^(OBSUser *user, OBSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![self run])
                        return;

                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                        [alert show];
                        return;
                    }

                    self.locationLabel.text = self.session.user.userLastLocation.description;
                    self.baseLabel.text = self.session.user.userBaseLocation.description;
                    self.useBaseSwitch.on = self.session.user.usesBaseLocation;

                    NSLog(@"2");
                    [condition lock];
                    [condition signal];
                    [condition unlock];
                });
            }];
            [condition wait];
            [condition unlock];
            NSLog(@"3");

            if (![self run])
                break;

            [condition lock];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"4");
                [NSThread sleepForTimeInterval:60];
                NSLog(@"5");
                [condition lock];
                [condition signal];
                [condition unlock];
            });
            [condition wait];
            [condition unlock];
            NSLog(@"6");
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.condition lock];
    [self setRun:NO];
    [self.condition signal];
    [self.condition unlock];

    [OBSLocationCentre stopUpdatingLocation];
    [OBSLocationCentre removeObserver:self];
}

- (void)didUpdateLocation:(CLLocation *)location
{
    NSLog(@"\n**********************"
          "\n*** didUpdateLocation:"
          "\n%@", location);
}

- (IBAction)useCurrentAsBase:(id)sender
{
    [self.session.user setBaseLocation:[OBSLocationCentre currentLocation] withCompletionHandler:^(OBSUser *user, CLLocation *location, OBSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                return;
            });
        }
    }];
}

- (IBAction)forgetBase:(id)sender
{
    [self.session.user setBaseLocation:nil withCompletionHandler:^(OBSUser *user, CLLocation *location, OBSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                return;
            });
        }
    }];
}

- (IBAction)useBase:(id)sender
{
    [self.session.user useBaseLocation:self.useBaseSwitch.on withCompletionHandler:^(OBSUser *user, BOOL useBaseLocation, OBSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                return;
            });
        }
    }];
}

@end
