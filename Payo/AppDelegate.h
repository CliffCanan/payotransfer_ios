//
//  AppDelegate.h
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <GameThrive/GameThrive.h>
#import <MobileAppTracker/MobileAppTracker.h>

UIImageView *splashView;
bool rainbows;
bool inBack;

@interface AppDelegate : UIResponder <UIApplicationDelegate, MobileAppTrackerDelegate>{
    UIImageView * noConnectionView;
    Reachability * hostReach;
    Reachability * internetReach;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) NSDate *inactiveDate;
@property (strong, nonatomic) GameThrive *gameThrive;

- (void)userLoggedIn;
- (void)userLoggedOut;

@end
