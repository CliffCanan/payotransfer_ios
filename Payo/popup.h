//
//  popup.h
//  Nooch
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"

@interface popup : UIViewController{
    UIView *pup;
    NSString *msg;

}

-(void)slideIn:(id)obj;
-(void)slideOut:(id)obj;
-(void)fadeIn:(id)obj;
-(void)fadeOut:(id)obj;
@end
