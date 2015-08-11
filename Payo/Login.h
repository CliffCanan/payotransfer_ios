//
//  Login.h
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "MBProgressHUD.h"
#import <MessageUI/MessageUI.h>

NSString * fullNameFromFb, *email_fb, *fbID;
BOOL fromLoginWithFbFail;

@interface Login : GAITrackedViewController<UIAlertViewDelegate,UITextFieldDelegate,serveD,CLLocationManagerDelegate,MFMailComposeViewControllerDelegate,MBProgressHUDDelegate>
{
    float lat;
    float lon;
    BOOL isloginWithFB;
    CLLocationManager *locationManager;
}
@property (strong, nonatomic) IBOutlet UIView *inputAccessory;
@end
