//
//  addBank.h
// Payo
//
//  Created by Cliff Canan on 3/13/14.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SpinKit/RTSpinKitView.h"
#import <MessageUI/MessageUI.h>

@interface addBank : GAITrackedViewController<MBProgressHUDDelegate,MFMailComposeViewControllerDelegate>
{
    UIView * overlay, * mainView;
}
@end
