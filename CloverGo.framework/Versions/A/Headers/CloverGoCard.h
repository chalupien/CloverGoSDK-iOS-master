//
//  FDCloverCard.h
//  CloverGo
//
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloverGoCard : NSObject


/**
 *  create card object
 *
 *  @params
 *      cardNumber  -    credit / debit card number
 *      expDate     -    expiry date format : MMYY
 *      cvv         -    4 digits for AMEX and 3 for all other card brands
 *      cardPresent -    card is present physically at the time of transaction
 *      zipCode     -    (optional) zip code.
 */

+ (instancetype)createObjectWithCardNumber:(NSString*)cardnum
                                   expDate:(NSString*)MMYY
                                       cvv:(NSString*)cvvCode
                               cardPresent:(BOOL)cardPresent
                                   zipCode:(NSString*)zip;

+(CloverGoCard*)sharedInstance;


@property (nonatomic, readonly)	NSString*   cardNumber;
@property (nonatomic, readonly)	NSString*	expDate;
@property (nonatomic, readonly)	NSString*	cvv;
@property (nonatomic, readonly)	NSString*	zipCode;
@property (nonatomic, readonly)	BOOL		isCardPresent;




@end
