//
//  PINSettings.h
//  Nooch
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"

@interface PINSettings : GAITrackedViewController<serveD,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSDictionary*Dictresponse;
    UIButton * tableRowArrow;
    BOOL touch1selected, touchForPayments;
}
@end
