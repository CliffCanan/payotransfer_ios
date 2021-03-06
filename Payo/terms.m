//
//  terms.m
// Payo
//
//  Created by administrator on 6/05/14.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import "terms.h"
#import "NSData+AESCrypt.h"
#import "NSString+AESCrypt.h"
#import "Home.h"
#import "Register.h"

@interface terms ()

@property(nonatomic,strong) MBProgressHUD * hud;
@end

@implementation terms

@synthesize termsView;

# pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil value:(NSString *)sendValue
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
    self.title = NSLocalizedString(@"Terms_ScrnTitle", @"Terms 'User Agreement' Screen Title");
}

- (void)dealloc {
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Terms Screen";
    self.artisanNameTag = @"Terms Webview Screen";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    float top = 0.0f;

    RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
    spinner1.color = [UIColor whiteColor];
    MBProgressHUD * hud1 = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    self.hud = hud1;
    [self.navigationController.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Terms_HUDlbl", @"Terms 'Loading Nooch's Terms of Service' HUD Label");
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    [self.hud show:YES];

    [hud1 release];
    [spinner1 release];

    if (isfromRegister)
    {
        UIView * nav_view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 64)];
        nav_view.backgroundColor = kPayoBlue;
        [self.view addSubview:nav_view];
        top = 62.0f;

        UILabel * terms = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 320, 40)];
        terms.textColor = [UIColor whiteColor];
        terms.text = NSLocalizedString(@"Terms_ScrnTitle2", @"Terms 'User Agreement' Screen Title (2nd)");
        terms.textAlignment = NSTextAlignmentCenter;
        [nav_view addSubview:terms];
        [terms release];

        UIButton * btn_Close = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_Close.frame = CGRectMake(0, 20, 80, 40);
        [btn_Close setTitle:NSLocalizedString(@"Terms_CloseBtn", @"Terms 'Close' Button Text") forState:UIControlStateNormal];
        [btn_Close setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.175) forState:UIControlStateNormal];
        btn_Close.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [btn_Close addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
        [nav_view addSubview:btn_Close];
        [nav_view release];
    }
    else
    {
        UIButton * hamburger = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [hamburger setStyleId:@"navbar_hamburger"];
        [hamburger addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        [hamburger setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
        [hamburger setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.2) forState:UIControlStateNormal];
        hamburger.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:hamburger];
        [self.navigationItem setLeftBarButtonItem:menu];
        [menu release];
    }

    NSURL * webURL = [NSURL URLWithString:@"https://www.nooch.com/tos"];
    termsView = [[UIWebView alloc]initWithFrame:CGRectMake(0, top, 320, [[UIScreen mainScreen] bounds].size.height - 62)];
    termsView.delegate = self;

    [termsView loadRequest:[NSURLRequest requestWithURL:webURL]];
    termsView.scalesPageToFit = YES;

    termsView.scrollView.hidden = NO;
    [termsView setMultipleTouchEnabled:YES];
    [self.view addSubview:termsView];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)dismissView:(id)sender
{
    [termsView setDelegate:nil];
    [(Register *)self.parentViewController removeChild:self];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.hud hide:YES];
    return ;
}

-(void)webViewDidFinishLoad:(UIWebView *) portal
{
    [self.hud hide:YES];
}

-(void)showMenu
{
    [[assist shared]setneedsReload:NO];
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];

    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Message"
                          message:@"Error connecting to server"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

-(void)listen:(NSString *)result tagName:(NSString*)tagName
{
    NSError *error;
    NSDictionary *template = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    [termsView loadHTMLString:[template objectForKey:@"Result"] baseURL:nil];

    [self.hud hide:YES];

    for (id subView in [termsView subviews])
    {
        if ([subView respondsToSelector:@selector(flashScrollIndicators)])
        {
            [subView flashScrollIndicators];
        }
    }
}

@end
