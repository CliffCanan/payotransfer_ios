//
//  GetEncryptionValue.m
// Payo
//
//  Created by Nooch on 09/08/11.
//  Copyright (c) 2015 Nooch Inc. All rights reserved.
//

#import "GetEncryptionValue.h"
#import "Constant.h"
#import "NSString+ASBase64.h"
NSMutableURLRequest*requestEncryption;

@implementation GetEncryptionValue

@synthesize Delegate, tag;

# pragma mark - Custom Method

-(void)getEncryptionData:(NSString *) stringtoEncry {
    
    NSString *encodedString = [NSString encodeBase64String:stringtoEncry];
    
    responseData = [[NSMutableData alloc] init];
    requestEncryption = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@"@"/%@?%@=%@", serverURL,@"GetEncryptedData",@"data",encodedString]]];
    [requestEncryption setHTTPMethod:@"GET"];
    [requestEncryption setTimeoutInterval:500.0f];
    NSURLConnection *connection =[[NSURLConnection alloc] initWithRequest:requestEncryption delegate:self];
    if (!connection)
        NSLog(@"connect error");
    
}

# pragma mark - NSURL Connection Methods

//response method for all request
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    NSError* error;

    // SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
//    id object = [NSJSONSerialization
//                 JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
//                 options:kNilOptions
//                 error:&error];;
    
  //  NSMutableArray *transResult;
    
//    if (object != nil) {
//        // Success!
//        transResult = [NSJSONSerialization
//                       JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
//                       options:kNilOptions
//                       error:&error];;
//    }
    
    NSMutableDictionary *loginResult = [NSJSONSerialization
                                        JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                                        options:kNilOptions
                                        error:&error];;
    NSString *resultStr = [[NSString alloc] initWithString:[loginResult objectForKey:@"Status"]];
    [self.Delegate encryptionDidFinish:resultStr TValue:self.tag];
}

@end
