//  TransactionDetails.m
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.

#import "TransactionDetails.h"
#import <QuartzCore/QuartzCore.h>
#import "Home.h"
#import "UIImageView+WebCache.h"
#import "ECSlidingViewController.h"
#import "HowMuch.h"
#import "TransferPIN.h"
#import "SelectRecipient.h"
#import "ProfileInfo.h"
#import "DisputeDetail.h"
#import "SettingsOptions.h"
//#import <FacebookSDK/FacebookSDK.h>
@import GoogleMaps;

@interface TransactionDetails ()
@property (nonatomic,strong) NSDictionary *trans;
@property(nonatomic,strong) NSMutableData *responseData;
@property(nonatomic,strong) MBProgressHUD *hud;
@end

@implementation TransactionDetails{
    GMSMapView *mapView_;
}

@synthesize accountStore,twitterAllowed,twitterAccount;

- (id)initWithData:(NSDictionary *)trans
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.trans = trans;
        NSLog(@"Screen Initialized with Transaction Info: %@",self.trans);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"";
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];

    RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];

    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    self.hud.labelText = NSLocalizedString(@"TransDeets_HUDlbl", @"Transfer Details 'Assembling this transfer...' text");
    [self.hud show:YES];

    [self.view setBackgroundColor:[UIColor whiteColor]];

	// Do any additional setup after loading the view.
    [self.navigationItem setTitle:NSLocalizedString(@"TransDeets_ScrnTtl", @"'Transfer Details' Screen Title")];

    [self.view setBackgroundColor:[UIColor whiteColor]];

    UIView * topSectionBg = [UIView new];
    [topSectionBg setFrame:CGRectMake(-1, -1, 322, 110)];
    [topSectionBg setStyleId:@"transDetailsTopSectionBG"];
    [self.view addSubview:topSectionBg];

    UIView * shadowUnder = [[UIView alloc] initWithFrame:CGRectMake(11, 28, 76, 76)];
    shadowUnder.backgroundColor = Rgb2UIColor(207, 210, 213, .5);
    shadowUnder.layer.cornerRadius = 38;
    shadowUnder.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowUnder.layer.shadowOffset = CGSizeMake(0, 1.5);
    shadowUnder.layer.shadowOpacity = 0.5;
    shadowUnder.layer.shadowRadius = 3.0;

    UILabel * other_party = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 60)];  // Other user's NAME
    UIImageView * user_picture = [[UIImageView alloc] initWithFrame:CGRectMake(10, 27, 78, 78)];  // Other user's PICTURE

    user_picture.layer.cornerRadius = 39;
    user_picture.clipsToBounds = YES;


    if ([[self.trans valueForKey:@"TransactionType"]isEqualToString:@"Reward"] ||
        [[self.trans valueForKey:@"Name"]isEqualToString:@"Team Nooch"])
    {
        [shadowUnder setFrame:CGRectMake(15, 32, 63, 63)];
        shadowUnder.layer.cornerRadius = 11;
        [user_picture setImage:[UIImage imageNamed:@"Icon120"]];
        [user_picture setFrame:CGRectMake(14, 31, 65, 65)];
        user_picture.layer.cornerRadius = 11;
    }
    else
    {
        [user_picture sd_setImageWithURL:[NSURL URLWithString:[self.trans objectForKey:@"Photo"]]
                        placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
    }
    [other_party setText:[[self.trans objectForKey:@"Name"] capitalizedString]];
    [other_party setStyleClass:@"details_othername"];

    [self.view addSubview:other_party];
    [self.view addSubview:shadowUnder];
    [self.view addSubview:user_picture];

	// SET TEXT LABEL ABOVE OTHER USER'S NAME
    UILabel *payment = [UILabel new];
    [payment setStyleClass:@"details_intro"];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(32, 33, 34, .32);
    shadow.shadowOffset = CGSizeMake(0, 1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };
    
    if ([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Transfer"])
    {
	    if ([[user valueForKey:@"MemberId"] isEqualToString:[self.trans valueForKey:@"MemberId"]]) {
	        payment.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"TransDeets_PaidToTxt", @"Transfer Details 'Paid To:' text") attributes:textAttributes];
            [payment setStyleClass:@"details_intro_red"];
        }
		else {
            payment.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"TransDeets_PymntFrm", @"Transfer Details 'Payment From' text") attributes:textAttributes];
            [payment setStyleClass:@"details_intro_green"];
        }
	}
    else if ([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Disputed"])
    {
        payment.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"TransDeets_DsptdTrnsfrTxt", @"Transfer Details 'Disputed Transfer:' text") attributes:textAttributes];
        [payment setStyleClass:@"details_intro_red"];
    }
    [self.view addSubview:payment];


    amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 320, 60)];
    [amount setStyleClass:@"details_amount"];
    [amount setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:amount];

    UILabel * memo = [[UILabel alloc] initWithFrame:CGRectMake(0, 116, 320, 60)];
    if (![[self.trans valueForKey:@"Memo"] isKindOfClass:[NSNull class]] && [self.trans valueForKey:@"Memo"]!=NULL)
    {
        if ([[self.trans valueForKey:@"Memo"] length] == 0 || [[self.trans valueForKey:@"Memo"] isEqualToString:@"\"\""])
        {
            memo.text = NSLocalizedString(@"TransDeets_NoMemoTxt1", @"Transfer Details 'No memo attached' text");
        } 
        else
            [memo setText:[NSString stringWithFormat:@"\"%@\"",[self.trans valueForKey:@"Memo"]]];
    }
    else
    {
        memo.text = NSLocalizedString(@"TransDeets_NoMemoTxt2", @"Transfer Details 'No memo attached' text (2nd)");
    }

    memo.numberOfLines = 2;
    [memo setStyleClass:@"details_label_memo"];
    [memo setStyleClass:@"blue_text"];
    [memo setStyleClass:@"italic_font"];
    [self.view addSubview:memo];

    UIButton * pay_back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [pay_back setTitle:@"" forState:UIControlStateNormal];
    [pay_back setStyleCSS:@"background-image : url(pay-back-icon.png)"];
    [pay_back setStyleId:@"details_payback"];
    [pay_back addTarget:self action:@selector(pay_again) forControlEvents:UIControlEventTouchUpInside];

    UILabel * pay_text = [UILabel new];
    [pay_text setFrame:pay_back.frame];

    UIButton * fb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [fb setTitle:@"" forState:UIControlStateNormal];
    [fb setStyleCSS:@"background-image : url(fb-icon-90x90.png)"];
    [fb addTarget:self action:@selector(post) forControlEvents:UIControlEventTouchUpInside];
    [fb setStyleId:@"details_fb"];

    UILabel *fb_text = [UILabel new];
    [fb_text setFrame:fb.frame];
    [fb_text setText:@"Share"];

    UIButton *twit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [twit setTitle:@"" forState:UIControlStateNormal];
    [twit setStyleCSS:@"background-image : url(twitter-icon.png)"];
    [twit addTarget:self action:@selector(post_to_twitter) forControlEvents:UIControlEventTouchUpInside];
    [twit setStyleId:@"details_twit"];

    UILabel * twit_text = [UILabel new];
    [twit_text setFrame:twit.frame];
    [twit_text setText:@"Tweet"];

    UIButton * disp = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [disp setTitle:@"" forState:UIControlStateNormal];
    [disp setStyleCSS:@"background-image : url(dispute-icon.png)"];
    [disp addTarget:self action:@selector(dispute) forControlEvents:UIControlEventTouchUpInside];
    [disp setStyleId:@"details_disp"];

    UILabel * disp_text = [UILabel new];
    [disp_text setFrame:disp.frame];
    [disp_text setText:NSLocalizedString(@"TransDeets_DsptTxt", @"Transfer Details 'Dispute' text")];

    if ([[UIScreen mainScreen] bounds].size.height > 500) {
        [pay_back setStyleClass:@"details_buttons"];
        [pay_text setStyleClass:@"details_buttons_labels"];
        [fb setStyleClass:@"details_buttons"];
        [fb_text setStyleClass:@"details_buttons_labels"];
        [twit setStyleClass:@"details_buttons"];
        [twit_text setStyleClass:@"details_buttons_labels"];
        [disp setStyleClass:@"details_buttons"];
        [disp_text setStyleClass:@"details_buttons_labels"];
    }
    else
    {
        [pay_back setStyleClass:@"details_buttons_4"];
        [pay_text setStyleClass:@"details_buttons_labels_4"];
        [fb setStyleClass:@"details_buttons_4"];
        [fb_text setStyleClass:@"details_buttons_labels_4"];
        [twit setStyleClass:@"details_buttons_4"];
        [twit_text setStyleClass:@"details_buttons_labels_4"];
        [disp setStyleClass:@"details_buttons_4"];
        [disp_text setStyleClass:@"details_buttons_labels_4"];
    }

    [pay_text setStyleId:@"details_buttons_labels_long"];
    CGRect frame1 = pay_text.frame;
    [pay_text setFrame:CGRectMake(frame1.origin.x - 5, frame1.origin.y, frame1.size.width, frame1.size.height)];
    [pay_text setText:NSLocalizedString(@"TransDeets_PayAgn", @"Transfer Details 'Pay Again' text")];

    if ([[self.trans valueForKey:@"TransactionType"] isEqualToString:@"Transfer"] &&
        [[self.trans valueForKey:@"TransactionStatus"] isEqualToString:@"Success"])
    {
        if ([[self.trans objectForKey:@"MemberId"] isEqualToString:[user objectForKey:@"MemberId"]])
        {
            [self.view addSubview:disp];
            [self.view addSubview:disp_text];
        }
        else
        {
            [fb_text setFrame:fb.frame];
            [twit setStyleId:@"details_disp"];
            [twit_text setFrame:twit.frame];
        }
        [self.view addSubview:pay_back];
        [self.view addSubview:pay_text];
        [self.view addSubview:fb];
        [self.view addSubview:fb_text];
        [self.view addSubview:twit];
        [self.view addSubview:twit_text];
    }

    serve * serveOBJ = [serve new ];
    serveOBJ.tagName = @"tranDetail";
    [serveOBJ setDelegate:self];
    [serveOBJ GetTransactionDetail:[self.trans valueForKey:@"TransactionId"]];
}


-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:NSLocalizedString(@"TransDeets_ScrnTtl2", @"'Transfer Details' Screen Title (2nd)")];
    [super viewWillAppear:animated];
    self.screenName = @"TransactionDetail Screen";
    self.artisanNameTag = @"Transfer Details Screen";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    isFromTransferPIN = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}

#pragma mark LightBox Methods
-(void)Map_LightBox
{
    overlay = [[UIView alloc]init];
    overlay.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height);
    overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    [self.navigationController.view addSubview:overlay];

    mainView = [[UIView alloc]init];
    mainView.layer.cornerRadius = 7;
    mapView_.layer.borderWidth = 0;
    
    if ([[UIScreen mainScreen] bounds].size.height < 500) {
        mainView.frame = CGRectMake(9, -500, 302, 443);
    }
    else {
        mainView.frame = CGRectMake(9, -540, 302, self.view.frame.size.height - 34);
    }
    mainView.backgroundColor = [UIColor whiteColor];
    
    [overlay addSubview:mainView];
    mainView.layer.masksToBounds = NO;
    mainView.layer.shadowOffset = CGSizeMake(0, 2);
    mainView.layer.shadowRadius = 5;
    mainView.layer.shadowOpacity = 0.65;

    [UIView animateWithDuration:.4
                     animations:^{
                         overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                     }];

    [UIView animateWithDuration:0.35
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         if ([[UIScreen mainScreen] bounds].size.height < 500) {
                             mainView.frame = CGRectMake(9, 70, 302, 449);
                         } else {
                             mainView.frame = CGRectMake(9, 70, 302, self.view.frame.size.height - 34);
                         }
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.24
                                          animations:^{
                                              [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                                              if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                                  mainView.frame = CGRectMake(9, 35, 302, 443);
                                              } else {
                                                  mainView.frame = CGRectMake(9, 50, 302, self.view.frame.size.height - 34);
                                              }
                                          }];
                     }];

    UIView * head_container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 302, 44)];
    head_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:head_container];
    head_container.layer.cornerRadius = 10;
    
    UIView * space_container = [[UIView alloc]initWithFrame:CGRectMake(0, 34, 302, 10)];
    space_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:space_container];

    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 302, 30)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:NSLocalizedString(@"TransDeets_LocTrnsfrLocTtle", @"'Transfer Loaction' Lightbox Title")];
    [title setStyleClass:@"lightbox_title"];
    [mainView addSubview:title];

    UIView * map_container = [[UIView alloc]initWithFrame:CGRectMake(10, 50, 282, 300)];
    map_container.backgroundColor = [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0];
    [mainView addSubview:map_container];
    
    map_container.layer.cornerRadius = 6;
    map_container.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    map_container.layer.borderWidth = 1;
    map_container.clipsToBounds = YES;
    GMSCameraPosition * camera = [GMSCameraPosition cameraWithLatitude:lat
                                                             longitude:lon
                                                                  zoom:10];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(11, 51, 278, 298) camera:camera];
    [mapView_ setFrame:CGRectMake(11, 51, 278, 298)];
    [mainView addSubview:mapView_];
    mapView_.layer.cornerRadius = 6;
    mapView_.clipsToBounds = YES;
    mapView_.myLocationEnabled = YES;

    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(lat, lon);
    marker.map = mapView_;

    UIView * desc_container=[[UIView alloc]initWithFrame:CGRectMake(10, 356, 280, 36)];
    desc_container.backgroundColor=[UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0];
    desc_container.layer.cornerRadius = 6;
    desc_container.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    desc_container.layer.borderWidth=0.5;
    [mainView addSubview:desc_container];

    UILabel * desc=[[UILabel alloc]initWithFrame:CGRectMake(5, 0, 270, 36)];
    [desc setBackgroundColor:[UIColor clearColor]];
    desc.text = NSLocalizedString(@"TransDeets_LocLtBxDesc", @"Location Lightbox description text");
    desc.font = [UIFont fontWithName:@"Roboto" size:12];
    [desc setStyleId:@"mapLightBox_paraText"];
    desc.numberOfLines = 0;
    [desc_container addSubview:desc];

    UIView * line_container=[[UIView alloc]initWithFrame:CGRectMake(0, desc_container.frame.origin.y+desc_container.frame.size.height+6, 300, 1)];
    line_container.backgroundColor = [UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:1.0];
    [mainView addSubview:line_container];

    UIButton * btnclose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnclose setTitle:NSLocalizedString(@"TransDeets_LocLtBxClsBtn", @"Location Lightbox 'Close' Btn Text") forState:UIControlStateNormal];
    [btnclose setTitleShadowColor:Rgb2UIColor(26, 32, 38, 0.26) forState:UIControlStateNormal];
    btnclose.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [btnclose addTarget:self action:@selector(close_lightBox) forControlEvents:UIControlEventTouchUpInside];
    if ([[UIScreen mainScreen] bounds].size.height < 500)
    {
        [btnclose setStyleClass:@"button_blue_closeLightbox_smscrn"];
        [btnclose setFrame:CGRectMake(160, mainView.frame.size.height - 46, 120, 38)];
    }
    else
    {
        [btnclose setFrame:CGRectMake(150, mainView.frame.size.height - 58, 130, 42)];
        [btnclose setStyleClass:@"button_blue_closeLightbox"];
    }
    [mainView addSubview:btnclose];
}

-(void)close_lightBox
{
    [UIView animateWithDuration:0.15
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         if ([[UIScreen mainScreen] bounds].size.height < 500) {
                             mainView.frame = CGRectMake(9, 70, 302, 449);
                         } else {
                             mainView.frame = CGRectMake(9, 70, 302, self.view.frame.size.height - 34);
                         }
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:.38
                                          animations:^{
                                              [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                                              if ([[UIScreen mainScreen] bounds].size.height < 500) {
                                                  mainView.frame = CGRectMake(9, -500, 302, 443);
                                              }
                                              else {
                                                  mainView.frame = CGRectMake(9, -540, 302, self.view.frame.size.height - 34);
                                              }
                                              overlay.alpha = 0.1;
                                          } completion:^(BOOL finished) {
                                              [overlay removeFromSuperview];
                                          }
                          ];
                     }
     ];
}

#pragma mark Transfer Responses

-(void)cancel_invite
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TransDeets_CnclTrnsfrAlrtTitl", @"'Cancel This Transfer' Alert Title")
                                                 message:NSLocalizedString(@"TransDeets_CnclTrnsfrAlrtBody", @"Cancel This Transfer Alert Body Text")
                                                delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"TransDeets_CnclTrnsfrAlrtYesBtn", @"Cancel This Transfer Alert 'Yes' Btn")
                                       otherButtonTitles:NSLocalizedString(@"TransDeets_CnclTrnsfrAlrtNoBtn", @"Cancel This Transfer Alert 'No' Btn"), nil];
    [av show];
    [av setTag:310];
}

-(void)pay_again
{
    if ([self isUsersStatusOk] == YES)
    {
        NSMutableDictionary * input = [self.trans mutableCopy];
        if ([[user valueForKey:@"MemberId"] isEqualToString:[self.trans valueForKey:@"MemberId"]])
        {
            NSString * MemberId = [input valueForKey:@"RecepientId"];
            [input setObject:MemberId forKey:@"MemberId"];
        }

        //isPayBack = YES;

        // NSLog(@"%@",self.trans);
        HowMuch *payback = [[HowMuch alloc] initWithReceiver:input];
        [self.navigationController pushViewController:payback animated:YES];
    }
}

-(BOOL)isUsersStatusOk
{
    if ([[assist shared] getSuspended])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"\xF0\x9F\x98\xA7  %@", NSLocalizedString(@"TransDeets_SuspAlrtTtl", @"'Account Suspended' Alert Title")]
                                                        message:NSLocalizedString(@"TransDeets_SuspAlrtBody", @"Account Suspended Alert Body Text")
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:NSLocalizedString(@"TransDeets_SuspAlrtBtn", @"'Contact Support' Btn"), nil];
        [alert setTag:50];
        [alert show];
        return NO;
    }
    else if ([[user valueForKey:@"Status"]isEqualToString:@"Registered"])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"TransDeets_EmlVerNddAlrtTtl", @"'Email Verification Needed' Alert Title")
                                                        message:NSLocalizedString(@"TransDeets_EmlVerNddAlrtBody", @"'Email Verification Needed' Alert Body Text")
                                                       delegate:Nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:Nil, nil];
        [alert show];
        return NO;
    }
    else if (![[user valueForKey:@"IsVerifiedPhone"]isEqualToString:@"YES"] )
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Phone Not Verified"
                                                        message:@"To keep Nooch safe, we ask all users to verify a phone number before sending money.\n\nIf you've already added your phone number, just respond 'Go' to the text message we sent."
                                                       delegate:self
                                              cancelButtonTitle:@"Later"
                                              otherButtonTitles:@"Go Now" , nil];
        [alert setTag:147];
        [alert show];
        return NO;
    }
    else if (![user boolForKey:@"IsSynapseBankAvailable"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Link A Bank Account"
                                                        message:@"\xE2\x9A\xA1\nAdding a bank account to fund Nooch payments is lightning quick.\n\n• No routing or account number needed\n• Bank-grade encryption keeps your info safe\n\nWould you like to take care of this now?"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:@"Go Now", nil];
        [alert setTag:81];
        [alert show];
        return NO;
    }
    // ... and check if that bank account is 'Verified'
    else if (![user boolForKey:@"IsSynapseBankVerified"])
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Bank Account Un-Verified"
                                                     message:@"Looks like your bank account remains un-verified.  This usually happens when the contact info listed on the bank account does not match your Nooch profile information. Please contact Nooch support for more information."
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:@"Learn More", nil];
        [av setTag:82];
        [av show];
        return NO;
    }
    
    return YES;
}

#pragma mark Social Posting Methods
- (void)post_to_fb
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        me.accountStore = [[ACAccountStore alloc] init];
        ACAccountType *facebookAccountType = [me.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        me.facebookAccount = nil;

        NSDictionary *options = @{
                ACFacebookAppIdKey: @"198279616971457",
                ACFacebookPermissionsKey: @[@"publish_stream"],
                ACFacebookAudienceKey: ACFacebookAudienceFriends
        };

        [me.accountStore requestAccessToAccountsWithType:facebookAccountType
                options:options completion:^(BOOL granted, NSError *e)
        {
             if (granted)
             {
                 NSArray *accounts = [me.accountStore accountsWithAccountType:facebookAccountType];
                 me.facebookAccount = [accounts lastObject];
                 [self performSelectorOnMainThread:@selector(post) withObject:nil waitUntilDone:NO];
             }
             else
             {
                 // Handle Failure
                 NSLog(@"fbposting not allowed");
             }
         }];
    }
    else
    {
        UIAlertView * alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Can't Post"
                                  message:@"Please connect your Facebook account to your iPhone to post to Facebook."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void) post_to_twitter
{
    NSString * post_text = nil;

    if ([[self.trans objectForKey:@"TransactionStatus"] isEqualToString:@"Success"])
    {
        if ([[user valueForKey:@"MemberId"] isEqualToString:[self.trans valueForKey:@"MemberId"]])
        {
            post_text = [NSString stringWithFormat:@"I just Nooch'ed %@!",[self.trans objectForKey:@"Name"]];
        }
        else
        {
            post_text = [NSString stringWithFormat:@"I just got paid by %@ on Nooch!",[self.trans objectForKey:@"Name"]];
        }
    }

    SLComposeViewController * controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [controller setInitialText: post_text];
    [controller addURL:[NSURL URLWithString:@"http://bit.ly/1xdG2le"]];
    //[controller addImage:[UIImage imageWithData:datos]];

    [self presentViewController:controller animated:YES completion:Nil];

    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
       NSString * output = nil;
       switch (result) {
           case SLComposeViewControllerResultCancelled:
               NSLog (@"Twitter Post Cancelled");
               break;
           case SLComposeViewControllerResultDone:
               output = @"Twitter Post Succesfull";
               NSLog (@"Twitter Post Successful");
               break;
           default:
               break;
       }
       if ([output isEqualToString:@"Twitter Post Succesfull"])
       {
           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:output
                                                           message:@"\xF0\x9F\x91\x8D"
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
           [alert show];
           [alert setTag:11];
       }
       [controller dismissViewControllerAnimated:YES completion:Nil];
    };
    controller.completionHandler = myBlock;
}

-(void)post
{
    //NSString * post_text = nil;

    //if ([[self.trans objectForKey:@"TransactionStatus"] isEqualToString:@"Success"])
    //{
        //post_text = [NSString stringWithFormat:@"I just paid %@!",[self.trans objectForKey:@"Name"]];
    //}

    //NSString * postTitle = @"Payo makes money simple";
    //NSString * postLink = @"https://157054.measurementapi.com/serve?action=click&publisher_id=157054&site_id=91086";
    //NSString * postImgUrl = @"https://www.nooch.com/wp-content/themes/newnooch/library/images/nooch-logo.svg";

    // Check if the Facebook app is installed and we can present the share dialog
/*    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString: postLink];
    params.name = postTitle;
    params.picture = [NSURL URLWithString:postImgUrl];
    params.caption = post_text;
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params])
    {
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if (error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story to FB: %@", error.description);
                                          }
                                          else {
                                              // Success
                                              NSLog(@"Facebook Share result: %@", results);
                                          }
                                      }];
    }
    else
    {
        // FALLBACK: publish just a link using the Feed dialog
        
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Sharing Tutorial", @"name",
                                       @"Build great social apps and get more installs.", @"caption",
                                       @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
                                       @"https://developers.facebook.com/docs/ios/share/", @"link",
                                       @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User canceled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User canceled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }*/
}

// A function for parsing URL parameters returned by the FB Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void) dispute
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TransDeets_CnfrmDsptAlrtTtl", @"'Confirm Dispute' Alert Title")
                                                 message:NSLocalizedString(@"TransDeets_CnfrmDsptAlrtBody", @"'Confirm Dispute' Alert Body Text")//@"To protect your account, if you dispute a transfer your Nooch account will be temporarily suspended while we investigate."
                                                delegate:self
                                       cancelButtonTitle:NSLocalizedString(@"TransDeets_CnfrmDsptAlrtNoBtn", @"Confirm Dispute Alert 'No' Btn Text")
                                       otherButtonTitles:NSLocalizedString(@"TransDeets_CnfrmDsptAlrtYesBtn", @"Confirm Dispute Alert 'Yes - Dispute' Btn Text"), nil];
    [av show];
    [av setTag:1];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 147 && buttonIndex == 1)  // PHONE NOT VERIFIED, GO TO PROFILE
    {
        ProfileInfo *prof = [ProfileInfo new];
        isProfileOpenFromSideBar=NO;
        isFromTransDetails=YES;
        [self.navigationController pushViewController:prof animated:YES];
    }

    else if (alertView.tag == 1 && buttonIndex == 1)  // DISPUTE
    {
        RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];

        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.delegate = self;
        self.hud.labelText = @"Disputing this transfer...";
        [self.hud show:YES];

        self.responseData = [NSMutableData data];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

        NSString * memId = [user objectForKey:@"MemberId"];
        [dict setObject :memId forKey:@"MemberId"];
        [dict setObject:[self.trans valueForKey:@"RecepientId"] forKey:@"RecepientId"];
        [dict setObject:[self.trans valueForKey:@"TransactionId"] forKey:@"TransactionId"];
        [dict setObject:@"SENT" forKey:@"ListType"];

        serve *serveobj = [serve new];
        [serveobj setDelegate:self];
        serveobj.tagName = @"dispute";
        [serveobj RaiseDispute:dict];
    }

    else if ((alertView.tag == 568 || alertView.tag == 50) && buttonIndex == 1)  // User Disputed a Transfer, then selected "Contact Support" in Alert
    {
        if (![MFMailComposeViewController canSendMail])
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"No Email Detected"
                                                          message:@"You don't have an email account configured for this device."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
            [av show];
            return;
        }

        NSString * memberId = [user valueForKey:@"MemberId"];
        NSString * fullName = [NSString stringWithFormat:@"%@ %@",[user valueForKey:@"firstName"],[user valueForKey:@"lastName"]];
        NSString * userStatus = [user objectForKey:@"Status"];
        NSString * userEmail = [user objectForKey:@"UserName"];
        NSString * IsVerifiedPhone = [[user objectForKey:@"IsVerifiedPhone"] lowercaseString];
        NSString * iOSversion = [[UIDevice currentDevice] systemVersion];
        NSString * msgBody = [NSString stringWithFormat:@"<!doctype html> <html><body><br><br><br><br><br><br><small>• MemberID: %@<br>• Name: %@<br>• Status: %@<br>• Email: %@<br>• Is Phone Verified: %@<br>• iOS Version: %@<br></small></body></html>",memberId, fullName, userStatus, userEmail, IsVerifiedPhone, iOSversion];

        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        mailComposer.navigationBar.tintColor=[UIColor whiteColor];
        [mailComposer setSubject:[NSString stringWithFormat:@"Support Request: Version %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
        [mailComposer setMessageBody:msgBody isHTML:YES];
        [mailComposer setToRecipients:[NSArray arrayWithObjects:@"support@nooch.com", nil]];
        [mailComposer setCcRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setBccRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setModalTransitionStyle:UIModalTransitionStylePartialCurl];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }

    else if (alertView.tag == 81 && buttonIndex == 1)
    {
        SettingsOptions * mainSettingsScrn = [SettingsOptions new];
        [nav_ctrl pushViewController:mainSettingsScrn animated:YES];
        [self.slidingViewController resetTopView];
    }

    else if (alertView.tag == 82 && buttonIndex == 1)
    {
        shouldDisplayBankNotVerifiedLtBox = YES;
        SettingsOptions * mainSettingsScrn = [SettingsOptions new];
        [nav_ctrl pushViewController:mainSettingsScrn animated:YES];
        [self.slidingViewController resetTopView];
    }
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];
}

-(void)DisputeDetailClicked:(UIButton*)sender
{
    DisputeDetail * dd = [[DisputeDetail alloc]initWithData:tranDetailResult];
    [self.navigationController pushViewController:dd animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
            
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            [alert setTitle:@"Email Draft Saved"];
            [alert show];
            break;
            
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            [alert setTitle:@"Email Sent Successfully"];
            [alert show];
            break;
            
        case MFMailComposeResultFailed:
            [alert setTitle:[error localizedDescription]];
            [alert show];
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    [self.hud hide:YES];

    if ([tagName isEqualToString:@"tranDetail"])
    {
        NSError *error;

        tranDetailResult = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if (![[self.trans objectForKey:@"Latitude"] intValue] == 0 && ![[self.trans objectForKey:@"Longitude"] intValue] == 0)
        {
            //NSLog(@"Latitude is : %f  & Longitude is: %f",[[self.trans objectForKey:@"Latitude"] floatValue],[[self.trans objectForKey:@"Longitude"] floatValue]);
            
            lat = [[self.trans objectForKey:@"Latitude"] floatValue];
            lon = [[self.trans objectForKey:@"Longitude"] floatValue];
            
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                                    longitude:lon
                                                                         zoom:11];
            
            UIButton * btnShowMapOverlay = [[UIButton alloc]init];
            [btnShowMapOverlay setBackgroundColor:[UIColor clearColor]];

            UIButton * btnShowPicOverlay = [[UIButton alloc]init];
            [btnShowPicOverlay setBackgroundColor:[UIColor clearColor]];

            mapView_ = [GMSMapView mapWithFrame:CGRectMake(-1, 226, 322, 180) camera:camera];

            if ([[UIScreen mainScreen] bounds].size.height == 480)
            {
                [mapView_ setFrame:CGRectMake(-1, 220, 322, 116)];
                btnShowMapOverlay.frame = CGRectMake(-1, 220, 322, 116);
            }
            else
            {
                [mapView_ setFrame:CGRectMake(-1, 226, 322, 180)];
                btnShowMapOverlay.frame = CGRectMake(-1, 226, 322, 180);
            }

           [self.view addSubview:mapView_];
            mapView_.myLocationEnabled = YES;
            
            // Creates a marker in the center of the map.
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(lat, lon);
            marker.map = mapView_;
            
            [self.view addSubview:btnShowMapOverlay];
            [self.view bringSubviewToFront:btnShowMapOverlay];
            [btnShowMapOverlay addTarget:self action:@selector(Map_LightBox) forControlEvents:UIControlEventTouchUpInside];
        }

        if ([self.trans objectForKey:@"Amount"] != NULL)
        {
            [amount setText:[NSString stringWithFormat:@"$%.02f", [[tranDetailResult valueForKey:@"Amount"] floatValue]]];
        }
        
        [amount setStyleClass:@"details_amount"];
        [amount setTextAlignment:NSTextAlignmentCenter];

        UILabel * location = [[UILabel alloc] initWithFrame:CGRectMake(-1, 180, 322, 20)];
        location.numberOfLines = 1;
        [location setStyleClass:@"details_label_location"];
        
        if ([[UIScreen mainScreen] bounds].size.height == 480) {
            [location setStyleClass:@"details_label_location_4"];
        }

        if ( ([self.trans objectForKey:@"City"] != NULL && [self.trans objectForKey:@"State"] != NULL) &&
            ([[self.trans objectForKey:@"City"] length] > 0 || [[self.trans objectForKey:@"State"] length] > 0) )
        {
            NSString * address = nil;

            if ([[self.trans objectForKey:@"City"] length] > 0)
            {
                address = [self.trans objectForKey:@"City"];

                if ([[self.trans objectForKey:@"State"] length] > 0)
                {
                    address = [address stringByAppendingString:[NSString stringWithFormat:@", %@",[self.trans objectForKey:@"State"]]];
                }
            }
            else if ([[self.trans objectForKey:@"State"] length] > 0)
            {
                address = [self.trans objectForKey:@"State"];
            }

            [location setText: address];
            [mapView_ addSubview: location];
        }
        else if ([[self.trans objectForKey:@"City"] length] == 0 &&
                 [[self.trans objectForKey:@"State"] length] == 0)
        {
            [location removeFromSuperview];
        }

        // Set Status
        UILabel * status = [[UILabel alloc] initWithFrame:CGRectMake(20, 166, 280, 30)];
        [status setFont: [UIFont fontWithName:@"Roboto-bold" size:21]];
        [status setTextAlignment:NSTextAlignmentCenter];
        [status setTag:12];

        NSLog(@"Transaction Date from server is: %@",[tranDetailResult objectForKey:@"TransactionDate"]);
        if ([tranDetailResult objectForKey:@"TransactionDate"] != NULL)
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
            [dateFormatter setAMSymbol:@"AM"];
            [dateFormatter setPMSymbol:@"PM"];
            dateFormatter.dateFormat = @"M/d/yyyy h:mm:ss a";
            
            NSDate * yourDate = [dateFormatter dateFromString:[tranDetailResult objectForKey:@"TransactionDate"]];
            dateFormatter.dateFormat = @"dd-MMMM-yyyy";
            //[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];

            NSString *statusstr;

            if ([[tranDetailResult objectForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
                statusstr = NSLocalizedString(@"TransDeets_CncldTxt", @"'Canceled' Status Text");
                [status setStyleClass:@"red_text"];
            }
            else if ([[tranDetailResult valueForKey:@"TransactionType"] isEqualToString:@"Sent"]     ||
                     [[tranDetailResult valueForKey:@"TransactionType"] isEqualToString:@"Transfer"])
            {
                statusstr = NSLocalizedString(@"TransDeets_CmpltTxt", @"'Complete' Status Text");
                [status setStyleClass:@"green_text"];
            }
            
            if (![[self.trans valueForKey:@"DisputeId"] isKindOfClass:[NSNull class]] &&
                  [self.trans valueForKey:@"DisputeId"] != NULL )
            {
                statusstr = NSLocalizedString(@"TransDeets_DsptdsTxt", @"'Disputed:' Status Text");
                [status setStyleClass:@"red_text"];

				UIButton * detailbutton = [UIButton buttonWithType:UIButtonTypeCustom];
                [detailbutton addTarget:self
                           action:@selector(DisputeDetailClicked:)
                 forControlEvents:UIControlEventTouchUpInside];
                [detailbutton setTitle:NSLocalizedString(@"TransDeets_SeeDetTxt1", @"'See Details' Status Text") forState:UIControlStateNormal];
                [detailbutton setTitle:NSLocalizedString(@"TransDeets_SeeDetTxt2", @"'See Details' Status Text (2nd)") forState:UIControlStateHighlighted];
                [detailbutton setTitle:NSLocalizedString(@"TransDeets_SeeDetTxt3", @"'See Details' Status Text (3rd)") forState:UIControlStateSelected];
                detailbutton.frame = CGRectMake(97, 195, 120, 20);
                detailbutton.titleLabel.font=[UIFont fontWithName:@"Roboto-Regular" size:15];
                detailbutton.titleLabel.textColor=kPayoBlue;
                [detailbutton setTitleColor:kPayoBlue forState:UIControlStateSelected];
                [detailbutton setTitleColor:kPayoBlue forState:UIControlStateNormal];
                [self.view addSubview:detailbutton];

				UIImageView * arrow_direction = [[UIImageView alloc]initWithFrame:CGRectMake(detailbutton.frame.origin.x+detailbutton.frame.size.width - 15, 198, 12, 15)];
                arrow_direction.image = [UIImage imageNamed:@"arrow-blue.png"];
                [self.view addSubview:arrow_direction];

                UIView * line = [[UIView alloc]initWithFrame:CGRectMake(118, 213, 78, 1)];
                line.backgroundColor=kPayoBlue;
                [self.view addSubview:line];
            }

            [status setText:statusstr];
            [self.view addSubview:status];

            if ([[self.trans valueForKey:@"DisputeId"] isKindOfClass:[NSNull class]] ||
                 [self.trans valueForKey:@"DisputeId"] == NULL )
            {
                if (![yourDate isKindOfClass:[NSNull class]] && yourDate != NULL)
                {
                    NSArray *arrdate = [[dateFormatter stringFromDate:yourDate] componentsSeparatedByString:@"-"];

                    UILabel *datelbl = [[UILabel alloc] initWithFrame:CGRectMake(80, 190, 160, 30)];
                    [datelbl setTextAlignment:NSTextAlignmentCenter]; 
                    [datelbl setFont:[UIFont fontWithName:@"Roboto-Light" size:16]];
                    [datelbl setTextColor:kNoochGrayDark];
                    datelbl.text = [NSString stringWithFormat:@"%@ %@, %@",[arrdate objectAtIndex:1],[arrdate objectAtIndex:0],[arrdate objectAtIndex:2]];
                    [self.view addSubview:datelbl];
                }
            }
        }

        serve *info = [serve new];
        info.Delegate = self;
        info.tagName = @"info";
        [info getDetails:[user valueForKey:@"MemberId"]];
    }

    else if ([tagName isEqualToString:@"dispute"])
    {
        for (UIView *subview in self.view.subviews)
        {
            if (subview.tag == 12)  // Remove "Completed" Status
                [subview removeFromSuperview];
        }

        UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Transfer Disputed"
                                                    message:@"Thanks for letting us know. We will investigate and may contact you for more information.\n\nIf you would like to tell us more please contact Nooch Support."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:@"Contact Support", nil];
        [alert show];
        [alert setTag:568];

        UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(20, 166, 320, 30)];
        [status setStyleClass:@"details_label"];
        [status setStyleId:@"details_status"];
        NSString *statusstr=@"Disputed";
        [status setStyleClass:@"red_text"];
        [status setText:statusstr];
        [self.view addSubview:status];
        [[assist shared]setSusPended:YES];
    }

    else if ([tagName isEqualToString:@"info"])
    {
        NSError *error;
        NSMutableDictionary * Result = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if ( [Result valueForKey:@"Status"] != Nil &&
           ![[Result valueForKey:@"Status"] isKindOfClass:[NSNull class]] &&
             [Result valueForKey:@"Status"] != NULL)
        {
            [user setObject:[Result valueForKey:@"Status"] forKey:@"Status"];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    // Dispose of any resources that can be recreated.
}
@end