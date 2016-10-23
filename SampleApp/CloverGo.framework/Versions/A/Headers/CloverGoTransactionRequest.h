//
//  CloverGoTransactionRequest.h
//  CloverGo
//
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloverGoCard.h"

@interface CloverGoTransactionRequest : NSObject

+ (instancetype) requestWithAmount:(NSDecimalNumber*)subTotal
                               tax:(NSDecimalNumber*)tax
                               tip:(NSDecimalNumber*)tip
                          itemName:(NSString*)itemName;

+ (instancetype) requestWithAmount:(NSDecimalNumber*)subTotal
                               tax:(NSDecimalNumber*)tax
                               tip:(NSDecimalNumber*)tip
                 externalPaymentId:(NSString*)externalPaymentId
                         orderItems:(NSArray*)orderItems;

+ (void)setCreditCard:(CloverGoCard*)card;

+(CloverGoTransactionRequest*)sharedInstance;


@property (nonatomic, readonly)	NSDecimalNumber*    amount;
@property (nonatomic, readonly)	NSDecimalNumber*	taxAmount;
@property (nonatomic, readonly)	NSDecimalNumber*	tipAmount;
@property (nonatomic, readonly)	NSString*           itemName;
@property (nonatomic, readonly)	CloverGoCard*		card;
@property (nonatomic, readonly) NSArray*            orderItems;
@property (nonatomic, readonly) NSString*           externalPaymentId;

- (void)updateRequest:(CloverGoTransactionRequest*)request;


@end
