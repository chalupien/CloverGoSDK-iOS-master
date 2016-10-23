//
//  CloverGoCardReaderInfo.h
//  CloverGo
//
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloverGoStatusCode.h"
#import <RUA_BLE/RUADevice.h>


@interface CloverGoCardReaderInfo : NSObject

+(CloverGoCardReaderInfo*)sharedInstance;

+(void)readerInfoAfterCompletion:(void(^)(CloverGoCardReaderInfo* info,NSError* error))completion;

@property (nonatomic, readonly)	NSString* serialNo;

@property (nonatomic, readonly)	NSInteger batteryPercentage;

@property (nonatomic, readonly)	CloverGoCardReaderType	readerType;

@property (nonatomic, readonly) NSString* label;

@property (nonatomic, readonly) RUADevice* device;

- (instancetype)getReaderInfoObject;

- (instancetype)initWithDevice:(RUADevice*)device;

- (void)setReaderInfo:(CloverGoCardReaderInfo*)info;

- (void)setbatteryPercentage:(NSString*)percentage;

- (void)setDeviceType:(CloverGoCardReaderType)type;

- (void)setDeviceSerialNo:(NSString*)serialNo;



@end
