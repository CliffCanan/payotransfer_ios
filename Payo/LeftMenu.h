//
//  LeftMenu.h
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "ECSlidingViewController.h"
#import <MessageUI/MessageUI.h>
#import "EAIntroView.h"

@interface LeftMenu : GAITrackedViewController<UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,EAIntroDelegate,MFMailComposeViewControllerDelegate>
{
    UIView * user_bar;
    UIImageView *user_pic;
    UIButton * arrow;
    NSString * settingsIconPosition;
}
@end
