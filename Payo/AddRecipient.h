//
//  AddRecipient.h
//  Payo
//
//  Created by Cliff Canan on 8/14/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "serve.h"
#import "SelectRecipient.h"
#import "SpinKit/RTSpinKitView.h"

@interface AddRecipient : GAITrackedViewController<UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,serveD,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>
{
    UIImageView * newRecipPic;
    UIImagePickerController * picker;
}

@property(nonatomic,strong) UITextField * firstName;
@property(nonatomic,strong) UITextField * lastName;
@property(nonatomic,strong) UITextField * email;
@property(nonatomic,strong) UITextField * phone;
@property(nonatomic,strong) UITextField * cityInNepal;

@end