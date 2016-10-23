
##Configuring the Sample App

To get the sample app working, set the _merchant_id_, _employee_id_ and _device_id_ that you would have received in the Activation mail in the settings.plist

**_HomeViewController.m_** contains reference implementation on how to initialize the CloverGo SDK

**_ViewController.m_** contains reference implementation on initializing the Card reader and initiating a transaction

**_InventoryTableViewController_** contains reference implementation for fetching the Inventory Items

**_TaxRateTableViewController_** contains reference implementation for fetching the Tax rates applicable for the merchant

**_SignatureViewController_** contains reference implementation for Capturing the signature and sending the receipt of the transcation


##Integrating CloverGo iOS SDK 

###First Steps

Add the **CloverGo.framework** to your project

Add the Dependent frameworks to your project (you can find them under "Dependent Frameworks" folder)

- G4XSwiper.framework
- RPx_BLE.framework
- RUA_BLE.framework

Other iOS Dependent Libraries that needs to linked to your Application

- Foundation.framework
- CoreBluetooth.framework
- MobileCoreServices.framework
- SystemConfiguration.framework
- MediaPlayer.framework
- AudioToolbox.framework
- AVFoundation.framework
- libstdc++.6.tbd

###Additional project setting

In Build Settings under **Target** and set **_Allow Non-modular Includes in Framework Modules_** to **_YES_**.

##Initializing the SDK

```
- (id)initWithEmployeeId:(NSString *)employeeId
              merchantID:(NSString *)merchantId
                deviceId:(NSString *)deviceId
```

Initialization should be done only once and you can get the CloverGo instance rest of the application using 

```
[CloverGo sharedInstance]
```

###Implement the Card Reader Delegate

The view controller that initializes the card reader should implement **_CloverGoCardReaderDelegate_**

Below are the methods that should be implemented by the View Controller that acts as the **_CloverGoCardReaderDelegate_**

```
- (void)onReaderConnected;

- (void)onReaderReady;

- (void)onReaderDisconnected;

- (void)onReaderResetProgress:(CloverGoReaderResetProgress*)progress;

- (void)onSelectAidFromList:(NSArray *)arrayOfAID
                 completion:(void (^)(CloverGoEMVApplicationIdentifier* aid))completion;

- (void)onCardReadProgress:(CloverGoCardReaderEvent*)event;

- (void)onCardReaderError:(CloverGoCardReaderEvent*)event;

- (void)onSelectReaderFromList:(NSArray *)arrayOfReaders
                 completion:(void (^)(CloverGoCardReaderInfo* cardReader))completion;

@optional
- (void)onTransactionAbort;
```

Set the cardReaderDelegate variable in the cloverGoInstance with the ViewController that implements the **_CloverGoCardReaderDelegate_**

```
_cloverGoInstance.cardReaderDelegate = self;
```

###Initialize the Card Reader
```
[[CloverGo sharedInstance] initCardReader:CloverGoCardReaderType450 shouldAutoReset:YES]
```

CloverGo will start scanning for Bluetooth readers and send the available reader list to the callback method **_onSelectReaderFromList_** in the **_CloverGoCardReaderDelegate_**. 
App needs to choose the reader it needs to connect with by calling the completion block and that will start initializing the reader.
Reader events will be sent to **_CloverGoCardReaderDelegate_** 

###Implement the Transaction Delegate

The View Controller that handles the payment transaction processing should implement **_CloverGoTransactionDelegate_**

Below are the methods that should be implemented by the View Controller that acts as the **_CloverGoTransactionDelegate_**

```
- (void)onSuccess:(CloverGoTransactionResponse*)response;

- (void)onFailure:(CloverGoTransactionError*)error;

- (void)proceedOnError:(CloverGoTransactionEvent*)error
            completion:(void (^)(BOOL proceed))completion;
```

Set the transactionDelegate variable in the cloverGoInstance with the View Controller that implements the **_CloverGoTransactionDelegate_**

```
_cloverGoInstance.transactionDelegate = self;
```

###Initiate a Transaction

Once the reader is initialized, the status of the reader can be verified using **_isCardReaderReady_** method

```
[[CloverGo sharedInstance] isCardReaderReady]
```

Create the **_CloverGoTransactionRequest_** with the following method, please note all amounts are in pennies

```
+ (instancetype) requestWithAmount:(NSDecimalNumber*)subTotal
                               tax:(NSDecimalNumber*)tax
                               tip:(NSDecimalNumber*)tip
                 externalPaymentId:(NSString*)externalPaymentId
                         orderItems:(NSArray*)orderItems;
```

Call the **_doTransaction_** method in CloverGo instance to initiate the transaction

```
[[CloverGo sharedInstance] doTransaction:request];
```

Once a sucessful transaction is complete, the response **_CloverGoTransactionResponse_** will be sent to the **_CloverGoTransactionDelegate_** method **_onSuccess_**

**_CloverGoTransactionResponse_** returns the following values
```
@property (nonatomic, readonly)	NSString*           orderId;
@property (nonatomic, readonly)	NSString*           transactionID;
@property (nonatomic, readonly)	NSDecimalNumber*    amountCharged;// includes tax and tip if any
@property (nonatomic, readonly)	NSString*           cardType;
@property (nonatomic, readonly)	NSString*           cardLast4Digits;
@property (nonatomic, readonly)	NSString*           cardholderName;
@property (nonatomic, readonly) NSString*           externalPaymentId;
@property (nonatomic, readonly) NSString*           cvmResult;
@property (nonatomic, readonly) NSString*           entryType;
@property (nonatomic, readonly) NSString*           authCode;
@property (nonatomic, readonly) NSString*           aid;
```

If the transaction fails the error response will be sent to  **_onFailure_** of **_CloverGoTransactionDelegate_**

**_CloverGoTransactionError_** return ths following response

```
@property (nonatomic, readonly)	NSString*           errorCode;
@property (nonatomic, readonly)	NSString*           errorMessage;
```

###Additional Transactional properties

Additional transactional properties can be set on the CloverGo instance 
- Allow Duplicate Transactions
- Ignore AVS Check

```
[[CloverGo sharedInstance] allowDuplicateTransactions:YES];
[[CloverGo sharedInstance] ignoreAVSCheck:YES];
```

###Get Inventory

The View Controller that handles the inventory items should implement **_CloverGoInventoryDelegate_**

Below are the methods that should be implemented by the View Controller that acts as the **_CloverGoInventoryDelegate_**

```
-(void) getInventoryItemsSuccess:(NSArray*) inventoryItems;

-(void) getInventoryItemsFailure:(NSError*) error;
```

To get an array of **_CloverGoInventoryItem_** call the **_getInventoryItems_** method

```
[[CloverGo sharedInstance] getInventoryItems];
```

###Get Tax Rates

The View Controller that handles the Tax Rates should implement **_CloverGoTaxRateDelegate_**

Below are the methods that should be implemented by the View Controller that acts as the **_CloverGoTaxRateDelegate_**

```
-(void) getTaxRatesSuccess:(NSArray*) taxRates;

-(void) getTaxRatesFailure:(NSError*) error;
```

To get an array of **_CloverGoTaxRate_** call the **_getTaxRates_** method

```
[[CloverGo sharedInstance] getTaxRates];
```

###Enabling Debug Mode

To enable CloverGo SDK’s debug logs to be printed on the console, call the **_setDebugMode_** method with a **_YES_** Boolean parameter

```
[[CloverGo sharedInstance] setDebugMode:YES];
```
