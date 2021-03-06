//  CreatePIN.m
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.

#import "CreatePIN.h"
#import "Home.h"
#import "ReferralCode.h"

@interface CreatePIN ()
@property(nonatomic,retain) UIView *first_num;
@property(nonatomic,retain) UIView *second_num;
@property(nonatomic,retain) UIView *third_num;
@property(nonatomic,retain) UIView *fourth_num;
@property(nonatomic,strong) UILabel *prompt;
@property(nonatomic,strong) UITextField *pin;
@property(nonatomic,strong) NSString *pin_check;
@property(nonatomic,strong) NSMutableDictionary *user;
@end

@implementation CreatePIN

- (id)initWithData:(NSDictionary *)usr
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.user = [usr mutableCopy];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pin_check = @"";
 
    self.screenName = @"Create PIN Screen";
    self.artisanNameTag = @"Create PIN Screen";

    [self.pin setText:@""];
    [self.first_num setBackgroundColor:[UIColor clearColor]];
    [self.second_num setBackgroundColor:[UIColor clearColor]];
    [self.third_num setBackgroundColor:[UIColor clearColor]];
    [self.fourth_num setBackgroundColor:[UIColor clearColor]];
    [self.prompt setText:NSLocalizedString(@"CreatePIN_Instruc1", @"Create PIN screen Initial Instruction Text")];
}

#pragma mark - UITextField delegation
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger len = [textField.text length] + [string length];
    
    if ([string length] == 0) { //deleting
        switch (len) {
            case 4:
                [self.fourth_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 3:
                [self.third_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 2:
                [self.second_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 1:
                [self.first_num setBackgroundColor:[UIColor clearColor]];
                break;
            case 0:
                break;
            default:
                break;
        }
    }
    else
    {
        UIColor *which = kPayoGreen;
        switch (len)
        {
            case 5:
                return NO;
                break;
            case 4:
                [self.fourth_num setBackgroundColor:which];
                if ([self.pin_check length] != 4)
                {
                    self.pin_check = [NSString stringWithFormat:@"%@%@",textField.text,string];
                    [self.prompt setText:NSLocalizedString(@"CreatePIN_CnfrmPin", @"Create PIN screen 'Confirm PIN' Text")];
                    [self.pin setText:@""];
                    [self.first_num setBackgroundColor:[UIColor clearColor]];
                    [self.second_num setBackgroundColor:[UIColor clearColor]];
                    [self.third_num setBackgroundColor:[UIColor clearColor]];
                    [self.fourth_num setBackgroundColor:[UIColor clearColor]];
                    return NO;
                }
                else
                {
                    if ([self.pin_check isEqualToString:[NSString stringWithFormat:@"%@%@",textField.text,string]])
                    {
                        [self.user setObject:[NSString stringWithFormat:@"%@%@",textField.text,string] forKey:@"pin_number"];
                        //push invite code
                        ReferralCode *code_entry = [[ReferralCode alloc] initWithData:self.user];
                        [self.navigationController pushViewController:code_entry animated:YES];
                    }
                    else
                    {
                        self.pin_check = @"";
                        [self.pin setText:@""];
                        [self.prompt setText:NSLocalizedString(@"CreatePIN_NoMatch", @"Create PIN screen PINs don't match feedback Text Instruction Text")];
                        [self.prompt setTextColor:kPayoRed];
                        [self.first_num setBackgroundColor:[UIColor clearColor]];
                        [self.second_num setBackgroundColor:[UIColor clearColor]];
                        [self.third_num setBackgroundColor:[UIColor clearColor]];
                        [self.fourth_num setBackgroundColor:[UIColor clearColor]];
                        return NO;
                    }
                }
                break;
            case 3:
                [self.third_num setBackgroundColor:which];
                break;
            case 2:
                [self.second_num setBackgroundColor:which];
                break;
            case 1:
                [self.first_num setBackgroundColor:which];
                break;
            case 0:
                break;
            default:
                break;
        }
    }
    return YES;
}

-(void) BackClicked:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Back button
    UIButton *btnback = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnback setBackgroundColor:[UIColor whiteColor]];
    [btnback setFrame:CGRectMake(7, 20, 44, 44)];
    [btnback addTarget:self action:@selector(BackClicked:) forControlEvents:UIControlEventTouchUpInside];

    UILabel *glyph_back = [UILabel new];
    [glyph_back setBackgroundColor:[UIColor clearColor]];
    [glyph_back setFont:[UIFont fontWithName:@"FontAwesome" size:28]];
    [glyph_back setTextAlignment:NSTextAlignmentCenter];
    [glyph_back setFrame:CGRectMake(0, 14, 44, 44)];
    [glyph_back setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-arrow-circle-o-left"]];
    [glyph_back setTextColor:kPayoBlue];
    [btnback addSubview:glyph_back];

    [self.view addSubview:btnback];

    UIImageView * logo = [[UIImageView alloc] initWithFrame:CGRectMake(125, 19, 70, 70)];
    [logo setImage:[UIImage imageNamed:@"payo-logo-140.png"]];
    [self.view addSubview:logo];

    self.pin_check = @"";
    [self.view setBackgroundColor:[UIColor whiteColor]];

    NSShadow * shadowNavText = [[NSShadow alloc] init];
    shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .26);
    shadowNavText.shadowOffset = CGSizeMake(0, -1.0);

    NSDictionary * titleAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                       NSShadowAttributeName: shadowNavText};
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];

    [self.navigationItem setTitle:NSLocalizedString(@"CreatePIN_ScrnTtl", @"'Create PIN' screen Title")];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 118, 300, 40)];
    [title setText:NSLocalizedString(@"CreatePIN_HdrTxt", @"'Create your PIN' Header Text")];
    [title setStyleClass:@"header_signupflow"];
    [self.view addSubview:title];

    self.prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 231, 300, 50)];
    [self.prompt setNumberOfLines:2];
    [self.prompt setText:NSLocalizedString(@"CreatePIN_Instruc2", @"Create PIN screen Initial Instruction Text (2nd)")];
    [self.prompt setStyleClass:@"instruction_text"];

    self.pin = [UITextField new];
    self.pin.inputAccessoryView = [[UIView alloc] init];
    [self.pin setKeyboardType:UIKeyboardTypeNumberPad];
    [self.pin setDelegate:self];
    [self.pin setTextColor:[UIColor clearColor]];
    [self.pin setFrame:CGRectMake(200, -100, 10, 10)];
    [self.view addSubview:self.pin];
    [self.pin becomeFirstResponder];

    self.first_num = [[UIView alloc] initWithFrame:CGRectMake(70,181,28,28)];
    self.second_num = [[UIView alloc] initWithFrame:CGRectMake(120,181,28,28)];
    self.third_num = [[UIView alloc] initWithFrame:CGRectMake(170,181,28,28)];
    self.fourth_num = [[UIView alloc] initWithFrame:CGRectMake(220,181,28,28)];

    self.first_num.layer.cornerRadius = self.second_num.layer.cornerRadius = self.third_num.layer.cornerRadius = self.fourth_num.layer.cornerRadius = 14;

    if ([[UIScreen mainScreen] bounds].size.height == 480)
    {
        [self.prompt setStyleClass:@"instruction_text_smscrn"];
        self.first_num = [[UIView alloc] initWithFrame:CGRectMake(73,173,26,26)];
        self.second_num = [[UIView alloc] initWithFrame:CGRectMake(121,173,26,26)];
        self.third_num = [[UIView alloc] initWithFrame:CGRectMake(169,173,26,26)];
        self.fourth_num = [[UIView alloc] initWithFrame:CGRectMake(217,173,26,26)];
        self.first_num.layer.cornerRadius = self.second_num.layer.cornerRadius = self.third_num.layer.cornerRadius = self.fourth_num.layer.cornerRadius = 13;
    }

    self.first_num.backgroundColor = self.second_num.backgroundColor = self.third_num.backgroundColor = self.fourth_num.backgroundColor = [UIColor clearColor];
    self.first_num.layer.borderWidth = self.second_num.layer.borderWidth = self.third_num.layer.borderWidth = self.fourth_num.layer.borderWidth = 3;
    self.first_num.layer.borderColor = self.second_num.layer.borderColor = self.third_num.layer.borderColor = self.fourth_num.layer.borderColor = kPayoGreen.CGColor;

    [self.view addSubview:self.prompt];
    [self.view addSubview:self.first_num];
    [self.view addSubview:self.second_num];
    [self.view addSubview:self.third_num];
    [self.view addSubview:self.fourth_num];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end