//
//  TaxRateTableViewController.m
//  CloverGoSample
//
//  Created by Rajan Veeramani on 5/24/16.
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import "TaxRateTableViewController.h"
#import <CloverGo/CloverGo.h>
#import "KVNProgress.h"
#import "ViewController.h"

@interface TaxRateTableViewController ()<CloverGoTaxRateDelegate>

@property (nonatomic,strong) CloverGo *cloverGoInstance;
@property (nonatomic,strong) NSArray *taxRates;


@end

@implementation TaxRateTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _cloverGoInstance = [CloverGo sharedInstance];
    self.cloverGoInstance.taxRateDelegate = self;
    [self configureKVNProgress];
    [self initSpinnerWithmessage:@"Loading Tax Rates..." details:@"Please wait..."];
    [self.cloverGoInstance getTaxRates];
}

- (void)configureKVNProgress{
    KVNProgressConfiguration *basicConfiguration = [KVNProgressConfiguration defaultConfiguration];
    basicConfiguration.fullScreen = YES;
    [KVNProgress setConfiguration:basicConfiguration];
    [KVNProgress showCancelButton:NO];
}

- (void)initSpinnerWithmessage:(NSString*)message
                       details:(NSString *)detailText{
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress showWithStatus:[NSString stringWithFormat:@"%@\n%@",message,detailText]];
    });
}

- (void)removeSpinner{
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress dismiss];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.taxRates.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taxRateCell" forIndexPath:indexPath];
    
    CloverGoTaxRate *taxRate = [self.taxRates objectAtIndex:indexPath.row];
    if (taxRate) {
        NSNumber *taxRateValue = taxRate.taxRate;
        double taxRatePercent = [taxRateValue doubleValue]/100000;
        cell.textLabel.text =
        [taxRate.taxRateName stringByAppendingString:[@" ("
                        stringByAppendingString:[[NSString stringWithFormat:@"%.4f%%", taxRatePercent]
                        stringByAppendingString:@")"]]];
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


-(void) getTaxRatesSuccess:(NSArray *)taxRatesFromBackend {
    _taxRates = taxRatesFromBackend;
    [self.tableView reloadData];
    [self removeSpinner];
}

-(void) getTaxRatesFailure:(NSError *)error {
    NSLog(@"Error Occured while fetching Inventory Items - %@", error);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    if (path) {
        CloverGoOrderItem *orderItem = [CloverGoOrderItem new];
        orderItem.itemName = @"Custom Item 1";
        CloverGoTaxRate *taxRateSelected = [self.taxRates objectAtIndex:path.row];
        NSArray *taxRates = @[taxRateSelected];
        orderItem.taxRates = taxRates;
        orderItem.unitQuantity = 1;
        ViewController *vc;
        vc = [segue destinationViewController];
        vc.taxRate = taxRateSelected;
        vc.isCustomItem = YES;
        vc.orderItems = @[orderItem];
    }
    
}

@end
