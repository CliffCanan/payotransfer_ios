//
//  Register.h
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "MBProgressHUD.h"
#import "SpinKit/RTSpinKitView.h"
#import <MessageUI/MessageUI.h>

@interface Register : GAITrackedViewController<UITextFieldDelegate,serveD,MBProgressHUDDelegate,MFMailComposeViewControllerDelegate>
{
    BOOL isTermsChecked;
    BOOL isloginWithFB;
    BOOL pwLength;
    int criteriaHit;
}
-(void)removeChild:(UIViewController *) child;
@end
