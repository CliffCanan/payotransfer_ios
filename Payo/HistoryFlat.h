//
//  HistoryFlat.h
//  Nooch
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "popSelect.h"
#import "FPPopoverController.h"
#import "SWTableViewCell.h"
#import "Home.h"
#import <MessageUI/MessageUI.h>
#import "SpinKit/RTSpinKitView.h"

BOOL isHistFilter;
NSString *listType;

@interface HistoryFlat : GAITrackedViewController<UITableViewDataSource,UITableViewDelegate,
serveD,FPPopoverControllerDelegate,UISearchBarDelegate,SWTableViewCellDelegate,MBProgressHUDDelegate,MFMailComposeViewControllerDelegate>
{
    NSArray *histArrayCommon;
    NSMutableArray *histArray;
    NSMutableArray *histShowArrayCompleted;
    NSMutableArray * histTempCompleted;
    BOOL ishistLoading;
    BOOL isEnd, isStart;
    BOOL locUpdateSuccessfully;
    BOOL isFilter, isSearch, isLocalSearch;
    int totalDisplayedTransfers_completed,index;
    float firstX,firstY;
    float lat_hist,lon_hist;
    short countRows;

    FPPopoverController * fp;
    NSString * SearchString;
    UIButton * exportHistory;
    NSString * subTypestr;
    NSDate * ServerDate;
    UILabel * emptyText_localSearch;
    CLLocationManager * locationManager;
    CLLocationCoordinate2D locationUser;
}
@property(nonatomic,strong) MBProgressHUD *hud;
@end
