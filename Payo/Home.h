//
//  Home.h
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.

#import <UIKit/UIKit.h>
#import "Helpers.h"
#import <PixateFreestyle/PixateFreestyle.h>
#import "serve.h"
#import "core.h"
#import "NavControl.h"
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>
#import "NSString+FontAwesome.h"
#import "FAImageView.h"
#import "iCarousel.h"
#import <ArtisanSDK/ArtisanSDK.h>

core *me;
#define kPayoBlue      [Helpers hexColor:@"1A5BAA"]
#define kPayoGreen     [Helpers hexColor:@"55BA50"]
#define kPayoRed       [Helpers hexColor:@"D2232A"]
#define kPayoPurple    [Helpers hexColor:@"5A538D"]
#define kNoochGrayLight [Helpers hexColor:@"939598"]
#define kNoochGrayDark  [Helpers hexColor:@"414042"]
#define kNoochLight     [Helpers hexColor:@"EBEBEB"]
#define Rgb2UIColor(r, g, b, a)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

UINavigationController *nav_ctrl;
NSUserDefaults *user;
BOOL isSynapseOn,noRecentContacts,isFromTransferPIN;

@interface Home : GAITrackedViewController<serveD,CLLocationManagerDelegate,MBProgressHUDDelegate,MFMailComposeViewControllerDelegate,iCarouselDataSource,iCarouselDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
{
    CLLocationManager*locationManager;
    float lat,lon;
    UIView*overlay;
    UIView*mainView;
    NSDate*ServerDate;
    NSTimer*timerHome;
    NSMutableArray *additions;
    NSMutableArray *favorites;
    NSString * emailID, * firstNameAB, * lastNameAB;
    UIButton *top_button;
    int bannerAlert;
    short carouselTopValue, topBtnTopValue, loopIteration;
    BOOL shouldBreakLoop,isPendingGlyphShowing;
}
-(void)contact_support;
-(void)hide;
@end
