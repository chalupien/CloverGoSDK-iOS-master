//
//  InventoryTableTableViewController.m
//  CloverGoSample
//
//  Created by Rajan Veeramani on 5/24/16.
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import "InventoryTableTableViewController.h"
#import <CloverGo/CloverGo.h>
#import "KVNProgress.h"
#import "ViewController.h"

@interface InventoryTableTableViewController ()<CloverGoInventoryDelegate>

@property (nonatomic,strong) CloverGo *cloverGoInstance;
@property (nonatomic,strong) NSArray *inventoryItems;

@end

@implementation InventoryTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cloverGoInstance = [CloverGo sharedInstance];
    _cloverGoInstance.inventoryDelegate = self;
 
    [self configureKVNProgress];
    [self initSpinnerWithmessage:@"Loading Items..." details:@"Please wait..."];
    [self.cloverGoInstance getInventoryItems];
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
    return self.inventoryItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InventoryCell" forIndexPath:indexPath];
    CloverGoInventoryItem *item = [self.inventoryItems objectAtIndex:indexPath.row];
    NSNumber *itemPrice = item.price;
    double priceInDollar = [itemPrice doubleValue]/100;
    cell.textLabel.text = [item.name stringByAppendingString:[@" - $" stringByAppendingString:[NSString stringWithFormat:@"%.2f", priceInDollar]]];
    
    return cell;
}

-(void) getInventoryItemsSuccess:(NSArray *)inventoryItemsFromBackend {
    _inventoryItems = inventoryItemsFromBackend;
    [self.tableView reloadData];
    [self removeSpinner];
}

-(void) getInventoryItemsFailure:(NSError *)error {
    NSLog(@"Error Occured while fetching Inventory Items - %@", error);
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    //Test to all Inventory Items for tax Calculation Testing
    if (path) {
        CloverGoInventoryItem *orderItem = [self.inventoryItems objectAtIndex:path.row];
		orderItem.unitQuantity = 1;
        ViewController *vc;
        vc = [segue destinationViewController];
        vc.orderItems = @[orderItem];
    }
}

@end
