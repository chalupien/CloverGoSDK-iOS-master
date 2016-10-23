//
//  CloverGoCardReaderEvent.h
//  CloverGo
//
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloverGoStatusCode.h"

@interface CloverGoCardReaderEvent : NSObject

+ (instancetype)initWithEventType:(CloverGoCardReaderEventType)type
                         message:(NSString*)message
                    detailMessage:(NSString*)detail
                 showCancelButton:(BOOL)show;

+ (CloverGoCardReaderEvent*)sharedInstance;

@property (nonatomic, readonly)	NSString* message;

@property (nonatomic, readonly)	NSString* detailMessage;

@property (nonatomic, readonly)	CloverGoCardReaderEventType	eventType;

@property (nonatomic, readonly)	BOOL	showCancelButton;


@end
