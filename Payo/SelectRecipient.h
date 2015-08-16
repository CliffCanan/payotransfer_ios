//
//  SelectRecipient.h
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "serve.h"
#import "HowMuch.h"
#import "AddRecipient.h"
#import "SpinKit/RTSpinKitView.h"

BOOL isFromBankWebView;
int screenLoadedTimes;
NSMutableDictionary * dict;

@interface SelectRecipient : GAITrackedViewController<UITableViewDelegate,UITableViewDataSource,serveD,UISearchBarDelegate,UIActionSheetDelegate,MBProgressHUDDelegate>
{
    BOOL searching, navIsUp, isRecentList;
    BOOL shouldAnimate;

    NSMutableArray * arrSearchedRecords;
    NSString * searchString;

    UIImageView * arrow;
    UILabel * em;
    UISearchBar * search;
}
@end
