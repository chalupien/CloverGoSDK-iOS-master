//
//  CloverGoTransactionEvent.h
//  CloverGo
//
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloverGoStatusCode.h"

@interface CloverGoTransactionEvent : NSObject

+ (instancetype)initWithEventType:(CloverGoTransactionEventType)type
                          message:(NSString*)message;

+ (CloverGoTransactionEvent*)sharedInstance;

@property (nonatomic, readonly)	NSString* message;

@property (nonatomic, readonly)	CloverGoTransactionEventType eventType;

@end
