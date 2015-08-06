//
//  HowMuch.h
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Home.h"
BOOL isFromHome;
BOOL isFromStats;
BOOL isFromArtisanDonationAlert;

@interface HowMuch : GAITrackedViewController<UITextFieldDelegate, UINavigationControllerDelegate>
{
    NSString * transLimitFromArtisanString;
    int transLimitFromArtisanInt;
}

-(id)initWithReceiver:(NSDictionary *)receiver;
@end
