//
//  ResetPIN.h
//  Nooch
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "Helpers.h"
#import "Home.h"
#import <MessageUI/MessageUI.h>

@interface ResetPIN : GAITrackedViewController<serveD,MFMailComposeViewControllerDelegate>
{
    NSDictionary*dictResult;
    UILabel *title;
    int pinchangeProgress;
    NSString*newPinString;
    NSString *encryptedPIN;
    NSString*newEncryptedPIN;
}
@end
