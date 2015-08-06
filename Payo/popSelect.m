//
//  popSelect.m
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import "popSelect.h"
#import "HistoryFlat.h"
@interface popSelect ()

@end

@implementation popSelect

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    popList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 160, 216)];
    [popList setRowHeight:54];
    [popList setSeparatorColor:Rgb2UIColor(188, 190, 192, .5)];
    [popList setUserInteractionEnabled:YES];
    [popList setScrollEnabled:NO];
    [popList setDelegate:self];
    [popList setDataSource:self];
    [self.view addSubview:popList];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [popList reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    for(UIView *subview in cell.contentView.subviews)
        [subview removeFromSuperview];
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Roboto" size:17]];

    if (isHistFilter)
    {
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"PopSelect_Row1", @"'All Transfers' Text");
        }
        else if(indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"PopSelect_Row2", @"'Sent' Text");
        }
        else if(indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"PopSelect_Row5", @"'Disputes' Text");
        }
        else if(indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"PopSelect_CancelRow", @"'Cancel' Text");
        }
        return cell;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isHistFilter)
    {
        if (indexPath.row == 0) {
            listType = @"ALL";
        }
        else if(indexPath.row == 1) {
            listType = @"SENT";
        }
        else if(indexPath.row == 4) {
            listType = @"DISPUTED";
        }
        else if(indexPath.row == 5) {
            listType = @"CANCEL";
        }
        isFilterSelected = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPopOver" object:nil];

        return;
    }

    if (!memoList) {
        return;
    }
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
