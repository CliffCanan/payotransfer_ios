//
//  TransactionDetails.h
//  Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
@import GoogleMaps;

@interface TransactionDetails : GAITrackedViewController<serveD,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,MBProgressHUDDelegate,UIScrollViewDelegate>{
    UIView * blankView;
    UILabel * amount;
    UIView * overlay,*mainView;
    double lat;
    double lon;
    NSMutableDictionary * tranDetailResult;
}
@property (nonatomic, retain) ACAccount * twitterAccount;
@property (nonatomic) bool twitterAllowed;
@property (nonatomic, retain) ACAccountStore * accountStore;

-(id)initWithData:(NSDictionary *)trans;

@end