//
//  core.h
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "assist.h"

@interface core : assist

+(BOOL)isAlive:(NSString*)path;
+(BOOL)isClean:(id)object;
+(UIColor*)hexColor:(NSString*)hex;
+(NSString *)path:(NSString *)type;
+(UIFont *)nFont:(NSString*)weight size:(int)size;

@end
