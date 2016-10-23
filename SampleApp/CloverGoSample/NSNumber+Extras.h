//
//  NSNumber+Extras.h
//  MVP1.0.1
//
//  Copyright (c) 2015 FirstData. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Extras)

+(NSDecimalNumber*)penniesFromString:(NSString*)string;
+(NSDecimalNumber*)dollarsFromString:(NSString*)string;

-(NSDate*)dateFromUnixMiliseconds;
-(NSString*)txDateFromUnixMiliseconds;
-(NSInteger)pennies;
-(NSString*)dollarString;
-(NSString*)dollarStringFromPennies;
@end
