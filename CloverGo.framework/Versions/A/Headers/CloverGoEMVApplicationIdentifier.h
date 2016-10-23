//
//  CloverGoEMVApplicationIdentifier.h
//  CloverGo
//
//  
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RUA_BLE/RUAApplicationIdentifier.h>

@interface CloverGoEMVApplicationIdentifier : NSObject

+(instancetype)initWithIdentifier:(RUAApplicationIdentifier*)identifier;

+(CloverGoEMVApplicationIdentifier*)sharedInstance;

@property (nonatomic, readonly) NSString* label;

@property (nonatomic, readonly) RUAApplicationIdentifier* identifier;

@end
