//
//  AppDelegate.h
//  CollisionDetection
//
//  Created by Brian Smith on 2/23/12.
//  Copyright (c) 2012 Orbotix Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    CMMotionManager *motionManager;
}
@property (readonly) CMMotionManager *motionManager;    // singleton 

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
