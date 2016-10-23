//
//  CloverGoKeyedTransactionRequest.h
//  CloverGo
//
//  
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import "CloverGoTransactionRequest.h"
#import "CloverGoCard.h"

@interface CloverGoKeyedTransactionRequest : CloverGoTransactionRequest

+ (CloverGoKeyedTransactionRequest*)sharedInstance;

- (instancetype)initWithCardNumber:(NSString*)number
                       cardExpDate:(NSString*)MMYY
                           cardCvv:(NSString*)cvv
                       cardPresent:(BOOL)cardPresent;

- (instancetype)initWithCardNumber:(NSString*)number
                       cardExpDate:(NSString*)MMYY
                           cardCvv:(NSString*)cvv
                       cardPresent:(BOOL)cardPresent
                           zipCode:(NSString*)zip;

- (void)setAmount:(NSDecimalNumber*)amount
           setTax:(NSDecimalNumber*)tax
           setTip:(NSDecimalNumber*)tip
         itemName:(NSString*)name;

- (void)setAmount:(NSDecimalNumber*)amount
           setTax:(NSDecimalNumber*)tax
           setTip:(NSDecimalNumber*)tip
         itemName:(NSString*)name
setExternalPaymentId:(NSString*)externalPaymentId
        lineItems:(NSArray*)lineItems;

@property (nonatomic, readonly)	NSDecimalNumber*    amount;
@property (nonatomic, readonly)	NSDecimalNumber*	taxAmount;
@property (nonatomic, readonly)	NSDecimalNumber*	tipAmount;
@property (nonatomic, readonly)	NSString*           itemName;
@property (nonatomic, readonly)	CloverGoCard*		card;
@property (nonatomic, readonly)	NSString*           externalPaymentId;
@property (nonatomic, readonly) NSArray*            lineItems;

+ (CloverGoCard*)getCard;

- (BOOL)validateCardNumber;

- (BOOL)validateCardExpDate;

- (BOOL)validateCardCvv;

- (BOOL)validateZipCode; // zip is optional for Clover Go Transaction - if sent - the payment with undergo an AVS check.
// zipCode on CloverGo follows internal zip rules where its maximum length is 9 and allows alphanumeric characters


@end
