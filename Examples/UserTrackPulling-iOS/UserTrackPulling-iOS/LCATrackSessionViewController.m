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

@end
