//
//  TransferPIN.h
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Helpers.h"
#import "Home.h"
#import "serve.h"
#import <MessageUI/MessageUI.h>
#import "SpinKit/RTSpinKitView.h"

@interface TransferPIN : GAITrackedViewController<UITextFieldDelegate,serveD,NSURLConnectionDelegate,MFMailComposeViewControllerDelegate,MBProgressHUDDelegate>
{
    UILabel * totalRupees, * exchangeRate, * glyphArrow;

    NSData *postTransfer;
    NSData *postDataTransfer;
    NSString *addressLine1;
    NSString * city,* state;
    NSString *country;
    NSString *encryptedPINNonUser;
    NSString *longitude, *latitude;
    NSString *postLengthTransfer;
    NSString *receiverFirst;
    NSString *receiverId;
    NSString *transactionId;
    NSString *responseString;
    NSString *urlStrTranfer;
    NSMutableURLRequest *requestTransfer;
    NSURL *urlTransfer;
    float exchangeRateFloat;
    float lon, lat;
    NSMutableDictionary * transactionInputTransfer;
    NSMutableDictionary * transactionTransfer;
    NSDictionary * dictResultTransfer; // in 'connectionDidFinishLoading' Response from server
    NSDictionary * googleLocationResults;
}
- (id)initWithReceiver:(NSMutableDictionary *)receiver type:(NSString *)type amount:(float)amount;

@end