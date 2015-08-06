//
//  NavControl.h
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
@interface NavControl : UINavigationController

-(void)disable;
-(void)reenable;
-(void)reset;
@end
