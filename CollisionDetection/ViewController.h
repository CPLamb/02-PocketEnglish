//
//  ViewController.h
//  CollisionDetection
//
//  Created by Brian Smith on 2/23/12.
//  Copyright (c) 2012 Orbotix Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RKDeviceAsyncData;

@interface ViewController : UIViewController {
    
    UIView      *unconnectedView;
    
    // collision UI
    UILabel     *xAccelerationLabel;
    UILabel     *yAccelerationLabel;
    UILabel     *zAccelerationLabel;
    UILabel     *xAxisLabel;
    UILabel     *yAxisLabel;
    UILabel     *xPowerLabel;
    UILabel     *yPowerLabel;
    UILabel     *speedLabel;
    UILabel     *timeStampLabel;
    UIButton    *driveButton;
    UIButton    *aimButton;
    UIButton *reboundButton;
    UISlider    *controlSpeedSlider;
    UISlider    *controlHeadingSlider;
    UILabel     *controlSpeedLabel;
    UILabel     *controlHeadingLabel;
    UILabel *messageLabel;
    UILabel *yLabel;
    UILabel *xLabel;
    UILabel *zLabel;
    
    // variables for driving
    BOOL        driving;
    BOOL        aiming;
    float spheroHeading;
    BOOL rebound;
}

@property (nonatomic, retain) IBOutlet UIView       *unconnectedView;

// collision UI
@property (nonatomic, retain) IBOutlet UILabel      *xAccelerationLabel;
@property (nonatomic, retain) IBOutlet UILabel      *yAccelerationLabel;
@property (nonatomic, retain) IBOutlet UILabel      *zAccelerationLabel;
@property (nonatomic, retain) IBOutlet UILabel      *xAxisLabel;
@property (nonatomic, retain) IBOutlet UILabel      *yAxisLabel;
@property (nonatomic, retain) IBOutlet UILabel      *xPowerLabel;
@property (nonatomic, retain) IBOutlet UILabel      *yPowerLabel;
@property (nonatomic, retain) IBOutlet UILabel      *speedLabel;
@property (nonatomic, retain) IBOutlet UILabel      *timeStampLabel;
@property (nonatomic, retain) IBOutlet UIButton     *driveButton;
@property (nonatomic, retain) IBOutlet UIButton     *aimButton;
@property (nonatomic, retain) IBOutlet UISlider     *controlSpeedSlider;
@property (nonatomic, retain) IBOutlet UISlider     *controlHeadingSlider;
@property (nonatomic, retain) IBOutlet UILabel      *controlSpeedLabel;
@property (nonatomic, retain) IBOutlet UILabel      *controlHeadingLabel;
@property (nonatomic, retain) IBOutlet UILabel   *messageLabel;
@property (nonatomic, retain) IBOutlet UILabel   *yLabel;
@property (nonatomic, retain) IBOutlet UILabel   *xLabel;
@property (nonatomic, retain) IBOutlet UILabel   *zLabel;
@property (nonatomic, retain) IBOutlet UIButton  *reboundButton;

- (IBAction)drive:(id)sender;
- (IBAction)calibrate:(id)sender;
- (IBAction)configureDetection:(id)sender;
- (IBAction)speedValueChanged:(id)sender;
- (IBAction)headingValueChanged:(id)sender;
- (IBAction)rebound:(id)sender;

- (void)presentConfigurationView;

- (void)setDriving:(BOOL)state;
- (void)setAiming:(BOOL)state;
- (void)resetHeading;
- (void)resetSpeed;

- (void)handleApplicationDidBecomeActive:(NSNotification *)notification;
- (void)handleApplicationWillResignActive:(NSNotification *)notification;
- (void)handleRobotOnline:(NSNotification *)notification;
- (void)handleAsyncData:(RKDeviceAsyncData *)asyncData;

@end
