//
//  privacy.h
// Payo
//
//  Created by administrator on 12/05/13.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "MBProgressHUD.h"

@interface privacy : GAITrackedViewController <serveD,UIWebViewDelegate>

@property(nonatomic, retain) IBOutlet UIWebView *privacyView;

@end
