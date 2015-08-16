//
//  AddRecipient.m
//  Payo
//
//  Created by Clifford Canan on 8/14/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import "AddRecipient.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Resize.h"
#import "Helpers.h"
#import "ECSlidingViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "MBProgressHUD.h"

@interface AddRecipient ()

@property(nonatomic,strong) UITableView * contacts;
@property(nonatomic,strong) NSMutableArray * recents;
@property(nonatomic,strong) UIImageView * backgroundImage;
@property(nonatomic,strong) MBProgressHUD * hud;
@end

@implementation AddRecipient

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

    self.automaticallyAdjustsScrollViewInsets = NO;

    NSLog(@"Add Recipient -> viewDidLoad Fired");
    [self.navigationItem setTitle:NSLocalizedString(@"AddRecipientScrnTitle", @"Add Recipient Screen Title")];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    UIButton * save = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    save.frame = CGRectMake(280, 25, 40, 35);
    [save setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [save setTitle:@"Save" forState:UIControlStateNormal];
    [save setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.18) forState:UIControlStateNormal];
    save.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [save addTarget:self action:@selector(savePressed) forControlEvents:UIControlEventTouchUpInside];

    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:save]];

    UIButton * cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancel.frame = CGRectMake(4, 25, 50, 35);
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel setTitleShadowColor:Rgb2UIColor(19, 32, 38, 0.18) forState:UIControlStateNormal];
    cancel.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    [cancel addTarget:self action:@selector(cancelAddRecip) forControlEvents:UIControlEventTouchUpInside];

    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:cancel]];



    newRecipPic = [UIImageView new];
    [newRecipPic setFrame:CGRectMake(120, 68, 80, 80)];
    newRecipPic.layer.cornerRadius = 40;
    newRecipPic.layer.borderColor = [UIColor whiteColor].CGColor;
    newRecipPic.layer.borderWidth = 2;
    newRecipPic.clipsToBounds = YES;
    [newRecipPic addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(change_pic)]];
    [newRecipPic setUserInteractionEnabled:YES];
    [newRecipPic setImage:[UIImage imageNamed:@"RoundLoading"]];
    [newRecipPic setStyleClass:@"animate_bubble"];

    NSShadow * shadow_edit = [[NSShadow alloc] init];
    shadow_edit.shadowColor = Rgb2UIColor(33, 34, 35, .4);
    shadow_edit.shadowOffset = CGSizeMake(0, 1);
    NSDictionary * textAttributes = @{NSShadowAttributeName: shadow_edit };

    UILabel * edit_label = [UILabel new];
    [edit_label setBackgroundColor:[UIColor clearColor]];
    edit_label.attributedText = [[NSAttributedString alloc] initWithString:@"Add" attributes:textAttributes];
    [edit_label setFont:[UIFont fontWithName:@"Roboto-medium" size:12]];
    [edit_label setFrame:CGRectMake(0, newRecipPic.frame.size.height - 18, newRecipPic.frame.size.width, 12)];
    [edit_label setTextAlignment:NSTextAlignmentCenter];
    [edit_label setTextColor:[UIColor whiteColor]];

    [newRecipPic addSubview:edit_label];

    self.contacts = [[UITableView alloc] initWithFrame:CGRectMake(0, 150, 320, 280)];
    [self.contacts setDataSource:self];
    [self.contacts setDelegate:self];
    [self.contacts setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [self.view addSubview:self.contacts];



    self.firstName = [[UITextField alloc] initWithFrame:CGRectMake(113, 2, 200, 40)];
    [self.firstName setPlaceholder:@"Enter First Name"];
    [self.firstName setTextColor: kNoochGrayDark];
    [self.firstName setFont:[UIFont fontWithName:@"Roboto-regular" size:16]];
    [self.firstName setAutocapitalizationType: UITextAutocapitalizationTypeWords];
    [self.firstName setDelegate:self];
    [self.firstName setKeyboardType:UIKeyboardTypeAlphabet];
    [self.firstName setReturnKeyType:UIReturnKeyNext];
    [self.firstName setUserInteractionEnabled:YES];

    self.lastName = [[UITextField alloc] initWithFrame:CGRectMake(113, 2, 200, 40)];
    [self.lastName setPlaceholder:@"Enter Last Name"];
    [self.lastName setTextColor: kNoochGrayDark];
    [self.lastName setFont:[UIFont fontWithName:@"Roboto-regular" size:16]];
    [self.lastName setAutocapitalizationType: UITextAutocapitalizationTypeWords];
    [self.lastName setDelegate:self];
    [self.lastName setKeyboardType:UIKeyboardTypeAlphabet];
    [self.lastName setReturnKeyType:UIReturnKeyNext];
    [self.lastName setUserInteractionEnabled:YES];

    self.email = [[UITextField alloc] initWithFrame:CGRectMake(113, 2, 200, 40)];
    [self.email setPlaceholder:@"Enter Email Address"];
    [self.email setTextColor: kNoochGrayDark];
    [self.email setFont:[UIFont fontWithName:@"Roboto-regular" size:16]];
    [self.email setDelegate:self];
    [self.email setKeyboardType:UIKeyboardTypeEmailAddress];
    [self.email setReturnKeyType:UIReturnKeyNext];
    [self.email setUserInteractionEnabled:YES];

    self.phone = [[UITextField alloc] initWithFrame:CGRectMake(113, 2, 200, 40)];
    [self.phone setPlaceholder:@"Enter Phone Number"];
    [self.phone setTextColor: kNoochGrayDark];
    [self.phone setFont:[UIFont fontWithName:@"Roboto-regular" size:16]];
    [self.phone setDelegate:self];
    [self.phone setKeyboardType:UIKeyboardTypeNumberPad];
    [self.phone setReturnKeyType:UIReturnKeyNext];
    [self.phone setUserInteractionEnabled:YES];

    self.cityInNepal = [[UITextField alloc] initWithFrame:CGRectMake(113, 2, 200, 40)];
    [self.cityInNepal setPlaceholder:@"Enter City (In Nepal)"];
    [self.cityInNepal setTextColor: kNoochGrayDark];
    [self.cityInNepal setFont:[UIFont fontWithName:@"Roboto-regular" size:16]];
    [self.cityInNepal setAutocapitalizationType: UITextAutocapitalizationTypeWords];
    [self.cityInNepal setDelegate:self];
    [self.cityInNepal setKeyboardType:UIKeyboardTypeAlphabet];
    [self.cityInNepal setReturnKeyType:UIReturnKeyNext];
    [self.cityInNepal setUserInteractionEnabled:YES];

    [self.view addSubview:newRecipPic];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.screenName = @"AddRecipient Screen";
    self.artisanNameTag = @"Add Recipient Screen";

    [ARTrackingManager trackEvent:@"AddRecip_viewWillAppear"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)cancelAddRecip
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)savePressed
{
    if (self.firstName.text.length == 0 ||
        self.lastName.text.length == 0 ||
        self.email.text.length == 0 ||
        self.phone.text.length == 0 ||
        self.cityInNepal.text.length == 0)
    {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Incomplete Form"
                                                     message:@"Please complete all fields before saving this recipient."
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];

        if (self.firstName.text.length == 0)
        {
            [av setTag:10];
        }
        else if (self.lastName.text.length == 0)
        {
            [av setTag:15];
        }
        else if (self.email.text.length == 0)
        {
            [av setTag:20];
        }
        else if (self.phone.text.length == 0)
        {
            [av setTag:25];
        }
        else if (self.cityInNepal.text.length == 0)
        {
            [av setTag:30];
        }
        [av show];

        return;
    }

    // Validate the First & Last Name
    if (self.firstName.text.length < 2)
    {
        UIAlertView * alert =[[UIAlertView alloc]initWithTitle:@"Need a Full Name"
                                                       message:@"Nooch is currently only able to handle names greater than 3 letters.\n\nIf your first or last name has fewer than 3, please contact us and we'll be happy to manually add your recipient."
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil, nil];
        [alert show];
        [alert setTag:10];

        return;
    }
    if (self.lastName.text.length < 2)
    {
        UIAlertView * alert =[[UIAlertView alloc]initWithTitle:@"Need a Full Name"
                                                       message:@"Nooch is currently only able to handle names greater than 3 letters.\n\nIf your first or last name has fewer than 3, please contact us and we'll be happy to manually add your recipient."
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil, nil];
        [alert show];
        [alert setTag:15];

        return;
    }
    else
    {
        if ([self checkNameForNumsAndSpecChars:self.firstName.text] == false)
        {
            return;
        }
        if ([self checkNameForNumsAndSpecChars:self.lastName.text] == false)
        {
            return;
        }
    }


    // Now Validate the Email Address entered
    if ([[self.email.text lowercaseString] isEqualToString:[user objectForKey:@"UserName"]])
    {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SelectRecip_HoldOnThere", @"Select Recipient Hold On There Alert Title")
                                                     message:[NSString stringWithFormat:@"\xF0\x9F\x98\xB1\n%@", NSLocalizedString(@"SelectRecip_HoldOnThereBody", @"Select Recipient Hold On There Alert Body Text")]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        [av setTag:20];

        return;
    }

    if ([self.email.text length] > 3 &&
        [self.email.text rangeOfString:@"@"].location != NSNotFound &&
        [self.email.text rangeOfString:@"@"].location > 1 &&
        [self.email.text rangeOfString:@"."].location < self.email.text.length - 2 &&
        [self.email.text rangeOfString:@"."].location != NSNotFound)
    {
        if ([self checkEmailForShadyDomainAddRecip] == false)
        {
            return;
        }
    }
    else
    {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SelectRecip_PlsCheckEmailAlertTitle2", @"Select Recipient Please Check That Email Alert Title")
                                                      message:[NSString stringWithFormat:@"\xF0\x9F\x93\xA7\n%@", NSLocalizedString(@"SelectRecip_PlsCheckEmailAlertBody2", @"Select Recipient Please Check That Email Alert Body Text")]
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles: nil];
        [av show];
        [av setTag:20];

        return;
    }

    // Now Validate the City Entered
    if ([self.cityInNepal.text length] < 3 &&
        [self.cityInNepal.text rangeOfString:@"@"].location != NSNotFound)
    {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Please Check That City"
                                                      message:[NSString stringWithFormat:@"\xF0\x9F\x93\xA7\n%@", @"That doesn't look like a valid city.  Please check it and try again."]
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles: nil];
        [av show];
        [av setTag:30];

        return;
    }



    RTSpinKitView * spinner1 = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleArcAlt];
    spinner1.color = [UIColor whiteColor];
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Rgstr_HUDchkngEml", @"Register screen 'Checking if email already in use' HUD Label");
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.customView = spinner1;
    self.hud.delegate = self;
    [self.hud show:YES];

    serve * addRecip = [serve new];
    [addRecip setTagName:@"addRecip"];
    [addRecip setDelegate:self];
    //[addRecip addRecipient:self.firstName.text.capitalizedString lastName:self.lastName.text.capitalizedString email:self.email.text phone:self.phone.text city:self.cityInNepal.text];
}

#pragma mark - UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                      reuseIdentifier:CellIdentifier];
    }

    [cell.textLabel setFont:[UIFont fontWithName:@"Roboto-regular" size:15]];

    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"First Name";

        [cell.contentView addSubview:self.firstName];
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Last Name";

        [cell.contentView addSubview:self.lastName];
    }
    else if (indexPath.row == 2)
    {
        cell.textLabel.text = @"Email";

        [cell.contentView addSubview:self.email];
    }
    else if (indexPath.row == 3)
    {
        cell.textLabel.text = @"Phone #";

        [cell.contentView addSubview:self.phone];
    }
    else if (indexPath.row == 4)
    {
        cell.textLabel.text = @"City";

        [cell.contentView addSubview:self.cityInNepal];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Text Field Methods
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateKeyframesWithDuration:0.35
                                   delay:0
                                 options:0 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.5 animations:^{
                                      newRecipPic.alpha = 0;
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.7 animations:^{
                                      [self.contacts setFrame:CGRectMake(0, 68, 320, 280)];
                                  }];
                              }
                              completion:^(BOOL finished) {
                              }
     ];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.firstName.text = self.firstName.text.capitalizedString;
    self.lastName.text = self.lastName.text.capitalizedString;
    self.cityInNepal.text = self.cityInNepal.text.capitalizedString;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [UIView animateKeyframesWithDuration:0.5
                                   delay:0
                                 options:0 << 16
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.7 animations:^{
                                      [self.contacts setFrame:CGRectMake(0, 150, 320, 280)];
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:.4 relativeDuration:.6 animations:^{
                                      newRecipPic.alpha = 1;
                                  }];
                              }
                              completion:^(BOOL finished) {
                              }
     ];
}


#pragma mark - ImagePicker
-(UIImage* )imageWithImage:(UIImage*)image scaledToSize:(CGSize)size
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = 75.0/115.0;

    if (imgRatio != maxRatio)
    {
        if (imgRatio < maxRatio)
        {
            imgRatio = 115.0 / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = 115.0;
        }
        else
        {
            imgRatio = 75.0 / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = 75.0;
        }
    }

    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

-(void)imagePickerController:(UIImagePickerController *)picker1 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
    image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(120,120) interpolationQuality:kCGInterpolationMedium];
    [newRecipPic setImage:image];

    [[assist shared] setTranferImage:image];

    SDImageCache * imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];

    [self dismissViewControllerAnimated:YES completion:Nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker1
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark - Alert & Action View Handlers
-(void)change_pic
{
    UIActionSheet * actionSheetObject = [[UIActionSheet alloc] initWithTitle:@"Add A Profile Picture"
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"Profile_CancelTxt", @"Profile 'Cancel' Text")
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:NSLocalizedString(@"Profile_UseCamera", @"Profile 'Use Camera' Text"), NSLocalizedString(@"Profile_FrmLbry", @"Profile 'From iPhone Library' Text"), nil];
    actionSheetObject.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheetObject showInView:self.view];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10)
    {
        [self.firstName becomeFirstResponder];
    }
    else if (alertView.tag == 15)
    {
        [self.lastName becomeFirstResponder];
    }
    else if (alertView.tag == 20)
    {
        [self.email becomeFirstResponder];
    }
    else if (alertView.tag == 25)
    {
        [self.phone becomeFirstResponder];
    }
    else if (alertView.tag == 30)
    {
        [self.cityInNepal becomeFirstResponder];
    }
}

-(void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView * currentView in actionSheet.subviews)
    {
        if ([currentView isKindOfClass:[UILabel class]])
        {
            [((UILabel *)currentView) setFont:[UIFont boldSystemFontOfSize:15.f]];
        }
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            if (picker == nil)
            {
                picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
            }
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;

            //self.modalPresentationStyle = UIModalPresentationCurrentContext;
            [self presentViewController:picker animated:YES completion:Nil];
        }
        else
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_ErrorTxt", @"Profile 'Error' Text")
                                                          message:@"Can't find a camera for this device unfortunately.\n;-("
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
            [av show];
        }
    }
    else if (buttonIndex == 1)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
            if (picker == nil)
            {
                picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
            }

            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            picker.allowsEditing = YES;
            if ([[UIScreen mainScreen] bounds].size.height < 500) {
                [picker.view setStyleClass:@"pickerstyle_4"];
            }
            else {
                [picker.view setStyleClass:@"pickerstyle"];
            }

            //[self dismissViewControllerAnimated:NO completion:NULL];
            [self presentViewController:picker animated:YES completion: nil];
        }
        else
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Profile_ErrorTxt", @"Profile 'Error' Text")
                                                          message:@"We're having a little trouble accessing your device's photo library.\n;-("
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
            [av show];
        }
    }
}

#pragma mark - Other
-(BOOL)checkNameForNumsAndSpecChars:(NSString*)textString
{
    BOOL containsPunctuation = NSNotFound != [textString rangeOfCharacterFromSet:NSCharacterSet.punctuationCharacterSet].location;
    BOOL containsNumber = NSNotFound != [textString rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet].location;
    BOOL containsSymbols = NSNotFound != [textString rangeOfCharacterFromSet:NSCharacterSet.symbolCharacterSet].location;
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"'.-"];
    BOOL containsDash = NSNotFound != [textString rangeOfCharacterFromSet:characterSet].location;

    if (containsNumber)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"\xF0\x9F\x98\x8F  %@", NSLocalizedString(@"Rgstr_ReallyAlrtTtl1", @"Register screen Really Alert Title")]
                                                     message:NSLocalizedString(@"Rgstr_ReallyAlrtBody1", @"Register screen Really Alert Body Text")
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        [av setTag:10];

        return false;
    }
    else if ((containsSymbols || containsPunctuation) &&
             !containsDash)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"\xF0\x9F\x98\x8F  %@", NSLocalizedString(@"Rgstr_ReallyAlrtTtl2", @"Register screen Really Alert Title")]
                                                     message:NSLocalizedString(@"Rgstr_ReallyAlrtBody2", @"Register screen Really Alert Body (2nd - symbol)")
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        [av setTag:10];

        return false;
    }
    else
    {
        if ([textString length] < 2)
        {
            [self.firstName becomeFirstResponder];
        }
        return true;
    }
}

-(bool)checkEmailForShadyDomainAddRecip
{
    NSString * emailToCheck = self.email.text;

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
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Try A Different Email"
                                                     message:@"\xF0\x9F\x93\xA7\nTo protect all Nooch accounts, we ask that you please only make payments to a regular (not anonymous) email address."
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        [av setTag:20];
        
        return false;
    }
    else
    {
        return true;
    }
}

#pragma mark - server Delegation
-(void)Error:(NSError *)Error
{
}

-(void)listen:(NSString *)result tagName:(NSString *)tagName
{
    [self.hud hide:YES];

    if ([tagName isEqualToString:@"addRecip"])
    {
        NSError * error;
        NSMutableDictionary * dictResult = [NSJSONSerialization
                                            JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                            options:kNilOptions
                                            error:&error];

        if ([dictResult objectForKey:@"Result"] != [NSNull null])
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];

            [dict setObject:@"" forKey:@"email"];
            [dict setObject:@"" forKey:@"firstName"];
            [dict setObject:@"" forKey:@"lastName"];
            [dict setObject:@"" forKey:@"email"];
            [dict setObject:@"nonuser" forKey:@"nonuser"];
            [dict setObject:@"" forKey:@"Photo"];

            [self dismissViewControllerAnimated:YES completion:NULL];
        }
    }

}

#pragma mark - file paths
- (NSString *)autoLogin
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"autoLogin.plist"]];
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