//
//  popSelect.h
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
bool memoList;
BOOL isFilterSelected;
@interface popSelect : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UITableView *popList;
}

@end
