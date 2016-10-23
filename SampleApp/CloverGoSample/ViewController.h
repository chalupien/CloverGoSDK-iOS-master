//
//  ViewController.h
//  CloverGoSample
//
//  Created by Raghu Vamsi on 11/8/15.
//  Copyright © 2015 First Data Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloverGo/CloverGo.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) NSArray *orderItems;

@property (strong, nonatomic) CloverGoTaxRate *taxRate;

@property (nonatomic, assign) BOOL isCustomItem;

@end

