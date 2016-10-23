//
//  ViewController.m
//  CloverGoSample
//
//  Created by Raghu Vamsi on 11/8/15.
//  Copyright © 2015 First Data Inc. All rights reserved.
//

#import "ViewController.h"
#import <CloverGo/CloverGo.h>
#import "UIAlertController+CustomUIAlertController.h"
#import "KVNProgress.h"
#import "SignatureViewController.h"
#import "NSNumber+Extras.h"

#define InitiateAppFlowEventNotification @"InitiateAppFlowEvent"

@interface ViewController ()<UITextFieldDelegate,UIActionSheetDelegate, CloverGoCardReaderDelegate, CloverGoTransactionDelegate>
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *taxTextField;
@property (weak, nonatomic) IBOutlet UITextField *tipTextField;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UIButton *payButton;

@property (nonatomic, assign) BOOL readerConnected;
@property (nonatomic, assign) BOOL updateReader;
@property (nonatomic, assign) BOOL readerError;
@property (nonatomic,strong) CloverGo* cloverGoInstance;

@property (nonatomic,strong) CloverGoTransactionResponse* transactionResponse;

@property (nonatomic,strong) NSDecimalNumber* totalAmount;

@property (strong, nonatomic) AlertControllerCompletionBlock actionSheetTapBlock;

@property (strong, nonatomic) UIAlertController *alertController;

- (IBAction)payAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboardOnScreen)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    // set the required delegates
    _cloverGoInstance = [CloverGo sharedInstance];
    _cloverGoInstance.cardReaderDelegate = self;
    _cloverGoInstance.transactionDelegate = self;

    
    [[CloverGo sharedInstance] allowDuplicateTransactions:YES]; // allow duplicate transactions
    [[CloverGo sharedInstance] ignoreAVSCheck:YES]; // ignore avs promt issues
    
    // enabling debug mode will print console log statements
    [[CloverGo sharedInstance] setDebugMode:YES];

    [self configureKVNProgress];
    
    self.amountTextField.delegate = self.tipTextField.delegate = self.taxTextField.delegate = self;

}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.totalLabel.text = @"Total $0.00";
    self.amountTextField.text = self.tipTextField.text = @"";
    
    //Calculate Tax based on Line Items
    
    if (_orderItems) {
        NSNumber *amount, *tax;
        amount = [[CloverGo sharedInstance] getOrderTotalForOrderItems:self.orderItems];
        tax = [[CloverGo sharedInstance] getOrderTaxForOrderItems:self.orderItems];
        self.amountTextField.text = [amount dollarStringFromPennies];
        self.taxTextField.text = [tax dollarStringFromPennies];
    }
    
    [self calculateTotal];
    
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *cleanCentString = [[textField.text
                                  componentsSeparatedByCharactersInSet:
                                  [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                 componentsJoinedByString:@""];
    
    NSDecimalNumber *result;
    
    // Check the user input
    if (string.length > 0)
    {
        // Digit added
        if(textField.text.length > 10)
            return NO;
        
        result = [NSDecimalNumber decimalNumberWithString:[cleanCentString stringByAppendingString:string]];
    }
    else
    {
        // Digit deleted
        if(cleanCentString.length)
            result = (cleanCentString.length) ?
            [NSDecimalNumber decimalNumberWithString:[cleanCentString substringToIndex:cleanCentString.length -1]] :
            [NSDecimalNumber zero];
    }
    
    // Write amount with currency symbols to the textfield
    textField.text = [result dollarStringFromPennies];
    
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    if (theTextField == self.amountTextField) {
        [self.amountTextField resignFirstResponder];
        [self.tipTextField becomeFirstResponder];
    }
    
    if (theTextField == self.tipTextField) {
//        [self.view endEditing:YES];
        [self.tipTextField resignFirstResponder];
        [self.taxTextField becomeFirstResponder];
    }
    
    if (theTextField == self.taxTextField) {
        [self.view endEditing:YES];
    }
    
    [self calculateTotal];
    
    return YES;
}

- (void)configureKVNProgress{
    KVNProgressConfiguration *basicConfiguration = [KVNProgressConfiguration defaultConfiguration];
    basicConfiguration.fullScreen = YES;
    [KVNProgress setConfiguration:basicConfiguration];
    [KVNProgress showCancelButton:NO];
}

- (void)dismissKeyboardOnScreen{
    [self.view endEditing:YES];
    [self calculateTotal];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initAppFlow) name:InitiateAppFlowEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelCurrentEMVTransaction) name:CancelButtonClickedOnProgressWindowEventNotification object:nil];
}

- (void)audioDeviceConnected{
    self.alertController = [UIAlertController showSpinnerAlertInViewController:self withTitle:@"Connecting Reader...\nPlease wait..." message:@""];
}


- (void)updateUI:(NSNotification*)notification{
    
    if ([notification.userInfo[@"message"] isEqualToString:@"Dismiss Prompt"]) {
        [self removeSpinner];
    } else {
        [self initSpinnerWithmessage:notification.userInfo[@"message"] details:notification.userInfo[@"detail"]];
        [KVNProgress showCancelButton:([[notification.userInfo[@"showButton"] lowercaseString] isEqualToString:@"no"])? NO:YES];
    }
}



- (void)initAppFlow {
    
    NSLog(@"Proceed Now");
    
    [self removeSpinner];
    
    self.amountTextField.delegate = self.tipTextField.delegate = self;
}

- (void)startReaderReset {
    
    [KVNProgress initReaderReset];
    
    [self.cloverGoInstance resetCardReader];
}


- (void)initSpinnerWithmessage:(NSString*)message
                       details:(NSString *)detailText{
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress showWithStatus:[NSString stringWithFormat:@"%@\n%@",message,detailText]];
    });
}

- (void)calculateTotal{
    
    id xx3 = [NSDecimalNumber decimalNumberWithString:@"100"];
    
    if (_isCustomItem) {
         NSNumber *taxOnItem = [[CloverGo sharedInstance] calculateTaxWithAmount:[self getProperAmount:self.amountTextField] taxRate:_taxRate.taxRate];
        self.taxTextField.text = [taxOnItem dollarStringFromPennies];
        CloverGoOrderItem *item = [_orderItems objectAtIndex:0];
        item.price = [self getProperAmount:self.amountTextField];
        _orderItems = @[item];
    }
    
    self.totalAmount = xx3;
    
    self.totalLabel.text = [NSString stringWithFormat:@"Total %@",[self.totalAmount dollarStringFromPennies]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDecimalNumber*)getProperAmount:(UITextField*)textField{
    
    if (!([textField.text isEqualToString:@"$0.00"] || [textField.text isEqualToString:@""])) {
        
        NSString*	cleanAmount = [[textField.text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"$,"]] componentsJoinedByString: @""];
        if(cleanAmount.length == 0)
            cleanAmount = @"0";
        
        NSDecimalNumberHandler* roundingHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        
        NSDecimalNumber* amountSelected = [[NSDecimalNumber decimalNumberWithString:cleanAmount] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"100.00"] withBehavior:roundingHandler];
        
        NSLog(@"Amount Selected - %@",[amountSelected dollarStringFromPennies]);
        
        return amountSelected;
    } else {
        return [NSDecimalNumber zero];
    }
}

- (IBAction)initializeReader:(id)sender {
    
    BOOL success = [[CloverGo sharedInstance] initCardReader:CloverGoCardReaderType450 shouldAutoReset:YES];
    
    if (!success) {
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Clover SDK"
                                                                        message:@"Reader already initialized"
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Dismiss"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                 }];
        
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self initSpinnerWithmessage:@"Scanning for Readers" details:@"Please wait..."];
    }
}

- (IBAction)payAction:(id)sender {
    
    NSLog(@"Amount to be charged %@",[self.totalAmount dollarStringFromPennies]);
    
    //Quick Mode Item
    if (!_orderItems) {
        CloverGoOrderItem *quickModeItem = [CloverGoOrderItem new];
        quickModeItem.itemName = @"Quick Mode Item 1";
        quickModeItem.price = [self getProperAmount:self.amountTextField];
        quickModeItem.unitQuantity = 1;
        _orderItems = @[quickModeItem];
    }
    if([[CloverGo sharedInstance] isCardReaderReady]){
        [self performEMVTransactionUsingReader];
    } else {
#if (TARGET_IPHONE_SIMULATOR)
        [self performKeyedTransaction];
#endif

    }
}

- (void)performKeyedTransaction{
    
    CloverGoKeyedTransactionRequest* request = [[CloverGoKeyedTransactionRequest alloc] initWithCardNumber:@"4111111111111111" cardExpDate:@"1217" cardCvv:@"510" cardPresent:NO zipCode:@"22102"];
    
//    if (!_lineItems) {
//        CloverGoLineItem *lineItem1 = [CloverGoLineItem initWithItemId:nil itemName:@"Coffee" taxRateId:nil unitQuantity:[@"10" integerValue] price:[NSNumber numberWithInteger:1200]];
//        _lineItems = @[lineItem1];
//    }
    
    id xx3 = [NSDecimalNumber decimalNumberWithString:@"100"];
    
    [request setAmount:xx3 setTax:[self getProperAmount:self.taxTextField] setTip:[self getProperAmount:self.tipTextField] itemName:nil setExternalPaymentId:@"abcd" lineItems:self.orderItems];
    if (request.amount == [NSDecimalNumber zero]) {
        [UIAlertController showAlertInViewController:self withTitle:@"Invalid Amount" message:@"Amount cannot be nil" otherButtonTitles:nil tapBlock:nil];
    } else {
        [self.cloverGoInstance doTransactionWithKeyedRequest:request];
        [self initSpinnerWithmessage:@"Processing Transaction..." details:@"Please wait..."];
    }
}

- (void)cancelCurrentEMVTransaction{
    if(self.readerConnected){
        [self.cloverGoInstance abortTransaction];
    }
}


#pragma CardReaderDelegate

- (void)onReaderReset {
    
    if (self.alertController) {

        [self.alertController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)onReaderConnected // on reader plugged into audio jack
{
    [KVNProgress dismiss];
    [self audioDeviceConnected];
}

- (void)onReaderReady // reader is ready to take transaction
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [KVNProgress dismiss];
    self.readerConnected = YES;
    self.updateReader = NO;
    [self readerConnectedOnScreen];
}

- (void)onReaderDisconnected // reader is disconected
{
    [KVNProgress dismiss];
    self.readerConnected = NO;
    if (!self.updateReader) {
        [self readerDisconnectedOnScreen];
    }
}

- (void)onReaderResetProgress:(CloverGoReaderResetProgress*)progress // will return the % complete for the reader reset
{

    if (self.alertController && progress.statusCode == CloverGoCardReaderResetStatusCodeInitializationFailed) {
            [self.alertController dismissViewControllerAnimated:YES completion:^{
                self.alertController = [UIAlertController showAlertInViewController:self withTitle:@"Reader Reset Failed" message:progress.message otherButtonTitles:nil tapBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                    }];
                 }];

    }else if (self.alertController && progress.progress == 100){
            self.updateReader = YES;
            [self.alertController dismissViewControllerAnimated:YES completion:^{
                self.alertController = [UIAlertController showSpinnerAlertInViewController:self withTitle:@"Finishing update" message:@""];
            }];
    } else {

        self.alertController = [UIAlertController showSpinnerAlertInViewController:self withTitle:[NSString stringWithFormat:@"Progress - %d %%",progress.progress] message:progress.message];
    }
    
}

- (void)onSelectAidFromList:(NSArray *)arrayOfAID // the array returned has objects of class - CloverGoEMVApplicationIdentifier
                 completion:(void (^)(CloverGoEMVApplicationIdentifier* aid))completion // return the aid selected by user
{
    
    [self removeSpinner];
    
    NSMutableArray* buttonTitles = [[NSMutableArray alloc] init];
    
    for (CloverGoEMVApplicationIdentifier* identifier in arrayOfAID) {
        [buttonTitles addObject:identifier.label];
    }

    [UIAlertController showActionSheetInViewController:self withTitle:@"Please choose / confirm card" message:@"" buttonTitles:buttonTitles tapBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        
        if (action.style == UIAlertActionStyleCancel) {
            completion(nil);
        } else {
            completion(arrayOfAID[buttonIndex - UIAlertControllerOtherButtonIndex]);
        }
        
    }];
}

-(void) onSelectReaderFromList:(NSArray *)arrayOfReaders completion:(void (^)(CloverGoCardReaderInfo *))completion {
        [self removeSpinner];
    
    if ([arrayOfReaders count] >0) {
        NSMutableArray* buttonTitles = [[NSMutableArray alloc] init];
    
        for (CloverGoCardReaderInfo* readerInfo in arrayOfReaders) {
            [buttonTitles addObject:readerInfo.label];
        }
    
        [UIAlertController showActionSheetInViewController:self withTitle:@"Please choose Reader" message:@"" buttonTitles:buttonTitles tapBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
    
            if (action.style == UIAlertActionStyleCancel) {
                completion(nil);
            } else {
                completion(arrayOfReaders[buttonIndex - UIAlertControllerOtherButtonIndex]);
            }
            
        }];
    } else {
        [UIAlertController showActionSheetInViewController:self withTitle:@"No Devices Found" message:@"" buttonTitles:nil tapBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
            NSLog(@"Do nothing..");
        }];
    }

}

- (void)onCardReadProgress:(CloverGoCardReaderEvent*)event // transaction progress messages
{
    [self initSpinnerWithmessage:event.message details:event.detailMessage];
    [KVNProgress showCancelButton:event.showCancelButton];

    
}

- (void)onCardReaderError:(CloverGoCardReaderEvent*)event // transaction stopped due to reader errors
{
    NSLog(@"Reader error occured - Transaction Aborted");
    [self removeSpinner];
    self.alertController = [UIAlertController showAlertInViewController:self withTitle:event.message message:event.detailMessage otherButtonTitles:nil tapBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        NSLog(@"Do nothing!");
    }];

    
}

- (void)onTransactionAbort // when transaction is cancelled by user - this delegate is returned once that request is processed by reader
{
    [self removeSpinner];

    NSLog(@"Transaction Aborted");
    self.alertController = [UIAlertController showAlertInViewController:self withTitle:@"Transaction Status" message:@"Cancelled" otherButtonTitles:nil tapBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        NSLog(@"Do nothing !");
    }];

    
}

#pragma TransactionDelegate

- (void)onSuccess:(CloverGoTransactionResponse*)response // transaction returned successful response
{
    NSLog(@"Transaction Success- transaction ID %@",response.transactionID);
    NSLog(@"Card Type - %@",response.cardType);
    NSLog(@"CVM Result - %@",response.cvmResult);
    NSLog(@"Entry Type - %@", response.entryType);
    NSLog(@"Auth Code - %@", response.authCode);
    NSLog(@"AID - %@", response.aid);
    NSLog(@"Receipt URL - %@", [[CloverGo sharedInstance] receiptURL:response.orderId]);
    [self removeSpinner];
    
    self.transactionResponse = response;
    
    [self performSegueWithIdentifier:@"signatureScreen" sender:self];

    
    /*self.alertController = [UIAlertController showAlertInViewController:self withTitle:@"Transaction success" message:@"Take Signature" otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        NSLog(@"Take signature now !");
    
        
     
    }];
     
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"signatureScreen"])
    {
        SignatureViewController *controller = (SignatureViewController *)segue.destinationViewController;
        controller.transactionID = self.transactionResponse.transactionID;
        controller.orderID = self.transactionResponse.orderId;
    }
}


- (void)onFailure:(CloverGoTransactionError*)error // transaction failed - error returned from backend
{
    NSLog(@"Transaction Failed %@",error.errorMessage);
    [self removeSpinner];
    self.alertController = [UIAlertController showAlertInViewController:self withTitle:@"Transaction Failed" message:error.errorMessage otherButtonTitles:nil tapBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        NSLog(@"Do nothing !");
    }];
}

- (void)proceedOnError:(CloverGoTransactionEvent*)error   // if transaction is failed due to AVS check or Duplicate transaction
            completion:(void (^)(BOOL proceed))completion // return the BOOL to either proceed or not with the transaction
{
    if(error.eventType == CloverGoTransactionEventTypeDuplicateTransaction){
        [self removeSpinner];
        [UIAlertController showAlertInViewController:self withTitle:@"Duplicate Transaction" message:error.message otherButtonTitles:@[@"proceed"] tapBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
            if (buttonIndex != UIAlertControllerCancelButtonIndex) {
                [self initSpinnerWithmessage:@"Processing Transaction..." details:@"Please Wait..."];
                completion(YES);
            } else {
                completion(NO);
            }
        }];
    } else {
        // on AVS failure
        completion(YES);
    }
}


- (void)readerConnectedOnScreen{
    
    [self removeSpinner];
    
    NSLog(@"Current Reader Serial No:%@",[[[CloverGoCardReaderInfo sharedInstance] getReaderInfoObject] serialNo]);
    
    CloverGoCardReaderInfo *readerInfo = [CloverGo getReaderInfo];
    NSString * const ReaderType_toString[] = {
        [CloverGoCardReaderType350] = @"350",
        [CloverGoCardReaderType450] = @"450"
    };
    /*
    NSString *message = [[@"Serial No - " stringByAppendingString:[[readerInfo getReaderInfoObject] serialNo]] stringByAppendingString:@"\n"];
    message = [message stringByAppendingString:[[@"Reader Type - " stringByAppendingString:ReaderType_toString[[[readerInfo getReaderInfoObject] readerType]]] stringByAppendingString:@"\n"]];
    message = [message stringByAppendingString:[[@"Battery % - " stringByAppendingString:[NSString stringWithFormat:@"%li", (long)[[readerInfo getReaderInfoObject] batteryPercentage]]] stringByAppendingString:@"\n"]];
    [UIAlertController showAlertInViewController:self withTitle:@"Device Info" message:message otherButtonTitles:nil tapBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
        NSLog(@"Do Nothing");
    }];
     */

}


- (void)readerDisconnectedOnScreen{
    
    if (self.alertController) {
        [self.alertController dismissViewControllerAnimated:YES completion:^{
            self.alertController = [UIAlertController showAlertInViewController:self withTitle:@"Card Reader Disconnected" message:@"Connect Reader to take payments" otherButtonTitles:nil tapBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                NSLog(@"Do Nothing");
            }];
        }];
    }
}
- (void)readerErrorOnScreen{
    
    if (self.alertController) {
        [self.alertController dismissViewControllerAnimated:YES completion:^{
            self.alertController = [UIAlertController showAlertInViewController:self withTitle:@"Card Reader Error" message:@"Unable to detect card reader - please check microphone settings" otherButtonTitles:nil tapBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                NSLog(@"Do Nothing");
            }];
        }];
    }
    
}


- (void)removeSpinner{
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress dismiss];
    });
}

- (void)performEMVTransactionUsingReader
{
    [self removeSpinner];
    /*
     *      For EMV Transaction - amount is final and hence shall pennies(subtotal + tax) with tip
     */
    
    
    CloverGoTransactionRequest* request = [CloverGoTransactionRequest requestWithAmount:[[self getProperAmount:self.amountTextField]decimalNumberByAdding:[self getProperAmount:self.taxTextField]]  tax:[self getProperAmount:self.taxTextField] tip:[self getProperAmount:self.tipTextField] externalPaymentId:@"abcd" orderItems:self.orderItems];
    [[CloverGo sharedInstance] doTransaction:request];
    
}

@end
