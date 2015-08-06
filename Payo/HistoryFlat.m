//  HistoryFlat.m
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.

#import "HistoryFlat.h"
#import "Home.h"
#import "Helpers.h"
#import <QuartzCore/QuartzCore.h>
#import "TransactionDetails.h"
#import "UIImageView+WebCache.h"
#import "ECSlidingViewController.h"
#import "Register.h"
#import "TransferPIN.h"
#import "ProfileInfo.h"
#import "addBank.h"
#import "SettingsOptions.h"

@interface HistoryFlat ()

@property(nonatomic,strong) UISearchBar * search;
@property(nonatomic,strong) UITableView * list;
@property(nonatomic,strong) NSDictionary *responseDict;
@property(nonatomic,strong) UILabel * glyph_emptyTable;
@property(nonatomic, strong) UILabel * glyph_emptyLoc;
@property(nonatomic, strong) UILabel * emptyText;
@property(nonatomic, strong) UIImageView * emptyPic;
@property(nonatomic,strong) UIView * tableShadow;

@end

@implementation HistoryFlat

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];

    UIButton *hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [hamburger setStyleId:@"navbar_hamburger"];
    [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];

    UIBarButtonItem *menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
    [self.navigationItem setLeftBarButtonItem:menu];

    [self.navigationItem setTitle:NSLocalizedString(@"History_ScrnTitle", @"History screen title")];
     [nav_ctrl performSelector:@selector(disable)];

    if (!histArray) {
        histArray = [[NSMutableArray alloc]init];
    }
    if (!histShowArrayCompleted) {
        histShowArrayCompleted = [[NSMutableArray alloc]init];
    }
    if (!histTempCompleted) {
        histTempCompleted = [[NSMutableArray alloc]init];
    }

    self.search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 5, 320, 40)];
    [self.search setStyleId:@"history_search"];
    [self.search setDelegate:self];
    self.search.searchBarStyle = UISearchBarStyleMinimal;
    [self.search setPlaceholder:NSLocalizedString(@"History_SearchPlaceholder", @"History screen search bar placeholder text")];
    [self.search setImage:[UIImage imageNamed:@"search_blue"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.search setTintColor:kPayoBlue];
    [self.view addSubview:self.search];

    self.list = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 320, [UIScreen mainScreen].bounds.size.height - 50)];
    [self.list setStyleId:@"history"];
    [self.list setDataSource:self];
    [self.list setDelegate:self];
    [self.list setSectionHeaderHeight:0];
    [self.view addSubview:self.list];

    self.tableShadow = [[UIView alloc] initWithFrame:self.list.frame];
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:self.tableShadow.bounds];
    self.tableShadow.layer.masksToBounds = NO;
    self.tableShadow.layer.shadowColor = Rgb2UIColor(32, 33, 34, 0.4).CGColor;
    self.tableShadow.layer.shadowOpacity = 1;
    self.tableShadow.layer.shadowOffset = CGSizeMake(2,3);
    self.tableShadow.layer.shadowRadius = 2;
    self.tableShadow.layer.shadowPath = path.CGPath;
    self.tableShadow.layer.shouldRasterize = YES;
    [self.view addSubview:self.tableShadow];
    [self.view bringSubviewToFront:self.list];

    [self.view bringSubviewToFront:self.search];

    UIButton *filter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [filter setStyleClass:@"label_filter"];
    [filter setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    filter.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [filter setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-filter"] forState:UIControlStateNormal];
    [filter addTarget:self action:@selector(FilterHistory:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *filt = [[UIBarButtonItem alloc] initWithCustomView:filter];

    [self.navigationItem setRightBarButtonItem:filt animated:YES];

    SDImageCache * imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];

    listType = @"ALL";
    index = 1;
    isStart = YES;
    isLocalSearch = NO;
    subTypestr = @"";
    [self loadHist:@"ALL" index:index len:20 subType:subTypestr];

    // Row count for scrolling
    countRows = 0;

    // Export History
    exportHistory = [UIButton buttonWithType:UIButtonTypeCustom];
    [exportHistory setTitle:@"     Export History" forState:UIControlStateNormal];
    [exportHistory setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    exportHistory.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [exportHistory setFrame:CGRectMake(10, 420, 132, 31)];
    if ([UIScreen mainScreen].bounds.size.height > 500) {
        [exportHistory setStyleClass:@"exportHistorybutton"];
    }
    else {
        [exportHistory setStyleClass:@"exportHistorybutton_4"];
    }

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(19, 32, 38, .22);
    shadow.shadowOffset = CGSizeMake(0, -1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    UILabel * glyph_export = [UILabel new];
    [glyph_export setFont:[UIFont fontWithName:@"FontAwesome" size:14]];
    [glyph_export setFrame:CGRectMake(7, 1, 15, 30)];
    glyph_export.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-cloud-download"] attributes:textAttributes];
    [glyph_export setTextColor:[UIColor whiteColor]];
    [exportHistory addSubview:glyph_export];
    [exportHistory addTarget:self action:@selector(ExportHistory:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exportHistory];
    [self.view bringSubviewToFront:exportHistory];

    [self.view bringSubviewToFront:self.tableShadow];
    [self.view bringSubviewToFront:self.list];

    _emptyText = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 290, 70)];
    _emptyPic = [[UIImageView alloc] initWithFrame:CGRectMake(33, 102, 253, 256)];

    [ARTrackingManager trackEvent:@"HistoryMain_viewDidLoad_End"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setTitle:NSLocalizedString(@"History_ScrnTitle", @"History screen title")];

    [super viewWillAppear:animated];
    self.screenName = @"HistoryFlat Screen";
    self.artisanNameTag = @"History Screen";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.hud hide:YES];
}

#pragma mark - Navigation Handlers
-(void)showMenu
{
    [self.search resignFirstResponder];
    [self.slidingViewController anchorTopViewTo:ECRight];
}


/*-(void)move:(id)sender
{
    [self.view bringSubviewToFront:mapArea];
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstX = [[sender view] center].x;
        firstY = [[sender view] center].y;
    }
    if (firstX+translatedPoint.x==150.500000) {
        return;
    }
    if (firstX+translatedPoint.x==572.500000) {
        return;
    }
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY);

    CGFloat animationDuration = 0.2;
    CGFloat velocityX = (0.0*[(UIPanGestureRecognizer*)sender velocityInView:self.view].x);
    
    CGFloat finalX = translatedPoint.x + velocityX;
    CGFloat finalY = firstY;
    [[sender view] setCenter:translatedPoint];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [[sender view] setCenter:CGPointMake(finalX, finalY)];
    [UIView commitAnimations];
}*/

-(void)FilterHistory:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissFP:) name:@"dismissPopOver" object:nil];
    isHistFilter = YES;

    popSelect *popOver = [[popSelect alloc] init];
    popOver.title = nil;
    
    fp =  [[FPPopoverController alloc] initWithViewController:popOver];
    fp.border = NO;
    fp.tint = FPPopoverDefaultTint;
    fp.arrowDirection = FPPopoverArrowDirectionUp;
    fp.contentSize = CGSizeMake(165, 256);
    [fp presentPopoverFromPoint:CGPointMake(258, 50)];
}

-(void)dismissFP:(NSNotification *)notification
{
    [fp dismissPopoverAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dismissPopOver" object:nil];
    isSearch = NO;

    if (![listType isEqualToString:@"CANCEL"] && isFilterSelected)
    {
        [self.search setShowsCancelButton:NO];
        [self.search setText:@""];
        [self.search resignFirstResponder];

        [histShowArrayCompleted removeAllObjects];

        isLocalSearch = NO;
        isFilter = YES;
        index = 1;
        isFilterSelected = NO;

        //Release memory cache
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        [imageCache cleanDisk];
        countRows = 0;

        [self loadHist:listType index:index len:20 subType:subTypestr];
    }
    else {
        isFilter = NO;
    }
}

-(void)loadHist:(NSString*)filter index:(int)ind len:(int)len subType:(NSString*)subType
{
    if (!isFromTransferPIN && ![self.view.subviews containsObject:self.hud])
    {
        RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWanderingCubes];
        spinner1.color = [UIColor whiteColor];
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        self.hud.labelText = NSLocalizedString(@"History_HUDloadingTxt", @"History screen HUD loading text");
        [self.hud show:YES];
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = spinner1;
        self.hud.delegate = self;
    }

    isSearch = NO;
    isLocalSearch = NO;

    serve * serveOBJ = [serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName = @"hist";
    [serveOBJ histMore:filter sPos:ind len:len subType:subTypestr];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section2
{
    if (isLocalSearch) {
        return [histTempCompleted count];
    }
    return [histShowArrayCompleted count] + 1;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([histShowArrayCompleted count] > indexPath.row)
    {
        NSDictionary * dictRecord_complete = [histShowArrayCompleted objectAtIndex:indexPath.row];
        if (![[dictRecord_complete valueForKey:@"Memo"] isKindOfClass:[NSNull class]])
        {
            if ([[dictRecord_complete valueForKey:@"Memo"] length] < 2) {
                return 74;
            }
            else if ([[dictRecord_complete valueForKey:@"Memo"] length] > 26) {
                return 86;
            }
            else
               return 74;
        }
        else
        {
            return 74;
        }
    }
    else if ([histTempCompleted count] == indexPath.row ||
             [histShowArrayCompleted count] == 0)
    {
        return 200;
    }

    return 74;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"Cell";
    SWTableViewCell * cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == NULL)
    {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }

    if ([cell.contentView subviews])
    {
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }

    if ([histShowArrayCompleted count] > indexPath.row)
    {
        NSDictionary * dictRecord = nil;

        if (!isLocalSearch)
        {
            dictRecord = [histShowArrayCompleted objectAtIndex:indexPath.row];
        }
        else
        {
            dictRecord = [histTempCompleted objectAtIndex:indexPath.row];
        }

        if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]  ||
            [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"] ||
            [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]||
            [[dictRecord valueForKey:@"DisputeStatus"]isEqualToString:@"Resolved"] )
        {
            UILabel * statusIndicator = [[UILabel alloc] initWithFrame:CGRectMake(58, 7, 10, 11)];
            [statusIndicator setBackgroundColor:[UIColor clearColor]];
            [statusIndicator setTextAlignment:NSTextAlignmentCenter];
            [statusIndicator setFont:[UIFont fontWithName:@"FontAwesome" size:10]];

            UILabel * amount = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
            [amount setBackgroundColor:[UIColor clearColor]];
            [amount setTextAlignment:NSTextAlignmentRight];
            [amount setFont:[UIFont fontWithName:@"Roboto-Medium" size:18]];
            [amount setStyleClass:@"history_transferamount"];
            [amount setText:[NSString stringWithFormat:@"$%.02f",[[dictRecord valueForKey:@"Amount"] floatValue]]];

            UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 50, 50)];
            pic.layer.cornerRadius = 25;
            pic.clipsToBounds = YES;

            UILabel *transferTypeLabel = [UILabel new];
            [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel"];
            transferTypeLabel.layer.cornerRadius = 4;
            transferTypeLabel.clipsToBounds = YES;

            UILabel *name = [UILabel new];
            [name setStyleClass:@"history_cell_textlabel"];
            [name setStyleClass:@"history_recipientname"];

            UILabel *date = [UILabel new];
            [date setStyleClass:@"history_datetext"];

            UILabel *glyphDate = [UILabel new];
            [glyphDate setFont:[UIFont fontWithName:@"FontAwesome" size:9]];
            [glyphDate setFrame:CGRectMake(155, 7, 14, 11)];
            [glyphDate setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-clock-o"]];
            [glyphDate setTextColor:kNoochGrayLight];
            [cell.contentView addSubview:glyphDate];
            
            if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Rejected"]) {
                [statusIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-minus-circle"]];
                [statusIndicator setTextColor:kNoochRed];
            }
            else if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"]) {
                [statusIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"]];
                [statusIndicator setTextColor:kNoochRed];
            }
            else if ( [[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"] ||
                     ![[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Reward"]) {
                [statusIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"]];
                [statusIndicator setTextColor:kPayoGreen];
            }

            NSString * username = [NSString stringWithFormat:@"%@",[user valueForKey:@"UserName"]];
            NSString * fullName = [NSString stringWithFormat:@"%@ %@",[user valueForKey:@"firstName"],[user valueForKey:@"lastName"]];
            NSString * invitationSentTo = [NSString stringWithFormat:@"%@",[dictRecord valueForKey:@"InvitationSentTo"]];

            if ( [[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Transfer"] ||
                ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] &&
                 invitationSentTo != NULL && ![invitationSentTo isEqualToString:username] &&
                ![[dictRecord valueForKey:@"Name"] isEqualToString:fullName]))
            {
                if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]])
                {
                    // Sent Transfer
                    [amount setStyleClass:@"history_transferamount_neg"];
                    [transferTypeLabel setText:NSLocalizedString(@"History_TransferToTxt", @"History screen 'Transfer To' Text")];
                    [transferTypeLabel setBackgroundColor:kNoochRed];
                    [name setText:[NSString stringWithFormat:@"%@",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                    [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                        placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
                }
            }
            else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Reward"])
            {
                [amount setStyleClass:@"history_transferamount_pos"];
                [transferTypeLabel setText:@"REWARD FROM"];
                [transferTypeLabel setTextColor:kNoochGrayDark];
                [transferTypeLabel setBackgroundColor:[UIColor yellowColor]];
                [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"] capitalizedString]]];
                [pic setFrame:CGRectMake(9, 7, 44, 44)];
                [pic setImage:[UIImage  imageNamed:@"Icon.png"]];
                pic.layer.cornerRadius = 7;
                [statusIndicator setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-star"]];
                [statusIndicator setTextColor:[UIColor yellowColor]];
                [statusIndicator setFont:[UIFont fontWithName:@"FontAwesome" size:10]];
                [statusIndicator setStyleId:@"rewardIconShadow"];
            }
            else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"])
            {
                if ([[user valueForKey:@"MemberId"] isEqualToString:[dictRecord valueForKey:@"MemberId"]])
                {
                    //@"You disputed a transfer to"
                    [transferTypeLabel setText:NSLocalizedString(@"History_YouDisputedTxt", @"History screen 'You disputed...' Text")];
                }
                else
                {
                    //@"Transfer disputed by"
                    [transferTypeLabel setText:NSLocalizedString(@"History_DisputedByTxt", @"History screen 'Transfer disputed by' Text")];
                }
                
                [transferTypeLabel setStyleClass:@"history_cell_transTypeLabel_evenWider"];
                [transferTypeLabel setBackgroundColor:Rgb2UIColor(193, 32, 39, .98)];
                [date setStyleClass:@"history_datetext_wide"];
                [glyphDate setFrame:CGRectMake(180, 7, 14, 11)];
                [amount setTextColor:kNoochGrayDark];
                [name setText:[NSString stringWithFormat:@"%@ ",[[dictRecord valueForKey:@"Name"]capitalizedString]]];
                [pic sd_setImageWithURL:[NSURL URLWithString:[dictRecord objectForKey:@"Photo"]]
                    placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
            }

            //  'updated_balance' now for displaying transfer STATUS, only if status is "cancelled" or "rejected"
            //  (this used to display the user's updated balance, which no longer exists)
            UILabel * updated_balance = [UILabel new];
            [updated_balance setStyleClass:@"transfer_status"];
            
            if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Cancelled"])
            {
                [updated_balance setText:[NSString stringWithFormat:@"%@",[dictRecord valueForKey:@"TransactionStatus"]]];
                [updated_balance setTextColor:kNoochGrayLight];
                [cell.contentView addSubview:updated_balance];
            }
            else if ([[dictRecord valueForKey:@"TransactionStatus"]isEqualToString:@"Success"] &&
                     [[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Invite"] )
            {
                [updated_balance setText:NSLocalizedString(@"History_AcceptedTxt", @"History screen 'Accepted' Text")];
                [updated_balance setTextColor:kPayoGreen];
                [cell.contentView addSubview:updated_balance];
            }
            else if ([[dictRecord valueForKey:@"TransactionType"]isEqualToString:@"Disputed"] &&
                     [[dictRecord valueForKey:@"DisputeStatus"]isEqualToString:@"Resolved"])
            {
                [updated_balance setText:NSLocalizedString(@"History_ResolvedTxt", @"History screen 'Resolved' Text")];
                [updated_balance setTextColor:kPayoGreen];
                [cell.contentView addSubview:updated_balance];
            }

            NSDate *addeddate = [self dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
            if (![addeddate isKindOfClass:[NSNull class]] && addeddate != NULL)
            {

                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                                    fromDate:addeddate
                                                                      toDate:[NSDate date]
                                                                     options:0];

                if ((long)[components day] > 3)
                {
                    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                    //Set the AM and PM symbols
                    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
                    [dateFormatter setAMSymbol:@"AM"];
                    [dateFormatter setPMSymbol:@"PM"];
                    dateFormatter.dateFormat = @"MM/dd/yyyy hh:mm:ss a";
                    NSDate *yourDate = [dateFormatter dateFromString:[dictRecord valueForKey:@"TransactionDate"]];
                    dateFormatter.dateFormat = @"dd-MMMM-yyyy";

                    if (![yourDate isKindOfClass:[NSNull class]] && yourDate != NULL)
                    {
                        NSArray * arrdate = [[dateFormatter stringFromDate:yourDate] componentsSeparatedByString:@"-"];
                        [date setText:[NSString stringWithFormat:@"%@ %@",[arrdate objectAtIndex:1],[arrdate objectAtIndex:0]]];
                        [cell.contentView addSubview:date];
                    }
                }
                else if ((long)[components day] == 0)
                {
                    NSDateComponents *components = [gregorianCalendar components:NSHourCalendarUnit
                            fromDate:addeddate
                            toDate:ServerDate
                            options:0];
                    if ((long)[components hour] == 0)
                    {
                        NSDateComponents *components = [gregorianCalendar components:NSMinuteCalendarUnit
                            fromDate:addeddate
                            toDate:ServerDate
                            options:0];
                        if ((long)[components minute] == 0)
                        {
                            NSDateComponents *components = [gregorianCalendar components:NSSecondCalendarUnit                                
                                fromDate:addeddate
                                toDate:ServerDate
                                options:0];
                            [date setText:[NSString stringWithFormat:@"%ld seconds ago",(long)[components second]]];
                            [cell.contentView addSubview:date];
                        }
                        else if ((long)[components minute] == 1)
                            [date setText:[NSString stringWithFormat:@"%ld minute ago",(long)[components minute]]];
                        else
                            [date setText:[NSString stringWithFormat:@"%ld minutes ago",(long)[components minute]]];
                        [cell.contentView addSubview:date];
                    }
                    else
                    {
                        if ((long)[components hour] == 1)
                            [date setText:[NSString stringWithFormat:@"%ld hour ago",(long)[components hour]]];
                        else
                            [date setText:[NSString stringWithFormat:@"%ld hours ago",(long)[components hour]]];
                        [cell.contentView addSubview:date];
                    }
                }
                else
                {
                    if ((long)[components day] == 1)
                        [date setText:[NSString stringWithFormat:@"%ld day ago",(long)[components day]]];
                    else
                        [date setText:[NSString stringWithFormat:@"%ld days ago",(long)[components day]]];
                    [cell.contentView addSubview:date];
                }

                [cell.contentView addSubview:glyphDate];
            }


            if ( [dictRecord valueForKey:@"Memo"] != NULL &&
                ![[dictRecord objectForKey:@"Memo"] isKindOfClass:[NSNull class]] &&
                ![[dictRecord valueForKey:@"Memo"] isEqualToString:@""] )
            {
                UILabel *label_memo = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 310, 44)];
                [label_memo setBackgroundColor:[UIColor clearColor]];
                [label_memo setTextAlignment:NSTextAlignmentRight];
                NSString * forText = NSLocalizedString(@"History_ForTxt", @"History screen 'For' Text");
                label_memo.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  \"%@\" ",forText,[dictRecord valueForKey:@"Memo"]]
                                                                       attributes:nil];
                label_memo.numberOfLines = 0;
                label_memo.lineBreakMode = NSLineBreakByTruncatingTail;
                [label_memo setStyleClass:@"history_memo"];
                
                if (label_memo.attributedText.length > 36) {
                    [label_memo setStyleClass:@"history_memo_long"];
                }
                [cell.contentView addSubview:label_memo];
                [name setStyleClass:@"history_cell_textlabel_wMemo"];
            }

            [cell.contentView addSubview:pic];
            [cell.contentView addSubview:amount];
            [cell.contentView addSubview:statusIndicator];
            [cell.contentView addSubview:transferTypeLabel];
            [cell.contentView addSubview:name];
        }

        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }

    else if (!isLocalSearch && indexPath.row == [histShowArrayCompleted count])
    {
        if (isEnd == YES)
        {
            if ([histShowArrayCompleted count] == 0)
            {
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        }
        else
        {
            if (isSearch)
            {
                ishistLoading = YES;
                index++;
            }
            else
            {
                if (indexPath.row > 9)
                {
                    ishistLoading = YES;
                    index++;
                    [self loadHist:listType index:index len:20 subType:subTypestr];
                }
            }
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (isLocalSearch)
    {
        NSDictionary *dictRecord = [histTempCompleted objectAtIndex:indexPath.row];
        TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
        [self.navigationController pushViewController:details animated:YES];
        return;
    }
    if ([histShowArrayCompleted count] > indexPath.row)
    {
        NSDictionary * dictRecord = [histShowArrayCompleted objectAtIndex:indexPath.row];
        //NSLog(@"Selected Entry is: %@", dictRecord);
        TransactionDetails *details = [[TransactionDetails alloc] initWithData:dictRecord];
        [self.navigationController pushViewController:details animated:YES];
    }
}

#pragma mark - Date From String
- (NSDate*) dateFromString:(NSString*)aStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setAMSymbol:@"AM"];
    [dateFormatter setPMSymbol:@"PM"];
    dateFormatter.dateFormat = @"M/dd/yyyy hh:mm:ss a";

    NSDate *aDate = [dateFormatter dateFromString:aStr];
    return aDate;
}

#pragma mark - Search Related Methods
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO];
    [self.search resignFirstResponder];
    [self.search setText:@""];

    [UIView animateKeyframesWithDuration:0.2
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      [emptyText_localSearch setAlpha:0];
                                      [self.glyph_emptyTable setAlpha:0];
                                  }];
                              } completion:^(BOOL finished){
                                  if ([self.view.subviews containsObject:emptyText_localSearch] ||
                                      [self.view.subviews containsObject:self.glyph_emptyTable])
                                  {
                                      [emptyText_localSearch setHidden:YES];
                                      [self.glyph_emptyTable setHidden:YES];
                                      
                                      [emptyText_localSearch removeFromSuperview];
                                      [self.glyph_emptyTable removeFromSuperview];
                                  }
                              }
     ];

    isSearch = NO;
    isFilter = NO;
    listType = @"ALL";

    [histShowArrayCompleted removeAllObjects];

    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    countRows = 0;

    [self loadHist:listType index:1 len:20 subType:subTypestr];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar.text length] > 0)
    {
        listType = @"ALL";
        
        SearchString = [[self.search.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"] lowercaseString];

        [histShowArrayCompleted removeAllObjects];

        index = 1;
        isSearch = YES;
        isLocalSearch = NO;
        isFilter = NO;
 
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        [imageCache clearMemory];
        [imageCache clearDisk];
        [imageCache cleanDisk];
        countRows = 0;
        [self loadSearchByName];
    }
    [self.search resignFirstResponder];
}

-(void)searchTableView
{
    [histTempCompleted removeAllObjects];

    NSMutableArray * dictToSearch = nil;

    dictToSearch = [histShowArrayCompleted mutableCopy];
    
    for (NSMutableDictionary * tableViewBind in dictToSearch)
    {
        NSComparisonResult result = [[tableViewBind valueForKey:@"FirstName"] compare:SearchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchString length])];
        NSComparisonResult result2 = [[tableViewBind valueForKey:@"LastName"] compare:SearchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [SearchString length])];
        NSComparisonResult result3 = [[NSString stringWithFormat:@"%@ %@",[tableViewBind valueForKey:@"FirstName"],[tableViewBind valueForKey:@"LastName"]] compare:SearchString
                                                                                                                                                            options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                                                                                                                                                              range:NSMakeRange(0, [SearchString length])];


        if (result == NSOrderedSame || result2 == NSOrderedSame || result3 == NSOrderedSame)
        {
            [histTempCompleted addObject:tableViewBind];
        }
    }

    if ([histTempCompleted count] == 0)
    {
        if ([self.list subviews])
        {
            NSArray * viewsToHide = [self.list subviews];
            for (UIView * v in viewsToHide)
            {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.15];
                [v setAlpha:0];
                [UIView commitAnimations];
            }
        }

        [self.list setStyleId:@"emptyTable"];

        if (![self.view.subviews containsObject:emptyText_localSearch])
        {
            NSShadow * shadow_Dark = [[NSShadow alloc] init];
            shadow_Dark.shadowColor = Rgb2UIColor(88, 90, 92, .7);
            shadow_Dark.shadowOffset = CGSizeMake(0, -1.5);
            NSDictionary * shadowDark = @{NSShadowAttributeName: shadow_Dark};

            emptyText_localSearch = [[UILabel alloc] initWithFrame:CGRectMake(40, 78, 240, 60)];
            [emptyText_localSearch setFont:[UIFont fontWithName:@"Roboto-regular" size:20]];
            [emptyText_localSearch setText:NSLocalizedString(@"History_NoPaymentsFoundByName", @"History screen 'No payments found for that name' Text")];
            [emptyText_localSearch setTextColor:kNoochGrayLight];
            [emptyText_localSearch setTextAlignment:NSTextAlignmentCenter];
            [emptyText_localSearch setNumberOfLines:0];
            [emptyText_localSearch setHidden:NO];
            [emptyText_localSearch setAlpha:0];
            [self.view addSubview:emptyText_localSearch];

            self.glyph_emptyTable = [[UILabel alloc] initWithFrame:CGRectMake(40, 140, 240, 70)];
            [self.glyph_emptyTable setFont:[UIFont fontWithName:@"FontAwesome" size: 58]];
            self.glyph_emptyTable.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-frown-o"] attributes:shadowDark];
            [self.glyph_emptyTable setTextAlignment:NSTextAlignmentCenter];
            [self.glyph_emptyTable setTextColor: kNoochGrayLight];
            [self.glyph_emptyTable setHidden:NO];
            [self.glyph_emptyTable setAlpha:0];
            [self.view addSubview:self.glyph_emptyTable];
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [emptyText_localSearch setAlpha:1];
        [self.glyph_emptyTable setAlpha:1];
        [UIView commitAnimations];
    }
    else if ([histTempCompleted count] > 0)
    {
        [self.list setStyleId:@"history"];

        if ([self.list subviews])
        {
            NSArray * viewsToShow = [self.list subviews];
            for (UIView * v in viewsToShow)
            {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.15];
                [v setAlpha:1];
                [UIView commitAnimations];
            }
        }

        [UIView animateKeyframesWithDuration:0.1
                                       delay:0
                                     options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                  animations:^{
                                      [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                          [emptyText_localSearch setAlpha:0];
                                          [self.glyph_emptyTable setAlpha:0];
                                      }];
                                  } completion:^(BOOL finished){
                                      if ([self.view.subviews containsObject:emptyText_localSearch] ||
                                          [self.view.subviews containsObject:self.glyph_emptyTable])
                                      {
                                          [emptyText_localSearch setHidden:YES];
                                          [self.glyph_emptyTable setHidden:YES];

                                          [emptyText_localSearch removeFromSuperview];
                                          [self.glyph_emptyTable removeFromSuperview];
                                      }
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self.list reloadData];
                                      });
                                  }
         ];
    }
}

-(void)loadSearchByName
{
    RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"History_HUDsearching", @"History screen HUD when searching Text");
    [self.hud show:YES];
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;

    listType = @"ALL";
    isLocalSearch = NO;
    serve * serveOBJ = [serve new];
    serveOBJ.tagName = @"search";
    [serveOBJ setDelegate:self];
    [serveOBJ histMoreSerachbyName:listType sPos:index len:20 name:SearchString subType:subTypestr];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar becomeFirstResponder];
    [searchBar setShowsCancelButton:YES];
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""])
    {
        searchBar.text=@"";
        return;
    }
    if ([searchText length] > 0)
    {
        SearchString = [self.search.text lowercaseString];
        //isEnd = YES;
        isLocalSearch = YES;
        [self searchTableView];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

#pragma mark - file paths
- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"ConnectionErrorAlrtTitle", @"Any screen Connection Error Alert Text")
                          message:NSLocalizedString(@"ConnectionErrorAlrtBody", @"Any screen Connection Error Alert Body Text")
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    NSError *error;
    [self.hud hide:YES];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];

    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location!=NSNotFound)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [user removeObjectForKey:@"UserName"];
        [user removeObjectForKey:@"MemberId"];
        [timer invalidate];
        [nav_ctrl performSelector:@selector(disable)];
        [nav_ctrl performSelector:@selector(reset)];
        [nav_ctrl popViewControllerAnimated:YES];
        Register *reg = [Register new];
        [nav_ctrl pushViewController:reg animated:YES];
        me = [core new];
        return;
    }

    if ([tagName isEqualToString:@"csv"])
    {
        NSDictionary * dictResponse = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if ([[[dictResponse valueForKey:@"sendTransactionInCSVResult"]valueForKey:@"Result"]isEqualToString:@"1"])
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"History_ExprtSuccessAlrtTitle", @"History screen export successful Alert Title")
                                                            message:[NSString stringWithFormat:@"\xF0\x9F\x93\xA5\n%@", NSLocalizedString(@"History_ExprtSuccessAlrtBody", @"History screen export successful Alert Body Text")]
                                                           delegate:Nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:Nil, nil];
            [alert show];
        }
    }

    else if ([tagName isEqualToString:@"hist"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hud hide:YES];
        });

        if ([self.list subviews])
        {
            NSArray * viewsToShow = [self.list subviews];
            for (UIView * v in viewsToShow)
            {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.15];
                [v setAlpha:1];
                [UIView commitAnimations];
            }
        }

        histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        if ([histArray count] > 0)
        {
            [self.list setStyleId:@"history"];

            isEnd = NO;
            isStart = NO;

            for (NSDictionary * dict in histArray)
            {
                if ( [[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Success"]   ||
                    ([[dict valueForKey:@"TransactionType"]isEqualToString:@"Disputed"] &&
                     [[dict valueForKey:@"DisputeStatus"]isEqualToString:@"Resolved"]) )
                {
                    [histShowArrayCompleted addObject:dict];
                }
            }

            if ([self.list.subviews containsObject:_emptyPic])
            {
                [UIView animateKeyframesWithDuration:0.3
                                               delay:0
                                             options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                          animations:^{
                                              [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 animations:^{
                                                  [_emptyText setAlpha:0];
                                                  [_emptyPic setAlpha:0];
                                              }];
                                          } completion: ^(BOOL finished) {
                                              [_emptyText removeFromSuperview];
                                              [_emptyPic removeFromSuperview];
                                          }
                 ];
            }
        }
        else if ([histArray count] == 0)
        {
            isEnd = YES;
        }

        serve * serveOBJ = [serve new];
        [serveOBJ setDelegate:self];
        [serveOBJ setTagName:@"time"];
        [serveOBJ GetServerCurrentTime];

        if (!isLocalSearch)
        {
            if (isEnd == YES)
            {
                if ([histShowArrayCompleted count] == 0)
                {
                    [self.list setStyleId:@"emptyTable"];
                    [_emptyPic setImage:[UIImage imageNamed:@"HistoryPending"]];

                    if ([[UIScreen mainScreen] bounds].size.height > 500)
                    {
                        [_emptyText setFont:[UIFont fontWithName:@"Roboto-light" size:19]];
                    }
                    else
                    {
                        [_emptyText setFont:[UIFont fontWithName:@"Roboto-light" size:18]];
                        [_emptyPic setFrame:CGRectMake(33, 78, 253, 256)];
                    }
                    [_emptyText setNumberOfLines:0];
                    [_emptyText setTextAlignment:NSTextAlignmentCenter];

                    if ([[UIScreen mainScreen] bounds].size.height > 500)
                    {
                        [_emptyText setFrame:CGRectMake(15, 14, 290, 68)];
                    }
                    else
                    {
                        [_emptyText setFrame:CGRectMake(15, 5, 290, 68)];
                    }
                    [_emptyText setText:NSLocalizedString(@"History_EmptyCompletedTxt", @"History screen when there are no Completed payments to display text")];
                    [_emptyPic setStyleClass:@"animate_bubble"];

                    if (![self.list.subviews containsObject:_emptyPic] ||
                        ![self.list.subviews containsObject:_emptyText])
                    {
                        [self.list addSubview: _emptyPic];
                        [self.list addSubview: _emptyText];

                        [UIView animateKeyframesWithDuration:0.3
                                                       delay:0
                                                     options:0 << 16
                                                  animations:^{
                                                      [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 animations:^{
                                                          [_emptyText setAlpha:1];
                                                          [_emptyPic setAlpha:1];
                                                      }];
                                                  } completion: nil
                         ];
                        
                    }

                    [exportHistory removeFromSuperview];
                }
            }
        }
    }

    else if ([tagName isEqualToString:@"time"])
    {
        //ServerDate
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        ServerDate = [self dateFromString:[dict valueForKey:@"Result"] ];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.list reloadData];
        });
        
        if ([histShowArrayCompleted count] > 0)
        {
            [self.list scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:countRows inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
             countRows = [histShowArrayCompleted count];
        }
        [self.view bringSubviewToFront:exportHistory];
    }

    else if ([tagName isEqualToString:@"search"])
    {
        [self.hud hide:YES];
        histArray = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        if ([histArray count] > 0)
        {
            isEnd = NO;
            isStart = NO;
            
            for (NSDictionary * dict in histArray)
            {
                if ([[dict valueForKey:@"TransactionStatus"]isEqualToString:@"Success"])
                {
                    [histShowArrayCompleted addObject:dict];
                }
            }

            serve * serveOBJ = [serve new];
            [serveOBJ setDelegate:self];
            [serveOBJ setTagName:@"time"];
            [serveOBJ GetServerCurrentTime];
        }
        else
        {
            isEnd = YES;
        }
    }

    if ([tagName isEqualToString:@"email_verify"])
    {
        NSString *response = [[NSJSONSerialization
                               JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                               options:kNilOptions
                               error:&error] objectForKey:@"Result"];
        if ([response isEqualToString:@"Already Activated."])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@""
                                                         message:@"Your email has already been verified."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
        else if ([response isEqualToString:@"Not a nooch member."])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@""
                                                         message:NSLocalizedString(@"History_ErrorAlrtBody", @"History screen generic error Alert Body Text")
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
        else if ([response isEqualToString:@"Success"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Check Your Email"
                                                         message:[NSString stringWithFormat:@"\xF0\x9F\x93\xA5\nA verifiction link has been sent to %@.",[user objectForKey:@"UserName"]]
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
        else if ([response isEqualToString:@"Failure"])
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@""
                                                         message:NSLocalizedString(@"History_ErrorAlrtBody", @"History screen generic error Alert Body Text")
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
    }
}

-(IBAction)ExportHistory:(id)sender
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"History_ExportAlrtTitle", @"History screen export transfer data Alert Title")
                                                     message:NSLocalizedString(@"History_ExportAlrtBody", @"History screen export transfer data Alert Body Text")
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"CancelTxt", @"Any screen 'Cancel' Button Text")
                                           otherButtonTitles:NSLocalizedString(@"History_SendTxt", @"History screen 'Send' Button Text"), nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 11;

    UITextField *textField = [alert textFieldAtIndex:0];
    textField.text = [user objectForKey:@"UserName"];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    [alert show];
}

#pragma mark - Alert View Handling
-(void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 11 && buttonIndex == 1) // export history
    {
        NSString * email = [[actionSheet textFieldAtIndex:0] text];
        serve * s = [[serve alloc] init];
        [s setTagName:@"csv"];
        [s setDelegate:self];
        [s sendCsvTrasactionHistory:email];
    }

    else if (actionSheet.tag == 51 && buttonIndex == 1)  // Resend Email Verificaiton Link
    {
        serve * email_verify = [serve new];
        [email_verify setDelegate:self];
        [email_verify setTagName:@"email_verify"];
        [email_verify resendEmail];
    }

    else if (actionSheet.tag == 52 && buttonIndex == 1)  // No bank attached, go to Settings
    {
        SettingsOptions * mainSettingsScrn = [SettingsOptions new];
        [nav_ctrl pushViewController:mainSettingsScrn animated:YES];
        [self.slidingViewController resetTopView];
    }

    else if (actionSheet.tag == 53 && buttonIndex == 1)  // No bank attached, go to Settings
    {
        shouldDisplayBankNotVerifiedLtBox = YES;
        SettingsOptions * mainSettingsScrn = [SettingsOptions new];
        [nav_ctrl pushViewController:mainSettingsScrn animated:YES];
        [self.slidingViewController resetTopView];
    }
    
    else if (actionSheet.tag == 50 && buttonIndex == 1) // Contact Support
    {
        if (![MFMailComposeViewController canSendMail])
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"No Email Detected"
                                                                message:@"You don't have an email account configured for this device."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
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
        [mailComposer setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
}

#pragma mark - Mail Controller
-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
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

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    // Dispose of any resources that can be recreated.
}
@end