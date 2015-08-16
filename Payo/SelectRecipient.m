//  SelectRecipient.m
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.

#import "SelectRecipient.h"
#import "UIImageView+WebCache.h"
#import "Helpers.h"
#import "ECSlidingViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "MBProgressHUD.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface SelectRecipient ()

@property(nonatomic,strong) UITableView * contacts;
@property(nonatomic,strong) NSMutableArray * recents;
@property(nonatomic,strong) MBProgressHUD * hud;
@property(nonatomic,strong) UIImageView * noContact_img;
@property(nonatomic,strong) UIImageView * backgroundImage;
@end

@implementation SelectRecipient

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

    self.navigationController.navigationBar.topItem.title = @"";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.slidingViewController.panGesture setEnabled:YES];
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];

    [self.navigationItem setLeftBarButtonItem:nil];
    UIButton * back_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];
    [self.navigationItem setLeftBarButtonItem:menu];

    UIButton * Done = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    Done.frame = CGRectMake(278, 25, 45, 35);
    [Done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [Done setTitle:@"+ Add" forState:UIControlStateNormal];
    [Done setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.16) forState:UIControlStateNormal];
    Done.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [Done addTarget:self action:@selector(addNewRecipient) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithCustomView:Done];
    [self.navigationItem setRightBarButtonItem:backItem];

    search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 6, 320, 40)];
    search.searchBarStyle = UISearchBarStyleMinimal;
    search.placeholder = NSLocalizedString(@"SelectRecip_SearchPlaceholder", @"Select Recipient Search Bar Placeholder");
    [search setDelegate:self];
    [search setImage:[UIImage imageNamed:@"search_blue"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [search setImage:[UIImage imageNamed:@"clear_white"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];

    for (UIView *subView1 in search.subviews)
    {
        for (id subview2 in subView1.subviews)
        {
            if ([subview2 isKindOfClass:[UITextField class]])
            {
                ((UITextField *)subview2).textColor = [UIColor whiteColor];
                ((UITextField *)subview2).font = [UIFont fontWithName:@"Roboto-medium" size:16];
                [((UITextField *)subview2) setClearButtonMode:UITextFieldViewModeWhileEditing];
                 break;
            }
        }
    }

    [self.view addSubview:search];

    self.contacts = [[UITableView alloc] initWithFrame:CGRectMake(0, 52, 320, [[UIScreen mainScreen] bounds].size.height - 147)];
    [self.contacts setDataSource:self];
    [self.contacts setDelegate:self];
    [self.contacts setSectionHeaderHeight:28];
    [self.contacts setStyleId:@"select_recipientwithoutSeperator"];
    [self.contacts setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.contacts];
    [self.contacts reloadData];

    RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];

    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;

    self.noContact_img = [[UIImageView alloc] init];
    self.noContact_img.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [search setHidden:NO];
    self.screenName = @"SelectRecipient Screen";
    self.artisanNameTag = @"Select Recipient Screen";

    [self.navigationItem setTitle:NSLocalizedString(@"SelectRecipientScrnTitle", @"Select Recipient Screen Title")];
    [self.navigationItem setHidesBackButton:YES];

    NSShadow * shadowNavText = [[NSShadow alloc] init];
    shadowNavText.shadowColor = Rgb2UIColor(19, 32, 38, .2);
    shadowNavText.shadowOffset = CGSizeMake(0, -1.0);
    NSDictionary * titleAttributes = @{NSShadowAttributeName: shadowNavText};

    if (!isFromBankWebView)
    {
        UILabel * back_button = [UILabel new];
        [back_button setUserInteractionEnabled:YES];
        UITapGestureRecognizer * backTap;
        [back_button setStyleId:@"navbar_back"];
        back_button.attributedText = [[NSAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-left"] attributes:titleAttributes];
        backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backPressed_SelectRecip)];
        [back_button addGestureRecognizer: backTap];

        UIBarButtonItem * menu = [[UIBarButtonItem alloc] initWithCustomView:back_button];
        [self.navigationItem setLeftBarButtonItem:menu];
    }
    else
    {
        UIButton * Done = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        Done.frame = CGRectMake(307, 25, 16, 35);
        [Done setStyleId:@"icon_RequestMultiple"];
        [Done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [Done setTitle:@"Home" forState:UIControlStateNormal];
        [Done setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.16) forState:UIControlStateNormal];
        Done.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        [Done addTarget:self action:@selector(backPressed_FrmBnkWbView) forControlEvents:UIControlEventTouchUpInside];

        UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithCustomView:Done];
        [self.navigationItem setLeftBarButtonItem:backItem];
    }


    [ARTrackingManager trackEvent:@"SelectRecip_viewWillAppear1"];

    if ([self.recents count] == 0)
    {
        [self.view addSubview: self.noContact_img];
    }

    [search setTintColor:kPayoBlue];

    isRecentList = YES;
    searching = NO;

    search.text = @"";
    [search resignFirstResponder];
    search.searchBarStyle = UISearchBarStyleMinimal;
    [search setShowsCancelButton:NO animated:YES];
    [self.contacts setStyleId:@"select_recipient"];

    if (navIsUp == YES)
    {
        navIsUp = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self lowerNavBar];
        });
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.12];
    [self.contacts setAlpha:0];
    [UIView commitAnimations];

    //NSLog(@"noRecentContacts is: %d",noRecentContacts);

    if (noRecentContacts == true)
    {
        [self displayFirstTimeUserImg];
    }
    else
    {
        RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
        spinner1.color = [UIColor whiteColor];
        self.hud.customView = spinner1;
        self.hud.labelText = NSLocalizedString(@"SelectRecip_RecentLoading", @"Select Recipient Recent List Loading Text");
        self.hud.detailsLabelText = nil;
        [self.hud show:YES];

        serve * recents = [serve new];
        [recents setTagName:@"recents"];
        [recents setDelegate:self];
        [recents getRecents];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.12];
    [self.contacts setAlpha:0];
    [UIView commitAnimations];

    [self.hud hide:YES];
    [super viewDidDisappear:animated];
}

#pragma mark - Navigation Methods
-(void)backPressed_SelectRecip
{
    [[assist shared] setneedsReload:NO]; //Going right back to Home, so don't really need to reload

    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)backPressed_FrmBnkWbView
{
    [[assist shared] setneedsReload:NO]; //Going right back to Home, so don't really need to reload

    [self.navigationItem setLeftBarButtonItem:nil];

    Home * goHome = [Home new];
    [self.navigationController pushViewController:goHome animated:YES];
}

-(void)addNewRecipient
{
    AddRecipient * addRecipient = [[AddRecipient alloc] init];

    UINavigationController * navigationController = [[UINavigationController alloc]
                           initWithRootViewController:addRecipient];

    [self presentViewController:navigationController animated:YES completion: nil];
    //[self.navigationController pushViewController:addRecipient animated:YES];
}

-(void)lowerNavBar
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIView animateKeyframesWithDuration:0.2
                                   delay:0
                                 options:0 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      [self.view setBackgroundColor:[UIColor whiteColor]];
                                      [self.contacts setFrame:CGRectMake(0, 52, 320, [[UIScreen mainScreen] bounds].size.height - 117)];

                                      search.placeholder = @"Search by Name or Enter an Email";
                                      [search setFrame:CGRectMake(0, 6, 320, 40)];
                                      [search setImage:[UIImage imageNamed:@"search_blue"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
                                  }];
                              } completion: nil
    ];
}

#pragma mark - Action Sheet Handlers
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *_currentView in actionSheet.subviews)
    {
        if ([_currentView isKindOfClass:[UILabel class]])
        {
            [((UILabel *)_currentView) setFont:[UIFont boldSystemFontOfSize:15.f]];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

}


#pragma mark - Searching
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self lowerNavBar];

    if ([self.recents count] == 0)
    {
        [self.contacts setHidden:YES];
        [self.view addSubview: self.noContact_img];
    }

    searching = NO;
    isRecentList = YES;

    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [searchBar resignFirstResponder];
    [searchBar setText:@""];
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.contacts setStyleId:@"select_recipient"];
    [self.contacts reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];

    [self.contacts reloadData];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    navIsUp = YES;

    [search setTintColor:[UIColor whiteColor]]; // For the 'Cancel' text

    [UIView animateKeyframesWithDuration:0.22
                                   delay:0
                                 options:0 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.8 animations:^{
                                      [self.contacts setFrame:CGRectMake(0, 70, 320, [[UIScreen mainScreen] bounds].size.height - 56)];
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.9 animations:^{
                                      if ([self.view.subviews containsObject:self.noContact_img])
                                      {
                                          [self.noContact_img setAlpha:0];
                                      }
                                      [self.view setBackgroundColor:kPayoBlue];
                                      [self.contacts setAlpha:1];

                                      [search setImage:[UIImage imageNamed:@"search_white"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                      [searchBar setFrame:CGRectMake(0, 24, 320, 40)];
                                      searchBar.placeholder = @"";
                                  }];
                              } completion: ^(BOOL finished){
                                  if ([self.view.subviews containsObject:self.noContact_img])
                                  {
                                      [self.noContact_img removeFromSuperview];
                                  }
                              }
     ];

    [searchBar becomeFirstResponder];
    [searchBar setShowsCancelButton:YES animated:YES];
    [searchBar setKeyboardType:UIKeyboardTypeEmailAddress];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchBar.text length] == 0)
    {
        searching = NO;
        isRecentList = YES;

        return;
    }

    else if ([searchText length] > 0)
    {
        if ([self.view.subviews containsObject:self.noContact_img])
        {
            [UIView animateKeyframesWithDuration:.3
                                           delay:0
                                         options:1 << 16
                                      animations:^{
                                          [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                              [self.noContact_img setAlpha:0];
                                          }];
                                      } completion: ^(BOOL finished){
                                          [self.noContact_img removeFromSuperview];
                                      }
             ];
        }
        [self.contacts setHidden:NO];

        searching = YES;

        shouldAnimate = NO;
        searchString = searchText;
        [self searchTableView];

        [self.contacts reloadData];
    }

    else
    {
        searchString = [searchBar.text substringToIndex:[searchBar.text length] - 1];
        [self.contacts reloadData];
    }
}

-(void)searchTableView
{
    arrSearchedRecords = [[NSMutableArray alloc]init];

    for (NSString * key in [[assist shared] assos].allKeys)
    {
        NSMutableDictionary * dict = [[assist shared] assos][key];

        NSComparisonResult result;
        NSComparisonResult result2;
        NSComparisonResult result3;

        if ([dict valueForKey:@"FirstName"])
        {
            result = [[dict valueForKey:@"FirstName"] compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        }
        else {
            result = true;
        }

        if ([dict valueForKey:@"LastName"])
        {
            result2 = [[dict valueForKey:@"LastName"] compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        }
        else {
            result2 = true;
        }

        if ([dict valueForKey:@"LastName"] &&
            [dict valueForKey:@"FirstName"])
        {
            NSString * fullName = [NSString stringWithFormat:@"%@ %@", [dict valueForKey:@"FirstName"], [dict valueForKey:@"LastName"]];
            result3 = [fullName compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        }
        else {
            result3 = true;
        }

        if ((result == NSOrderedSame || result2 == NSOrderedSame || result3 == NSOrderedSame) &&
            (dict[@"FirstName"] || dict[@"LastName"]))
        {
            [arrSearchedRecords addObject:dict];
        }
    }

    if (![arrSearchedRecords isKindOfClass:[NSNull class]])
    {
        NSSortDescriptor * sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"FirstName" ascending:YES];
        NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray * temp = [arrSearchedRecords copy];
        [arrSearchedRecords setArray:[temp sortedArrayUsingDescriptors:sortDescriptors]];
    }
}

#pragma mark - file paths
- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
}

-(void)loadDelay
{
    NSMutableArray * arrNav = [nav_ctrl.viewControllers mutableCopy];
    [arrNav removeLastObject];
    [nav_ctrl setViewControllers:arrNav animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)Error:(NSError *)Error
{
    [self.hud hide:YES];
}

#pragma mark - server Delegation
- (void) listen:(NSString *)result tagName:(NSString *)tagName
{
    [self.contacts setNeedsDisplay];
    
    if ([result rangeOfString:@"Invalid OAuth 2 Access"].location != NSNotFound)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self autoLogin] error:nil];
        [user removeObjectForKey:@"UserName"];
        [user removeObjectForKey:@"MemberId"];

        [timer invalidate];

        [nav_ctrl performSelector:@selector(disable)];
        [nav_ctrl performSelector:@selector(reset)];

        [[assist shared]setPOP:YES];
        [self performSelector:@selector(loadDelay) withObject:Nil afterDelay:1.0];
    }

    else if ([tagName isEqualToString:@"getMemberIds"])
    {
        NSError *error;
        NSMutableDictionary * getMemberIdsResult = [NSJSONSerialization
                               JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                               options:kNilOptions
                               error:&error];
        NSMutableArray * phoneEmailListFromServer = [[getMemberIdsResult objectForKey:@"GetMemberIdsResult"] objectForKey:@"phoneEmailList"];
        NSMutableArray * additions = [NSMutableArray new];

        for (NSDictionary * dict in phoneEmailListFromServer)
        {
            NSMutableDictionary * new = [NSMutableDictionary new];

            for (NSString * key in dict.allKeys)
            {
                if ([key isEqualToString:@"memberId"] && [dict[key] length] > 0)
                {
                    [new setObject:dict[key] forKey:@"MemberId"];
                }
                else if ([key isEqualToString:@"emailAddy"])
                {
                    [new setObject:dict[key] forKey:@"UserName"];
                }
                else
                {
                    [new setObject:dict[key] forKey:key];
                }
            }
            if (new[@"MemberId"])
            {
                [additions addObject:new];
            }
        }
        [[assist shared] addAssos:additions];
    }

    else if ([tagName isEqualToString:@"recents"])
    {
        if ([self.view.subviews containsObject:self.hud])
        {
            [self.hud hide:YES];
        }

        NSError * error;
        self.recents = [NSJSONSerialization
                        JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                        options:kNilOptions
                        error:&error];
        
        NSMutableArray * temp = [NSMutableArray new];
 
        for (NSDictionary * dict in self.recents)
        {
            NSMutableDictionary * prep = dict.mutableCopy;
            [prep setObject:@"YES" forKey:@"recent"];
            [temp addObject:prep];
        }

        self.recents = temp.mutableCopy;
        [[assist shared] addAssos:[self.recents mutableCopy]];

        [self.hud hide:YES];
        if ([self.recents count] > 0)
        {
            if ([self.view.subviews containsObject:self.noContact_img])
            {
                [UIView animateKeyframesWithDuration:.3
                                               delay:0
                                             options:1 << 16
                                          animations:^{
                                              [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                                  [self.noContact_img setAlpha:0];
                                              }];
                                          } completion: ^(BOOL finished){
                                              [self.noContact_img removeFromSuperview];
                                          }
                 ];
            }

            if ([self.contacts isHidden]) {
                [self.contacts setHidden:NO];
            }

            [self.contacts setStyleId:@"select_recipient"];
            [self.contacts reloadData];

            [UIView animateKeyframesWithDuration:0.4
                                           delay:0
                                         options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                      animations:^{
                                          [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.6 animations:^{
                                              [self.backgroundImage setAlpha: 0];
                                              [search setHidden:NO];
                                          }];
                                          [UIView addKeyframeWithRelativeStartTime:.2 relativeDuration:.8 animations:^{
                                              CGRect frame = self.contacts.frame;
                                              frame.origin.y = 52;
                                              frame.size.height = [[UIScreen mainScreen] bounds].size.height - 117;
                                              [self.contacts setFrame:frame];
                                          }];
                                          [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                                              [self.contacts setAlpha: 1];
                                          }];
                                      } completion: ^(BOOL finished){
                                          nil;
                                      }
             ];
        }
        else
        {
            [self displayFirstTimeUserImg];
        }
    }

    else if ([tagName isEqualToString:@"getMemberDetails"])
    {
        NSError * error;

        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setDictionary:[NSJSONSerialization
                             JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                             options:kNilOptions
                             error:&error]];

        if (navIsUp == YES) {
            navIsUp = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self lowerNavBar];
            });
        }
        [self.navigationItem setLeftBarButtonItem:nil];

            NSString * PhotoUrl = [dict valueForKey:@"PhotoUrl"];
            [dict setObject:PhotoUrl forKey:@"Photo"];

        [self.hud hide:YES];

        isFromHome = NO;
        isFromArtisanDonationAlert = NO;

        HowMuch *how_much = [[HowMuch alloc] initWithReceiver:dict];
        [self.navigationController pushViewController:how_much animated:YES];
    }
}

-(void)displayFirstTimeUserImg
{
    if (IS_IPHONE_5)
    {
        self.noContact_img.frame = CGRectMake(0, 82, 320, 405);
        self.noContact_img.image = [UIImage imageNamed:@"SelectRecipIntro"];
    }
    else
    {
        self.noContact_img.frame = CGRectMake(3, 79, 314, 340);
        self.noContact_img.image = [UIImage imageNamed:@"selectRecipIntro_4"];
    }
    [self.noContact_img setAlpha:0];
    [self.view addSubview:self.noContact_img];
    
    [UIView animateKeyframesWithDuration:.4
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.6 animations:^{
                                      [self.backgroundImage setAlpha: 0];
                                      [search setHidden:NO];
                                      [self.contacts setAlpha: 0];
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:.2 relativeDuration:.8 animations:^{
                                      CGRect frame = self.contacts.frame;
                                      frame.origin.y = 52;
                                      frame.size.height = [[UIScreen mainScreen] bounds].size.height - 117;
                                      [self.contacts setFrame:frame];
                                      
                                      [self.noContact_img setAlpha:1];
                                  }];
                              } completion: ^(BOOL finished){
                                  //[self.contacts setHidden:YES];
                              }
     ];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 28)];
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake (10, 0, 200, 28)];
    [title setTextColor: kNoochGrayDark];
    [title setFont:[UIFont fontWithName:@"Roboto-regular" size:15]];

    if (section == 0)
    {
        if (searching) {
            title.text = NSLocalizedString(@"SelectRecip_SearchResults", @"Select Recipient Search Results");
        }
        else if (isRecentList) {
            title.text = NSLocalizedString(@"SelectRecip_RecentContacts", @"Select Recipient Recent Contacts");
        }
    }
    else
    {
        title.text = @"";
    }
    [headerView addSubview:title];
    [headerView setBackgroundColor:[Helpers hexColor:@"e3e4e5"]];
    [title setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (searching)
    {
        return [arrSearchedRecords count];
    }
    else
    {
        return [self.recents count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        [cell.textLabel setStyleClass:@"select_recipient_name"];
        cell.indentationLevel = 1;
    }

    for (UIView *subview in cell.contentView.subviews)
    {
        [subview removeFromSuperview];
    }

    [cell.detailTextLabel setText:@""];

    UIImageView * pic = [[UIImageView alloc] initWithFrame:CGRectMake(16, 6, 50, 50)];
    pic.clipsToBounds = YES;

    [cell.contentView addSubview:pic];

    if (searching)
    {
        NSDictionary *info = [arrSearchedRecords objectAtIndex:indexPath.row];

        [pic sd_setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        [cell setIndentationLevel:1];
        cell.indentationWidth = 61;

        pic.hidden = NO;
        [pic setFrame:CGRectMake(16, 6, 50, 50)];
        pic.layer.cornerRadius = 25;

        if (info[@"FirstName"] != NULL && info[@"LastName"] != NULL) // If address book record has a First & Last Name
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",info[@"FirstName"],info[@"LastName"]];
        }
        else if (info[@"FirstName"] != NULL && info[@"LastName"] == NULL) // If address book record has only a First Name
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",info[@"FirstName"]];
        }
        else if (info[@"FirstName"] == NULL && info[@"LastName"] != NULL) // If address book record has only a Last Name
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",info[@"LastName"]];
        }
        
        [cell.textLabel setStyleClass:@"select_recipient_name"];

        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    else if (isRecentList)
    {
        NSDictionary * info = [self.recents objectAtIndex:indexPath.row];
        [pic sd_setImageWithURL:[NSURL URLWithString:info[@"Photo"]]
            placeholderImage:[UIImage imageNamed:@"profile_picture.png"]];
        [pic setFrame:CGRectMake(16, 6, 50, 50)];
        pic.hidden = NO;
        pic.layer.cornerRadius = 25;

        [cell setIndentationLevel:1];
        cell.indentationWidth = 42;
        [cell.textLabel setStyleClass:@"select_recipient_name"];
        cell.textLabel.text = [NSString stringWithFormat:@"    %@ %@",info[@"FirstName"],info[@"LastName"]];

        cell.accessoryType = UITableViewCellAccessoryNone;

        if ([[[assist shared] assos] objectForKey:info[@"UserName"]])
        {
            if ([[assist shared] assos][info[@"UserName"]][@"addressbook"])
            {
                UIImageView *ab = [UIImageView new];
                [ab setStyleClass:@"addressbook-icons"];
                [ab setStyleClass:@"animate_bubble"];
                [cell.contentView addSubview:ab];
            }
        }

        [pic setStyleClass:@"animate_bubble"];
    }

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary * receiver = nil;

    if (searching)
    {
        receiver =  [arrSearchedRecords objectAtIndex:indexPath.row];

        //NSLog(@"Receiver is: %@",receiver);

        searching = NO;
        isRecentList = YES;
        [search resignFirstResponder];
        [search setText:@""];
        [search setShowsCancelButton:NO];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        if (navIsUp == YES)
        {
            navIsUp = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self lowerNavBar];
            });
        }

        isFromHome = NO;
        isFromArtisanDonationAlert = NO;
    }
    else
    {
        if (navIsUp == YES)
        {
            navIsUp = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self lowerNavBar];
            });
        }
        [self.navigationItem setLeftBarButtonItem:nil];
        isFromHome = NO;
        isFromArtisanDonationAlert = NO;

        receiver = [self.recents objectAtIndex:indexPath.row];
    }

    HowMuch * how_much = [[HowMuch alloc] initWithReceiver:receiver];
    [self.navigationController pushViewController:how_much animated:YES];
}

-(bool)checkEmailForShadyDomainSelectRecip
{
    NSString * emailToCheck = search.text;
    
    if ([emailToCheck rangeOfString:@"sharklasers"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"grr.la"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"guerrillamail"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"spam4"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"anonymousemail"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"anonemail"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"hmamail.com"].location != NSNotFound || // "hideMyAss.com"
        [emailToCheck rangeOfString:@"mailinator"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"mailinater"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"sendspamhere"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"sogetthis"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"mt2014.com"].location != NSNotFound ||  // "myTrashMail.com"
        [emailToCheck rangeOfString:@"hushmail"].location != NSNotFound ||
        [emailToCheck rangeOfString:@"mailnesia"].location != NSNotFound)
    {
        [search becomeFirstResponder];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Try A Different Email"
                                                         message:@"\xF0\x9F\x93\xA7\nTo protect all Nooch accounts, we ask that you please only make payments to a regular (not anonymous) email address."
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [av show];

        return false;
    }
    else
    {
        return true;
    }
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