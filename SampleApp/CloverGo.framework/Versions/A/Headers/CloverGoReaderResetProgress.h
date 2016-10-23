//
//  CloverGoReaderResetProgress.h
//  CloverGo
//
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloverGoStatusCode.h"

@interface CloverGoReaderResetProgress : NSObject

+(CloverGoReaderResetProgress*)sharedInstance;

- (instancetype)initWithReaderResetProgress:(int)progress
                                       code:(CloverGoCardReaderResetStatusCode)statusCode
                                    message:(NSString*)message;

@property (nonatomic,readonly) int progress;
@property (nonatomic,readonly) CloverGoCardReaderResetStatusCode statusCode;
@property (nonatomic,readonly) NSString* message;


@end
