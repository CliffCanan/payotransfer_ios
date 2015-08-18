//
//  NotificationSettings.m
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import "NotificationSettings.h"
#import "Home.h"

@interface NotificationSettings ()
@property(nonatomic,strong) UISwitch *email_sent;
@property(nonatomic,strong) UISwitch *email_unclaimed;
@property(nonatomic,strong) UITableView * transfers_table;
@property(nonatomic,strong) UIButton * btn_glyphEmail_1;
@property(nonatomic,strong) UIButton * btn_glyphPush_1;
@property(nonatomic,strong) UIButton * btn_glyphEmail_2;
@property(nonatomic,strong) UIButton * btn_glyphPush_2;
@property(nonatomic,strong) MBProgressHUD *hud;
@end

@implementation NotificationSettings

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Notification Settings Screen";
    self.artisanNameTag = @"Notification Settings Screen";
    [ARTrackingManager trackEvent:@"History_tggleMapByNavBtn"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.topItem.title = @"";

    [self.navigationItem setTitle:NSLocalizedString(@"NotifSettings_ScrnTitle", @"Notification Settings screen title")];

    [self.view setBackgroundColor:[UIColor whiteColor]];

    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setHidesBackButton:YES];

    NSShadow * shadowNavText = [[NSShadow alloc] init];
    shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
    NSDictionary * titleAttributes = @{NSShadowAttributeName: shadowNavText};

    UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backtn)];

    UILabel * back_button = [UILabel new];
    [back_button setStyleId:@"navbar_back"];
    [back_button setUserInteractionEnabled:YES];
    [back_button addGestureRecognizer: backTap];
    back_button.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] attributes:titleAttributes];

    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];

    [self.navigationItem setLeftBarButtonItem:menu];

    allOn_sec1_email = false;
    allOn_sec2_email = false;
    allOn_sec2_push = false;

    self.transfers_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 26, 320, 145)];
    [self.transfers_table setDataSource:self];
    [self.transfers_table setDelegate:self];
    [self.transfers_table setUserInteractionEnabled:NO];
    [self.view addSubview:self.transfers_table];
    [self.transfers_table reloadData];

    self.btn_glyphEmail_1 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn_glyphEmail_1.frame = CGRectMake(180, 0, 50, 36);
    [self.btn_glyphEmail_1 setStyleClass:@"font-awesome"];
    [self.btn_glyphEmail_1 setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-envelope-o"] forState:UIControlStateNormal];
    [self.btn_glyphEmail_1 setTitleColor:kPayoBlue forState:UIControlStateHighlighted];
    [self.btn_glyphEmail_1 addTarget:self action:@selector(toggle_section:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn_glyphEmail_1];

    self.btn_glyphPush_1 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn_glyphPush_1.frame = CGRectMake(260, 0, 50, 39);
    [self.btn_glyphPush_1 setStyleClass:@"fontAwesome_bigger"];
    [self.btn_glyphPush_1 setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-mobile"] forState:UIControlStateNormal];
    [self.btn_glyphPush_1 setTitleColor:kPayoGreen forState:UIControlStateHighlighted];
    [self.btn_glyphPush_1 addTarget:self action:@selector(toggle_section:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn_glyphPush_1];

    /*self.btn_glyphEmail_2 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn_glyphEmail_2.frame = CGRectMake(180, 177, 50, 36);
    [self.btn_glyphEmail_2 setStyleClass:@"font-awesome"];
    [self.btn_glyphEmail_2 setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-envelope-o"] forState:UIControlStateNormal];
    [self.btn_glyphEmail_2 setTitleColor:kPayoBlue forState:UIControlStateHighlighted];
    [self.btn_glyphEmail_2 addTarget:self action:@selector(toggle_section:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn_glyphEmail_2];

    self.btn_glyphPush_2 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn_glyphPush_2.frame = CGRectMake(260, 177, 50, 39);
    [self.btn_glyphPush_2 setStyleClass:@"fontAwesome_bigger"];
    [self.btn_glyphPush_2 setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-mobile"] forState:UIControlStateNormal];
    [self.btn_glyphPush_2 setTitleColor:kPayoGreen forState:UIControlStateHighlighted];
    [self.btn_glyphPush_2 addTarget:self action:@selector(toggle_section:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btn_glyphPush_2];*/

    self.email_sent = [[UISwitch alloc] initWithFrame:CGRectMake(180, 38, 40, 30)];
    self.email_sent.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.email_sent setOnTintColor:kPayoBlue];
    [self.email_sent addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.email_sent.tag = 103;

    self.email_unclaimed = [[UISwitch alloc] initWithFrame:CGRectMake(180, 88, 40, 30)];
    self.email_unclaimed.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [self.email_unclaimed setOnTintColor:kPayoBlue];
    [self.email_unclaimed addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    self.email_unclaimed.tag = 104;

    [self.view addSubview:self.email_sent];
    [self.view addSubview:self.email_unclaimed];

    RTSpinKitView *spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"NotifSettings_HUDtxt", @"Notification Settings HUD loading text");
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    [self.hud show:YES];

    serve * serveOBJ = [serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName = @"getSettings";
    [serveOBJ MemberNotificationSettingsInput];
}

-(void)toggle_section:(UIButton*)glyph_selected
{
    if (glyph_selected == self.btn_glyphEmail_1)
    {
        if (allOn_sec1_email) {
            [self.email_sent setOn:NO animated:YES];
            [self.email_unclaimed setOn:NO animated:YES];
            allOn_sec1_email = false;
        }
        else {
            [self.email_sent setOn:YES animated:YES];
            [self.email_unclaimed setOn:YES animated:YES];
            allOn_sec1_email = true;
        }
    }
    else if (glyph_selected == self.btn_glyphPush_1)
    {

    }
}

-(void)changeSwitch:(UISwitch*)switchRef
{
    NSUInteger tag = switchRef.tag;
    switch (tag)
    {
        case 101:
            servicePath = @"email";
            serviceType = @"email_received";
            [self setService];
            break;
        case 102:
            servicePath = @"push";
            serviceType = @"push_received";
            [self setService];
            break;
        case 103:
            servicePath = @"email";
            serviceType = @"email_sent";
            [self setService];
            break;
        case 104:
            servicePath = @"email";
            serviceType = @"email_unclaimed";
            [self setService];
            break;
        default:
            break;
    }
}

-(void)setService
{
    NSDictionary *transactionInput1;

    if ([servicePath isEqualToString:@"push"])
    {
        transactionInput1 = [NSDictionary dictionaryWithObjectsAndKeys:
                             [user stringForKey:@"MemberId"],@"MemberId",
                             @"NoochToBank",@"BankToNooch",
                             @"0",@"TransferReceived",
                             nil];
    }
    else
    {
        transactionInput1 = [NSDictionary dictionaryWithObjectsAndKeys:[user stringForKey:@"MemberId"],@"MemberId",
                             @"0",@"EmailTransferReceived",
                             [self.email_sent isOn]?@"1":@"0",@"EmailTransferSent",
                             [self.email_unclaimed isOn]?@"1":@"0",
                             @"TransferUnclaimed",@"NoochToBankRequested",@"NoochToBankCompleted",@"BankToNoochCompleted",@"BankToNoochRequested",nil];
    }

    serve * serveOBJ = [serve new];
    [serveOBJ setDelegate:self];
    serveOBJ.tagName = @"setSettings";
    [serveOBJ MemberNotificationSettings:transactionInput1 type:servicePath];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.transfers_table)
    {
        return 2;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        
        [cell.textLabel setTextColor:kPayoBlue];
        cell.indentationLevel = 1;
        cell.indentationWidth = 10;
    }

    [cell.textLabel setStyleClass:@"table_view_cell_textlabel_2"];

    if (tableView == self.transfers_table)
    {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"NotifSettings_Row2", @"Notification Settings row lbl - 'Transfer Sent'");
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"NotifSettings_Row3", @"Notification Settings row lbl - 'Transfer Unclaimed'");
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

-(void)backtn {
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];
}

#pragma mark - server delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    if ([tagName isEqualToString:@"getSettings"])
    {
        NSError * error;
        dictInput = [NSJSONSerialization
                   JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                   options:kNilOptions
                   error:&error];
        NSLog(@"%@",dictInput);
        
        [self.hud hide:YES];

        // Transfer Sent
        if ([[dictInput objectForKey:@"EmailTransferSent"]boolValue]) {
            [self.email_sent setOn:YES];
        }
        else {
            [self.email_sent setOn:NO];
        }

        // Transfer Unclaimed
        if ([[dictInput objectForKey:@"TransferUnclaimed"]boolValue]) {
            [self.email_unclaimed setOn:YES];
        }
        else {
            [self.email_unclaimed setOn:NO];
        }

        if (self.email_unclaimed.isOn && self.email_sent.isOn) {
            allOn_sec1_email = true;
        }

    }

    else if ([tagName isEqualToString:@"setSettings"])
    {
        NSError * error;
        dictSettings = [NSJSONSerialization
                      JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                      options:kNilOptions
                      error:&error];

        NSLog(@"%@",dictSettings);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end