//
//  main.m
// Payo
//
//  Created by administrator on 08/01/13.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PixateFreestyle/PixateFreestyle.h>
#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        [PixateFreestyle initializePixateFreestyle];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}