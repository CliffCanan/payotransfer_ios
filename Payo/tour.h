//
//  tour.h
// Payo
//
//  Created by Clifford Canan on 9/17/14.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "serve.h"
#import "Helpers.h"
#import "Home.h"
#import "EAIntroView.h"

@interface tour : GAITrackedViewController<EAIntroDelegate>
{
    EAIntroView * intro;
}
@end
