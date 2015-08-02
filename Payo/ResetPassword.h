//
//  ResetPassword.h
//  Nooch
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//
NSString*userPass;
NSString*getEncryptionOldPassword;
NSString*newchangedPass;
BOOL isPasswordChanged;
#import <UIKit/UIKit.h>
#import "serve.h"
#import "MBProgressHUD.h"
#import "GetEncryptionValue.h"

@interface ResetPassword : GAITrackedViewController<UITextFieldDelegate,serveD,UITableViewDelegate,UITableViewDataSource,GetEncryptionValueDelegate,MBProgressHUDDelegate>
{
    NSString*passwordReset;
    NSString*getEncryptedPasswordValue;
    NSString*getEncryptionNewPassword;
    NSString*getEncryptionOldPassword;
    BOOL pwLength;
}
@end
