//
//  CloverGoTransactionResponse.h
//  CloverGo
//
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloverGoTransactionResponse : NSObject

+ (instancetype)initWithResponseFromBackend:(NSDictionary*)response;

+(CloverGoTransactionResponse*)sharedInstance;

@property (nonatomic, readonly)	NSString*           orderId;
@property (nonatomic, readonly)	NSString*           transactionID;
@property (nonatomic, readonly)	NSDecimalNumber*    amountCharged;// includes tax and tip if any
@property (nonatomic, readonly)	NSString*           cardType;
@property (nonatomic, readonly)	NSString*           cardLast4Digits;
@property (nonatomic, readonly)	NSString*           cardholderName;
@property (nonatomic, readonly) NSString*           externalPaymentId;
@property (nonatomic, readonly) NSString*           cvmResult;
@property (nonatomic, readonly) NSString*           entryType;
@property (nonatomic, readonly) NSString*           authCode;
@property (nonatomic, readonly) NSString*           aid;

@end
