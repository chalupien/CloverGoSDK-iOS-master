//
//  HomeViewController.m
//  CloverGoSample
//
//  Created by Rajan Veeramani on 5/24/16.
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import "HomeViewController.h"
#import <CloverGo/CloverGo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface HomeViewController ()

@property (nonatomic,strong) CloverGo *cloverGoInstance;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (!_cloverGoInstance) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
        NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
        
        NSString *merchantId = data[@"merchant_id"];
        NSString *employeeId = data[@"employee_id"];
        NSString *deviceId = data[@"device_id"];
        
        self.cloverGoInstance =  [[CloverGo alloc] initWithEmployeeId:employeeId merchantID:merchantId deviceId:deviceId];
        
        [self.cloverGoInstance setDebugMode:YES];
        
        [self.cloverGoInstance allowDuplicateTransactions:YES];
        
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
