//
//  ReferralCode.h
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "MBProgressHUD.h"

@interface ReferralCode : GAITrackedViewController<serveD,UITextFieldDelegate,MBProgressHUDDelegate>
{
    NSString * getEncryptedPassword;
    NSString * refCodeFromArtisan;
    float lat,lon;
    UIActivityIndicatorView*spinner;
    UIButton *enter;
}
- (id)initWithData:(NSDictionary *)usr;
@end
