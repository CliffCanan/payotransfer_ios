//
//  SelectRecipient.h
//  Nooch
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
#import "serve.h"
#import "HowMuch.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "SpinKit/RTSpinKitView.h"

BOOL isphoneBook, isFromBankWebView;
int screenLoadedTimes;

@interface SelectRecipient : GAITrackedViewController<UITableViewDelegate,UITableViewDataSource,serveD,UISearchBarDelegate,ABPeoplePickerNavigationControllerDelegate,UIActionSheetDelegate,MBProgressHUDDelegate>
{
    BOOL searching, navIsUp, isRecentList;
    BOOL emailEntry, shouldAnimate, phoneNumEntry;

    NSArray * emailAddresses;
    NSMutableArray * arrSearchedRecords;
    NSString * emailphoneBook, * phoneBookPhoneNum , * firstNamePhoneBook, * lastNamePhoneBook;
    NSString * searchString;

    UIImageView * arrow;
    UILabel * em;
    UISearchBar * search;
}
@end
