//
//  serve.h
// Payo
//
//  Created by Cliff Canan on 7/30/15.
//  Copyright (c) 2015 Nooch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MBProgressHUD.h"

@protocol serveD
@required
-(void)listen:(NSString *)result tagName:(NSString *)tagName;
-(void)Error:(NSError*)Error;
@end

@interface serve : NSObject {
    NSMutableData *responseData;
    id<serveD> Delegate;
    NSString *tagName;
    NSString *latlng;
    MKPlacemark *placeMarker;
    NSString *country;
    NSString *city;
    NSString *state;
    NSString *zipcode;
    NSString *addressLine1;
    NSString *addressLine2;
    NSString *TransactionDate;
    NSString *Latitude;
    NSString *Longitude;
    NSString *Altitude;
    NSMutableDictionary*dictUsers;
}
@property (retain) id<serveD> Delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSString *tagName;
@property(nonatomic,strong) MBProgressHUD *hud;

-(void)addRecipient:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email phone:(NSString*)phone city:(NSString*)city;
-(void)dupCheck:(NSString*)email;
-(void)forgotPass:(NSString *)email;
-(void)getSettings;
-(void)getEncrypt:(NSString *)input;
-(void)getExchangeRate;
-(void)getDetails:(NSString*)username;
-(void)getInvitedMemberList:(NSString*)memId;
-(void)GetTransactionDetail:(NSString*)transactionId;
-(void)getMemIdFromuUsername:(NSString*)username;
-(void)getMemberIds:(NSArray*)input;
-(void)getRecents;
-(void)GetReferralCode:(NSString*)memberid;
-(void)getTotalReferralCode:(NSString *)inviteCode;
-(void)get_favorites;
-(void)GetSynapseBankAccountDetails;
-(void)GetServerCurrentTime;
-(void)histMore:(NSString*)type sPos:(NSInteger)sPos len:(NSInteger)len subType:(NSString*)subType;
-(void)histMoreSerachbyName:(NSString*)type sPos:(NSInteger)sPos len:(NSInteger)len name:(NSString*)name subType:(NSString*)subType;
-(void)login:(NSString*)email password:(NSString*)pass remember:(BOOL)isRem lat:(float)lat lon:(float)lng;
-(void)loginwithFB:(NSString*)email FBId:(NSString*)FBId remember:(BOOL)isRem lat:(float)lat lon:(float)lng;
-(void)LogOutRequest:(NSString*) memberId;
-(void)MemberNotificationSettings:(NSDictionary*) memberNotificationSettings type:(NSString*)type;
-(void)MemberNotificationSettingsInput;
-(void)newUser:(NSString *)email first:(NSString *)fName last:(NSString *)lName password:(NSString *)password pin:(NSString*)pin invCode:(NSString*)inv fbId:(NSString *)fbId;
-(void)pinCheck:(NSString*)memId pin:(NSString*)pin;
-(void)ReferalCodeRequest:(NSString*)email;
-(void)RemoveSynapseBankAccount;
-(void)RaiseDispute:(NSDictionary*)Input;
-(void)resendEmail;
-(void)resetPassword:(NSString*)old new:(NSString*)new;
-(void)resetPIN:(NSString*)old new:(NSString*)new;
-(void)resendSMS;
-(void)saveDob:(NSString*)dob;
-(void)saveSsn:(NSString*)ssn;
-(void)saveUserIpAddressAndDeviceId:(NSString*)IpAddress;
-(void)SaveImmediateRequire:(BOOL)IsRequiredImmediatley;
-(void)saveShareToFB_Twitter:(NSString*)PostTo;
-(void)storeFB:(NSString*)fb_id isConnect:(NSString*)isconnect;
-(void)sendCsvTrasactionHistory:(NSString *)emailaddress;
-(void)setEmailSets:(NSDictionary*)notificationDictionary;
-(void)setPushSets:(NSDictionary*)notificationDictionary;
-(void)setSets:(NSDictionary*)settingsDictionary;
-(void)submitIdDocument;
-(void)TransferMoneyToNonNoochUser:(NSDictionary*)transactionInput email:(NSString*)email;
-(void)UpDateLatLongOfUser:(NSString*)lat lng:(NSString*)lng;
-(void)ValidatePinNumberToEnterForEnterForeground:(NSString*)memId pin:(NSString*)pin;
-(void)validateInviteCode:(NSString *)inviteCode;

@end