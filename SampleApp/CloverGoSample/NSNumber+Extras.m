//
//  NSNumber+Extras.m
//  MVP1.0.1
//
//  Copyright (c) 2015 FirstData. All rights reserved.
//

#import "NSNumber+Extras.h"

static NSNumberFormatter*		currencyFormatter;
static NSDateFormatter*			txDateFormatter;
static NSDecimalNumberHandler*	roundingHandler;

@implementation NSNumber (Extras)

+(void)initialize
{
	currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[currencyFormatter setCurrencyCode:@"USD"];
	
	txDateFormatter = [[NSDateFormatter alloc] init];
	[txDateFormatter setDateFormat:@"yyyy-MM-dd"];
	
	roundingHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
																				  scale:0
																	   raiseOnExactness:NO
																		raiseOnOverflow:NO
																	   raiseOnUnderflow:NO
																	raiseOnDivideByZero:NO];
}

+(NSDecimalNumber*)dollarsFromString:(NSString*)string
{
	NSNumber*			tempNumber = [currencyFormatter numberFromString:string];
	if(tempNumber == nil)
		return [NSDecimalNumber zero];
	
	NSDecimalNumber*	tempDecimal = [NSDecimalNumber decimalNumberWithDecimal:[tempNumber decimalValue]];
	
	return tempDecimal;
}

+(NSDecimalNumber*)penniesFromString:(NSString*)string
{
	NSDecimalNumber*	tempDecimal = [[NSNumber dollarsFromString:string] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[@100 decimalValue]] withBehavior:roundingHandler];

	return tempDecimal;
}

-(NSDate*)dateFromUnixMiliseconds
{
	NSTimeInterval	tempCreationTimeInterval = [self doubleValue] / 1000.0;
	NSDate*			creationDate = [[NSDate alloc] initWithTimeIntervalSince1970:tempCreationTimeInterval];

	return creationDate;
}

-(NSString*)txDateFromUnixMiliseconds
{
	return [txDateFormatter stringFromDate:[self dateFromUnixMiliseconds]];
}

-(NSInteger)pennies
{
	return (NSInteger) ([self doubleValue] / 100.0);
}

-(NSString*)dollarStringFromPennies
{
	NSNumber*	tempNumber = [NSNumber numberWithDouble:self.doubleValue/100.0];
	NSString*	dollars = [currencyFormatter stringFromNumber:tempNumber];
	
	return dollars;
}

-(NSString*)dollarString
{
	return [currencyFormatter stringFromNumber:self];
}
@end
