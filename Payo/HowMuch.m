//  HowMuch.m
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.

#import "HowMuch.h"
#import "TransferPIN.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Resize.h"
#import "SelectRecipient.h"
@interface HowMuch ()
@property(nonatomic,strong) NSDictionary *receiver;
@property(nonatomic,strong) UITextField *amount;
@property(nonatomic,strong) UITextField *memo;
@property(nonatomic,strong) UIButton *send;
@property(nonatomic,strong) UIButton *reset_type;
@property(nonatomic) NSMutableString *amnt;
@property(nonatomic) BOOL decimals;
@property(nonatomic,strong) UIView *shade;
@property(nonatomic,strong) UIView *choose;
@property(nonatomic,strong) UILabel *recip_back;
@property(nonatomic,strong) UIView *back;
@property(nonatomic,strong) UIButton *trans_image;
@property(nonatomic,strong) UIImageView * user_pic;

@end

@implementation HowMuch

- (id)initWithReceiver:(NSDictionary *)receiver
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.receiver = [receiver copy];
        NSLog(@"Selected Recipient is: %@",self.receiver);
    }
    return self;
}

-(void)backPressed:(id)sender
{
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.topItem.title = @"";

    [self.navigationItem setTitle:NSLocalizedString(@"HowMuch_ScrnTitle", @"How Much Screen Title")];
    [self.navigationItem setHidesBackButton:YES];

    NSShadow * shadowNavText = [[NSShadow alloc] init];
    shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
    NSDictionary * titleAttributes = @{NSShadowAttributeName: shadowNavText};

    UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backPressed:)];

    UILabel * back_button = [UILabel new];
    [back_button setStyleId:@"navbar_back"];
    [back_button setUserInteractionEnabled:YES];
    [back_button addGestureRecognizer: backTap];
    back_button.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] attributes:titleAttributes];

    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];

    [self.navigationItem setLeftBarButtonItem:menu];
    [self.navigationItem setRightBarButtonItem:Nil];

    self.amnt = [@"" mutableCopy];

    self.decimals = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashPageBckgrnd-568h@2x.png"]];
    backgroundImage.alpha = .3;
    [self.view addSubview:backgroundImage];

    self.back = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 248)];
    [self.back setStyleClass:@"raised_view"];

    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        [self.back setStyleClass:@"howmuch_mainbox_smscrn"];
    }
    else {
        [self.back setStyleClass:@"howmuch_mainbox"];
    }
    self.back.layer.cornerRadius = 4;
    [self.back setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.back];

    self.recip_back = [UILabel new];
    [self.recip_back setStyleClass:@"barbackground"];
    [self.recip_back setStyleClass:@"barbackground_gray"];
    self.recip_back.clipsToBounds = YES;
    [self.back addSubview:self.recip_back];

    NSShadow * shadow = [[NSShadow alloc] init];
    shadow.shadowColor = Rgb2UIColor(64, 65, 66, .3);
    shadow.shadowOffset = CGSizeMake(0, 1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow };

    UILabel * to = [UILabel new];
    to.attributedText = [[NSAttributedString alloc] initWithString:@"To: " attributes:textAttributes];
    [to setStyleId:@"label_howmuch_to"];
    [self.back addSubview:to];

    UILabel * to_label = [[UILabel alloc] initWithFrame:CGRectMake(43, 0, 300, 38)];
    [to_label setStyleId:@"label_howmuch_recipientname"];

    if ([self.receiver objectForKey:@"FirstName"])
    {
        to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", [[self.receiver objectForKey:@"FirstName"] capitalizedString],[[self.receiver objectForKey:@"LastName"] capitalizedString]]
                                                                  attributes:textAttributes];
    }
    else if ([self.receiver objectForKey:@"firstName"] && [self.receiver objectForKey:@"lastName"])
    {
        to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", [self.receiver objectForKey:@"firstName"], [self.receiver objectForKey:@"lastName"]] attributes:textAttributes];
    }
    else if (isFromArtisanDonationAlert && [self.receiver objectForKey:@"FirstName"] && [self.receiver objectForKey:@"LastName"])
    {
        to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", [self.receiver objectForKey:@"FirstName"], [self.receiver objectForKey:@"LastName"]] attributes:textAttributes];
    }
    else if ([self.receiver objectForKey:@"firstName"])
    {
        to_label.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [self.receiver objectForKey:@"firstName"]] attributes:textAttributes];
    }

    UILabel * glyph_nonuserType = [[UILabel alloc] initWithFrame:CGRectMake(275, 0, 20, 38)];
    [glyph_nonuserType setTextColor:[UIColor whiteColor]];
    [glyph_nonuserType setFont:[UIFont fontWithName:@"FontAwesome" size:17]];
    glyph_nonuserType.attributedText = [[NSAttributedString alloc]initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-user"] attributes:textAttributes];


    self.user_pic = [UIImageView new];
    [self.user_pic setFrame:CGRectMake(12, 48, 84, 84)];
    self.user_pic.layer.borderColor = kNoochGrayLight.CGColor;
    self.user_pic.layer.borderWidth = 2;
    self.user_pic.clipsToBounds = YES;
    self.user_pic.layer.cornerRadius = 42;
    if ([self.receiver valueForKey:@"nonuser"])
    {
        [self.user_pic setImage:[UIImage imageNamed:@"profile_picture.png"]];
    }
    else
    {
        [self.user_pic setHidden:NO];
        if (self.receiver[@"Photo"])
        {
            [self.user_pic sd_setImageWithURL:[NSURL URLWithString:self.receiver[@"Photo"]]
                     placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        }
        else
        {
            [self.user_pic sd_setImageWithURL:[NSURL URLWithString:self.receiver[@"PhotoUrl"]]
                             placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];

        }
    }

    [self.back addSubview:glyph_nonuserType];
    [self.back addSubview:to_label];
    [self.back addSubview:self.user_pic];

    self.amount = [[UITextField alloc] initWithFrame:CGRectMake(104, 58, 190, 68)];
    [self.amount setTextAlignment:NSTextAlignmentRight];
    [self.amount setPlaceholder:@"$ 0.00"];
    [self.amount setDelegate:self];
    [self.amount setTag:1];
    [self.amount setKeyboardType:UIKeyboardTypeNumberPad];
    [self.amount setInputAccessoryView:[[UIView alloc] init]];
    [self.amount setStyleId:@"howmuch_amountfield"];
    [self.back addSubview:self.amount];
    [self.amount becomeFirstResponder];

    UIView * memoShell = [[UIView alloc] initWithFrame:CGRectMake(8, 148, 288, 38)];
    memoShell.layer.cornerRadius = 3;
    memoShell.layer.borderWidth = 1;
    memoShell.layer.borderColor = kNoochGrayLight.CGColor;


    self.memo = [[UITextField alloc] initWithFrame:CGRectMake(2, 0, 255, 38)];
    [self.memo setFont:[UIFont fontWithName:@"Roboto-light" size:16]];
    [self.memo setPlaceholder:NSLocalizedString(@"HowMuch_MemoPlaceholder", @"How Much memo placeholder text")];
    [self.memo setText:[self.receiver objectForKey:@"Memo"]];
    [self.memo setTextAlignment:NSTextAlignmentCenter];
    [self.memo setTextColor:kNoochGrayDark];
    [self.memo setDelegate:self];
    [self.memo setTag:2];
    [self.memo setKeyboardType:UIKeyboardTypeDefault];
    self.memo.inputAccessoryView = [[UIView alloc] init]; // To override the IQ Keyboard Mgr

    self.send = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.send setFrame:CGRectMake(160, 194, 150, 50)];
    [self.send setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.send setTitle:NSLocalizedString(@"HowMuch_SendBtn", @"How Much send button text") forState:UIControlStateNormal];
    [self.send setTitleShadowColor:Rgb2UIColor(26, 38, 19, 0.21) forState:UIControlStateNormal];
    self.send.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.send addTarget:self action:@selector(initialize_send) forControlEvents:UIControlEventTouchUpInside];

    self.reset_type = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.reset_type setFrame:CGRectMake(132, 194, 0, 56)];
    [self.reset_type setBackgroundColor:[UIColor clearColor]];
    [self.reset_type setStyleId:@"reset_glyph"];
    [self.reset_type setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"] forState:UIControlStateNormal];
    [self.reset_type setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.22) forState:UIControlStateNormal];
    self.reset_type.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [self.reset_type addTarget:self action:@selector(reset_send_request) forControlEvents:UIControlEventTouchUpInside];
    [self.reset_type setAlpha:0];


    if (isFromArtisanDonationAlert)
    {
        [self.send setStyleClass:@"howmuch_buttons"];
        [self.send setStyleId:@"howmuch_send"];
        if (isFromArtisanDonationAlert)
        {
            [self.send setTitle:@"Confirm Donation" forState:UIControlStateNormal];
        }
        else
        {
            [self.send setTitle:NSLocalizedString(@"HowMuch_ConfirmSend", @"How Much confirm send payment text") forState:UIControlStateNormal];
        }
        [self.send removeTarget:self action:@selector(initialize_send) forControlEvents:UIControlEventTouchUpInside];
        [self.send addTarget:self action:@selector(confirm_send) forControlEvents:UIControlEventTouchUpInside];
        [self.back addSubview:self.send];
    }
    else
    {
        [self.send setStyleClass:@"howmuch_buttons"];
        [self.send setStyleId:@"howmuch_send"];
        [self.back addSubview:self.send];
    }

    [self.back addSubview:self.reset_type];
    
    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        [self.reset_type setFrame:CGRectMake(132, 136, 0, 56)];
        [self.send setStyleId:@"howmuch_send_4"];

        [self.user_pic setFrame:CGRectMake(6, 45, 72, 72)];
        self.user_pic.layer.cornerRadius = 36;

        [self.amount setStyleId:@"howmuch_amountfield_4"];

        [memoShell setFrame:CGRectMake(83, 98, 212, 31)];
        [self.memo setFrame:CGRectMake(1, 0, 211, 31)];
        [self.memo setFont:[UIFont fontWithName:@"Roboto-light" size:15]];
    }

    [self.back addSubview:memoShell];
    [memoShell addSubview:self.memo];

    transLimitFromArtisanString = [ARPowerHookManager getValueForHookById:@"transLimit"];
    transLimitFromArtisanInt = [transLimitFromArtisanString floatValue];
    [ARTrackingManager trackEvent:@"HowMuch_viewDidLoad_End"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.amount becomeFirstResponder];
    [self.navigationController setNavigationBarHidden:NO];

    NSShadow * shadowNavText = [[NSShadow alloc] init];
    shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
    NSDictionary * titleAttributes = @{NSShadowAttributeName: shadowNavText};

    UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backPressed:)];

    UILabel * back_button = [UILabel new];
    [back_button setStyleId:@"navbar_back"];
    [back_button setUserInteractionEnabled:YES];
    [back_button addGestureRecognizer: backTap];
    back_button.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] attributes:titleAttributes];

    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];

    [self.navigationItem setLeftBarButtonItem:menu];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"How Much Screen";
    self.artisanNameTag = @"How Much Screen";

    [self.amount becomeFirstResponder];

    [self.navigationItem setTitle:NSLocalizedString(@"HowMuch_ScrnTitle", @"How Much Screen Title")];
}

#pragma mark - type of transaction
-(void)initialize_send
{
    [self.recip_back setStyleClass:@"barbackground_green"];

    CGRect origin = self.reset_type.frame;
    origin.origin.x = 10;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.55];

    origin.size.width = 149;
    origin.origin.x = 162;

    self.user_pic.layer.borderColor = kPayoGreen.CGColor;

    [self.send addTarget:self action:@selector(confirm_send) forControlEvents:UIControlEventTouchUpInside];
    [self.send setTitle:NSLocalizedString(@"HowMuch_ConfirmSend", @"How Much confirm send payment text") forState:UIControlStateNormal];
    [self.reset_type setAlpha:1];
    [self.reset_type setStyleId:@"cancel_request"];
    [self.back bringSubviewToFront:self.reset_type];

    [UIView commitAnimations];
}

-(void)reset_send_request
{
    [self.recip_back setStyleClass:@"barbackground_gray"];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];

    self.user_pic.layer.borderColor = [Helpers hexColor:@"939598"].CGColor;

    [self.send setTitle:@"Send" forState:UIControlStateNormal];

    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        [self.send setStyleId:@"howmuch_send_4"];
    }
    else
    {
        [self.send setStyleId:@"howmuch_send"];
    }

    [self.send removeTarget:self action:@selector(confirm_send) forControlEvents:UIControlEventTouchUpInside];
    [self.send addTarget:self action:@selector(initialize_send) forControlEvents:UIControlEventTouchUpInside];

    [self.reset_type setAlpha:0];
    [UIView commitAnimations];
}

-(void)confirm_send
{
    if ([self.amnt floatValue] == 0)
    {
        NSString * alertMessage = @"";

        if ([self.receiver valueForKey:@"nonuser"] && ![self.receiver objectForKey:@"firstName"])
        {
            alertMessage = [NSString stringWithFormat:@"\xF0\x9F\x98\xAC\n%@", NSLocalizedString(@"HowMuch_CnfrmSndZeroNoNameAlertText", @"How Much confirm send with zero amount and no first or last name alert body text")];
        }
        else if ([self.receiver valueForKey:@"nonuser"] && [self.receiver objectForKey:@"firstName"])
        {
            alertMessage = [NSString stringWithFormat:@"\xF0\x9F\x98\xAC\n%@", [NSString stringWithFormat:NSLocalizedString(@"HowMuch_CnfrmSndZeroFirstNameAlertText", @"How Much confirm send with zero amount and only first name alert body text"),[[self.receiver objectForKey:@"firstName"] capitalizedString]]];
        }
        else
        {
            //@"\xF0\x9F\x98\xAC\nPlease enter a value over $0.\n\nWe'd love to send a $0 payment to %@, but it's actually rather tricky."
            alertMessage = [NSString stringWithFormat:NSLocalizedString(@"HowMuch_CnfrmSndZeroFirstNameAlertText", @"How Much confirm send with zero amount and only first name alert body text"),[[self.receiver objectForKey:@"FirstName"] capitalizedString]];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Non-cents!"
                                                        message:alertMessage
                                                        delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    else if ([[[self.amount text] substringFromIndex:1] doubleValue] > transLimitFromArtisanInt)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HowMuch_CnfrmSndOverLimitAlertTitle", @"How Much confirm send when amount is over limit Alert Title")
                                                        message:[NSString stringWithFormat:@"\xF0\x9F\x98\xB3\n%@", [NSString stringWithFormat:NSLocalizedString(@"HowMuch_CnfrmSndOverLimitAlertBody", @"How Much confirm send when amount is over limit Alert Body Text"), transLimitFromArtisanString]]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }

    NSMutableDictionary *transaction = [self.receiver mutableCopy];
    [transaction setObject:[self.memo text] forKey:@"memo"];
    float input_amount = [[[self.amount text] substringFromIndex:1] floatValue];

    [self.navigationItem setLeftBarButtonItem:nil];

    TransferPIN *pin;

    if ([self.receiver valueForKey:@"nonuser"]) {
        pin = [[TransferPIN alloc] initWithReceiver:transaction type:@"send" amount:input_amount];
    }
    else {
        pin = [[TransferPIN alloc] initWithReceiver:transaction type:@"send" amount:input_amount];
    }
    [self.navigationController pushViewController:pin animated:YES];
}

#pragma mark - UITextField delegation
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 1)
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setGeneratesDecimalNumbers:YES];
        [formatter setUsesGroupingSeparator:YES];

        NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
        [formatter setGroupingSeparator:groupingSeparator];
        [formatter setGroupingSize:3];
        
        if ([string length] == 0) //backspace
        {
            if ([self.amnt length] > 0)
            {
                self.amnt = [[self.amnt substringToIndex:[self.amnt length] - 1] mutableCopy];
            }
        }
        else
        {
            NSString * temp = [self.amnt stringByAppendingString:string];
            self.amnt = [temp mutableCopy];
        }

        float maths = [self.amnt floatValue];
        maths /= 100;

        if (maths > 1000)
        {
            self.amnt = [[self.amnt substringToIndex:[self.amnt length] - 1] mutableCopy];
            return NO;
        }

        if (maths != 0)
        {
            [textField setText:[formatter stringFromNumber:[NSNumber numberWithFloat:maths]]];
        } 
        else
        {
            [textField setText:@""];
        }
        return NO;
    }
    if (textField.tag == 2)
    {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 55) ? NO : YES;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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