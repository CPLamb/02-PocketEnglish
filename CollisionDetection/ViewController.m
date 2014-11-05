//
//  ViewController.m
//  CollisionDetection
//
//  Created by Brian Smith on 2/23/12.
//  Copyright (c) 2012 Orbotix Inc. All rights reserved.
//

#import <RobotKit/RobotKit.h>
#import <CoreMotion/CoreMotion.h>

#import "ViewController.h"
#import "ConfigurationViewController.h"


@implementation ViewController

@synthesize unconnectedView;

// collision UI
@synthesize xAccelerationLabel;
@synthesize yAccelerationLabel;
@synthesize zAccelerationLabel;
@synthesize xAxisLabel;
@synthesize yAxisLabel;
@synthesize xPowerLabel;
@synthesize yPowerLabel;
@synthesize speedLabel;
@synthesize timeStampLabel;
@synthesize driveButton;
@synthesize aimButton;
@synthesize controlSpeedSlider;
@synthesize controlHeadingSlider;
@synthesize controlSpeedLabel;
@synthesize controlHeadingLabel;

@synthesize messageLabel;
@synthesize yLabel;
@synthesize xLabel;
@synthesize zLabel;
@synthesize reboundButton;

//private accelerometer values
float accelY;
float accelX;
float accelZ;
NSTimer *loopTimer;     // Timer that allows 'english' to be placed on the ball

- (void)drive:(id)sender
{

    if (driving) {              // stops the ball
        [self setDriving:NO];
        [RKRollCommand sendStop];
        [self resetSpeed];
        [self.driveButton setTitle:@"Shoot" forState:UIControlStateNormal];
        [self resetInitialState];
    // stops the loop timer
        [loopTimer invalidate];
        
    } else {                    // starts the ball
        [self setDriving:YES];
        spheroHeading = self.controlHeadingSlider.value;
        [RKRollCommand sendCommandWithHeading:spheroHeading
                                     velocity:self.controlSpeedSlider.value];
        [self.driveButton setTitle:@"Stop" forState:UIControlStateNormal];
        
    // Goto the looping method to change heading
        while (driving) {
        [self startLooping];
        }
    }
}

- (void)calibrate:(id)sender
{
    if (!aiming) {
        [self resetSpeed];
        [self setAiming:YES];
        [RKBackLEDOutputCommand sendCommandWithBrightness:1.0];
    } else {
        [self setAiming:NO];
        [RKBackLEDOutputCommand sendCommandWithBrightness:0.0];
        [RKCalibrateCommand sendCommandWithHeading:0.0];
    }
    [self resetHeading];
}

- (void)configureDetection:(id)sender
{
    if (driving) {
        [RKRollCommand sendStop];
        [self setDriving:NO];
    } else if (aiming) {
        [self setAiming:NO];
        [RKBackLEDOutputCommand sendCommandWithBrightness:0.0];
    }
    [RKConfigureCollisionDetectionCommand sendCommandToStopDetection];
    [self presentConfigurationView];
}

- (void)speedValueChanged:(UISlider *)sender
{
    float speed = sender.value;
    if (driving) {
        [RKRollCommand sendCommandWithHeading:self.controlHeadingSlider.value
                                     velocity:speed];
    }
    self.controlSpeedLabel.text = [NSString stringWithFormat:@"%.3f", speed];
}

- (void)headingValueChanged:(UISlider *)sender
{
    float heading = sender.value;
    if (driving) {
        [RKRollCommand sendCommandWithHeading:heading
                                     velocity:self.controlSpeedSlider.value];
    } else if (aiming) {
        [RKRollCommand sendCommandWithHeading:heading velocity:0.0];
    }
    self.controlHeadingLabel.text = [NSString stringWithFormat:@"%.0f°", heading];
}

- (void)presentConfigurationView
{
    ConfigurationViewController *viewController = 
        [[ConfigurationViewController alloc] initWithNibName:nil bundle:nil];
    
    [self presentModalViewController:viewController animated:YES];
}

- (void)setDriving:(BOOL)state
{
    if (state) {
        driving = YES;
        self.aimButton.enabled = NO;
    } else {
        driving = NO;
        self.aimButton.enabled = YES;
    }
}

- (void)setAiming:(BOOL)state
{
    if (state) {
        aiming = YES;
        self.driveButton.enabled = NO;
        self.controlSpeedSlider.enabled = NO;
    } else {
        aiming = NO;
        self.driveButton.enabled = YES;
        self.controlSpeedSlider.enabled = YES;
    }
}

- (void)resetHeading
{
    self.controlHeadingLabel.text = @"0°";
    self.controlHeadingSlider.value = 0.0;
}

- (void)resetSpeed
{
    self.controlSpeedLabel.text = @"0.0";
//    self.controlSpeedSlider.value = 0.0;
}

#pragma mark - Custom CPL methods

- (IBAction)rebound:(id)sender {
    NSLog(@"Sets the ball to either rebound or stop after a collision");
    
    if (rebound) {              // ball rebounds after collision
        [self.reboundButton setTitle:@"Stops" forState:UIControlStateNormal];
        rebound = NO;

    } else {                    // ball stops after collision
//        [RKRollCommand sendStop];
        [self.reboundButton setTitle:@"Rebounds" forState:UIControlStateNormal];
        rebound = YES;

    }
}


- (void)startLooping {
//    NSLog(@"Starts a timer which executes applyEnglish every 0.N seconds");
    
    loopTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                     target:self
                                   selector:@selector(applyEnglish)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)incrementHeading {
//    NSLog(@"Incrementing");
    
    if (spheroHeading == 360.0) spheroHeading = 0.0;    // prevents out of limits 0.0 - 360.0
    spheroHeading = spheroHeading + 1.0;
    [RKRollCommand sendCommandWithHeading:spheroHeading
                                 velocity:self.controlSpeedSlider.value];
    self.controlHeadingLabel.text = [NSString stringWithFormat:@"%f3.0", spheroHeading];
}

- (void)decrementHeading {
//    NSLog(@"Decrementing");
    
    if (spheroHeading == 0.0) spheroHeading = 360.0;
    spheroHeading = spheroHeading - 1.0;
    [RKRollCommand sendCommandWithHeading:spheroHeading
                                 velocity:self.controlSpeedSlider.value];
    self.controlHeadingLabel.text = [NSString stringWithFormat:@"%f3.0", spheroHeading];
}

- (void)applyEnglish {
//  NSLog(@"Increments Decrements the heading depending upon X acclerometer setting");
//    while (driving) {
        if (accelX > 0.2) {
            // increment the heading
            [self incrementHeading];
        }
        if (accelX < -0.2) {
            // decrement the heading
            [self decrementHeading];
        }
//    }
}

- (void)startMyMotionDetection {
    // uses an execution block to scan accel data asynchronously
//    NSLog (@"Starts regular scanning of the accelerometer data");
    
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
                        withHandler:^(CMAccelerometerData *data, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(),      
                        ^{
                            accelY = data.acceleration.y;
                            accelX = data.acceleration.x;
                            accelZ = data.acceleration.z;
                            self.yLabel.text = [NSString stringWithFormat:@"%f5",accelY];
                            self.xLabel.text = [NSString stringWithFormat:@"%f5",accelX];
                            self.zLabel.text = [NSString stringWithFormat:@"%f5",accelZ];
                        }
                        );
     }
     ];
}

- (CMMotionManager *)motionManager {
    // Custom getter to reference CMMotionManager object in the AppDelegate
    CMMotionManager *motionManager = nil;
    
    id appDelegate = [UIApplication sharedApplication].delegate;  //sets up an unknown type object appDelegate
    
    if ([appDelegate respondsToSelector:@selector(motionManager)]) // if the object has a method motionManager (the getter??0
    {
        motionManager = [appDelegate motionManager];    // Then assign it to this motionManager??
    }
    
    return motionManager;
}

- (void)resetInitialState {
// Resets color & message
    [RKRGBLEDOutputCommand sendCommandWithRed:0.0 green:0.0 blue:0.0];
    self.messageLabel.text = @".......";
}

- (void)calculateRebound:(RKCollisionDetectedAsyncData *)collisionData {
    //    NSLog(@"Looks at the collision data and build the correct rebound response");
    
    if (collisionData.impactAcceleration.y > 0.70) {
        self.messageLabel.text = @"OUCH";
        
        // sets to rebound or stop depending upon button
        if (!rebound) {
            [RKRollCommand sendStop];
            driving = NO;
        } else {
            // Calculates return angle
            if (spheroHeading > 180) {
                float returnAngle = 540 - spheroHeading;
                [RKRollCommand sendCommandWithHeading:returnAngle
                                             velocity:self.controlSpeedSlider.value];
            } else {
                float returnAngle = 180 - spheroHeading;
                [RKRollCommand sendCommandWithHeading:returnAngle
                                             velocity:self.controlSpeedSlider.value];
            }
        }
        [RKRGBLEDOutputCommand sendCommandWithRed:1.0 green:0.0 blue:0.0];
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleApplicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [self.view addSubview:self.unconnectedView];
    [self.view bringSubviewToFront:self.unconnectedView];
    
    aiming = NO;
    driving = NO;
    rebound = YES;
    
    // Start getting accelerometer data
    [self startMyMotionDetection];
}

- (void)viewDidDisappear:(BOOL)animated {
    // included to stop accelerometer scanning
    
    [super viewDidDisappear:animated];
    
//    [self.motionManager stopAccelerometerUpdates];
}

- (void)handleApplicationDidBecomeActive:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRobotOnline:)
                                                 name:RKDeviceConnectionOnlineNotification
                                               object:nil];
    [[RKRobotProvider sharedRobotProvider] openRobotConnection];
}

- (void)handleApplicationWillResignActive:(NSNotification *)notification
{
    [RKConfigureCollisionDetectionCommand sendCommandToStopDetection];
    [[RKDeviceMessenger sharedMessenger] removeDataStreamingObserver:self]; 
    [[RKRobotProvider sharedRobotProvider] closeRobotConnection];
}

- (void)handleRobotOnline:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:RKDeviceConnectionOnlineNotification
                                                  object:nil];
    // observe async data
    [[RKDeviceMessenger sharedMessenger] addDataStreamingObserver:self
                                                         selector:@selector(handleAsyncData:)];
    
    [self.unconnectedView removeFromSuperview];
    self.view.userInteractionEnabled = YES;
    [self presentConfigurationView];
}

- (void)handleAsyncData:(RKDeviceAsyncData *)asyncData
{
    if ([asyncData isKindOfClass:[RKCollisionDetectedAsyncData class]]) {
        RKCollisionDetectedAsyncData *collisionData = (RKCollisionDetectedAsyncData *)asyncData;
        self.xAccelerationLabel.text = [NSString stringWithFormat:@"%.4f", 
                                        collisionData.impactAcceleration.x];
        self.yAccelerationLabel.text = [NSString stringWithFormat:@"%.4f",
                                        collisionData.impactAcceleration.y];
        self.zAccelerationLabel.text = [NSString stringWithFormat:@"%.4f",
                                        collisionData.impactAcceleration.z];
        self.xAxisLabel.text = collisionData.impactAxis.x ? @"☑" : @"☒";
        self.yAxisLabel.text = collisionData.impactAxis.y ? @"☑" : @"☒";
        self.xPowerLabel.text = [NSString stringWithFormat:@"%i",
                                 collisionData.impactPower.x];
        self.yPowerLabel.text = [NSString stringWithFormat:@"%i",
                                 collisionData.impactPower.y];
        self.speedLabel.text = [NSString stringWithFormat:@"%.3f",
                                collisionData.impactSpeed];
        self.timeStampLabel.text = [NSString stringWithFormat:@"%.3f",
                                collisionData.impactTimeStamp];
        [self calculateRebound:collisionData];
        
/*    // Sets the comment string to something based on the YAccel
        if (collisionData.impactAcceleration.y > 1.2) {
            self.messageLabel.text = @"OUCH";
         //   [RKRollCommand sendStop];
            [RKRollCommand sendCommandWithHeading:(self.controlHeadingSlider.value+180)
                                         velocity:self.controlSpeedSlider.value];
            [RKRGBLEDOutputCommand sendCommandWithRed:1.0 green:0.0 blue:0.0];
        }
*/
    }
}
/*
- (void)interpretCollision:(RKCollisionDetectedAsyncData *collisionData) {
    NSLog(@"Flashes the LED to RED & reverses the direction of the ball");
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
