//
//  terms.h
// Payo
//
//  Created by administrator on 12/05/13.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "MBProgressHUD.h"

BOOL isfromRegister;

@interface terms : GAITrackedViewController <serveD,UIWebViewDelegate,MBProgressHUDDelegate>

@property(nonatomic, retain) IBOutlet UIWebView *termsView;

@end
