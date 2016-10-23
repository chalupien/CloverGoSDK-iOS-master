//
//  CloverGoLineItem.h
//  CloverGo
//
//  Created by Rajan Veeramani on 5/18/16.
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloverGoOrderItem : NSObject

@property (nonatomic, strong) NSString *itemId;
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, assign) NSInteger unitQuantity;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSArray *taxRates;

+(instancetype)instanceWithDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)jsonRepresentation;

+(NSDecimalNumber*)totalForLineItemsInPennies:(NSArray*)lineItems;
+(NSDecimalNumber*)totalTaxForLineItemsInPennies:(NSArray*)lineItems;

@end
