//
//  LimitsAndFees.h
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#define Rgb2UIColor(r, g, b, a)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

@interface LimitsAndFees : GAITrackedViewController<serveD,UIWebViewDelegate>

@property(nonatomic, strong) IBOutlet UIWebView *LimitsAndFeesView;
@end
