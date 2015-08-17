//
//  SendInvite.h
//  Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "serve.h"
#import "MBProgressHUD.h"

@interface SendInvite : GAITrackedViewController<UITableViewDataSource,UITableViewDelegate,serveD,MFMailComposeViewControllerDelegate,UITextFieldDelegate,MBProgressHUDDelegate>
{
    NSMutableDictionary * dictResponse;
    NSMutableDictionary * dictInviteUserList;
    UILabel * code;
    NSRange start;
    NSRange end;
    NSString * betweenBraces;
    NSString * newString;
}

@end