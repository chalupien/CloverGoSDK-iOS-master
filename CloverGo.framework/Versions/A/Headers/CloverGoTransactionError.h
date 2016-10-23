//
//  CloverGoTransactionError.h
//  CloverGo
//
//  
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloverGoTransactionError : NSObject

+ (instancetype)initWithResponseFromBackend:(NSDictionary*)response;

+(CloverGoTransactionError*)sharedInstance;


@property (nonatomic, readonly)	NSString*           errorCode;
@property (nonatomic, readonly)	NSString*           errorMessage;


@end
