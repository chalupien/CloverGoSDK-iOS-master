//
//  CloverGoTaxRate.h
//  CloverGo
//
//  Created by Rajan Veeramani on 5/18/16.
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloverGoTaxRate : NSObject

@property(nonatomic, strong)	NSString*	taxRateId;
@property(nonatomic, strong)	NSString*	taxRateName;
@property(nonatomic, strong)	NSNumber*	taxRate;
@property(nonatomic, readonly)	NSInteger	taxRatePercentage;
@property(nonatomic, assign)	BOOL		isDefault;

-(instancetype)initWithDictionary:(NSDictionary*)dict;

@end
