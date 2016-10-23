//
//  CloverGo.h
//  CloverGo
//
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloverGoStatusCode.h"
#import "CloverGoCardReaderEvent.h"
#import "CloverGoEMVApplicationIdentifier.h"
#import "CloverGoTransactionError.h"
#import "CloverGoCardReaderInfo.h"
#import "CloverGoReaderResetProgress.h"
#import "CloverGoKeyedTransactionRequest.h"
#import "CloverGoTransactionResponse.h"
#import "CloverGoTransactionEvent.h"
#import "CloverGoInventoryItem.h"
#import "CloverGoTaxRate.h"
#import "CloverGoOrderItem.h"



/**
 *  CloverGo card reader delegate
 */
@protocol CloverGoCardReaderDelegate <NSObject>

@required

- (void)onReaderConnected; // on reader plugged into audio jack

- (void)onReaderReset;

- (void)onReaderReady; // reader is ready to take transaction

- (void)onReaderDisconnected; // reader is disconected

/**
 *  reader reset progress method
 *
 *  @param progress provides progress in % as well as the step
 */

- (void)onReaderResetProgress:(CloverGoReaderResetProgress*)progress;

/**
 *  select aid from a list of aid's returned
 *
 *  @param arrayOfAID array of aid's of class - CloverGoEMVApplicationIdentifier
 *  @param completion return the selected aid by user
 */

- (void)onSelectAidFromList:(NSArray *)arrayOfAID
                 completion:(void (^)(CloverGoEMVApplicationIdentifier* aid))completion;

/**
 *  card reader progress delegate method
 *  @param event returns the progress of events during card read by clovergo reader
 */

- (void)onCardReadProgress:(CloverGoCardReaderEvent*)event;

- (void)onCardReaderError:(CloverGoCardReaderEvent*)event;

- (void)onSelectReaderFromList:(NSArray *)arrayOfReaders
                 completion:(void (^)(CloverGoCardReaderInfo* cardReader))completion;

@optional
- (void)onTransactionAbort; // when transaction is cancelled by user.

@end


@protocol CloverGoTransactionDelegate <NSObject>

@required

- (void)onSuccess:(CloverGoTransactionResponse*)response;

- (void)onFailure:(CloverGoTransactionError*)error;

- (void)proceedOnError:(CloverGoTransactionEvent*)error
            completion:(void (^)(BOOL proceed))completion; // return the BOOL to either proceed or not with the transaction

@end

@protocol CloverGoAnalyticsInfoDelegate <NSObject>

@optional

// Below method provides info on reader and network error related info for Analytics

-(void)recordEventCategory:(NSString*)category
                   context:(NSString*)context
                    detail:(NSString*)detail;

- (void)updateTrackingId:(NSString*)trackingId;

- (void)timeRecordedForAction:(NSString*)action
                     starting:(NSDate*)startTime
                       ending:(NSDate*)endTime;
@end

@protocol CloverGoInventoryDelegate <NSObject>

-(void) getInventoryItemsSuccess:(NSArray*) inventoryItems;

-(void) getInventoryItemsFailure:(NSError*) error;

@end

@protocol CloverGoTaxRateDelegate <NSObject>

-(void) getTaxRatesSuccess:(NSArray*) taxRates;

-(void) getTaxRatesFailure:(NSError*) error;

@end

@interface CloverGo : NSObject


/*
 *   CloverGo Delegate
 */
@property (nonatomic,assign) id<CloverGoCardReaderDelegate> cardReaderDelegate;

@property (nonatomic,assign) id<CloverGoTransactionDelegate> transactionDelegate;

@property (nonatomic,assign) id<CloverGoAnalyticsInfoDelegate> analyticsDelegate;

@property (nonatomic,assign) id<CloverGoInventoryDelegate> inventoryDelegate;

@property (nonatomic,assign) id<CloverGoTaxRateDelegate> taxRateDelegate;


/**
 *  INIT method takes the below params
 *
 *  @param url
 *      Currently CloverGo Services API has 2 end points
 *      1. Test Env
 *      2. Live Env
 *
 *  @param apiKey    (is different per env) - Contact @ CloverGo Team for Credentials
 *  @param apiSecret (is different per env) - Contact @ CloverGo Team for Credentials
 *
 *  Below init will require developers to go through user activation using the class - # FDCloverActivation
 *  only use the below method if the activation is being done on your own cloud.
 */

+(NSString*)sdkVersion;

// Hackathon Constructor
- (id)initWithEmployeeId:(NSString *)employeeId
              merchantID:(NSString *)merchantId
                deviceId:(NSString *)deviceId;

//Use this method when passing only merchantID and not employeeID and DeviceID.
//- (id)initWithApiKey:(NSString *)apiKey
//           apiSecret:(NSString *)apiSecret
//                 env:(CloverGoEnvironment)env
//          merchantID:(NSString *)merchantId;

//-(id)initWithApiKey:(NSString*)apiKey
//          apiSecret:(NSString*)apiSecret
//                env:(CloverGoEnvironment)env
//           deviceID:(NSString*)deviceId
//         employeeID:(NSString*)employeeId
//         merchantID:(NSString*)merchantId;


/**
 *  CloverGo Shared Instance
 */

+ (CloverGo*)sharedInstance;

/**
 *  Process manually keyed transaction
 */
- (void)doTransactionWithKeyedRequest:(CloverGoKeyedTransactionRequest*)request;

/**
 *  Process card reader transaction
 */
- (void)doTransaction:(CloverGoTransactionRequest*)request;

/**
 *  Abort reader transaction
 */
- (void)abortTransaction;

/**
 *  stop reader transaction
 */
- (void)stopCardReaderTransaction:(void(^)(BOOL success, NSError* error))handler;


/**
 *  Force reset reader
 *  reader reset status updates are via delegate - 
 */
- (void)resetCardReader;


/**
 *  init / release card reader
 *  You would need this if you have to init card reader on applicationWillEnterForeground, applicationDidEnterBackground
 */
/// - (void)initCardReader;

- (BOOL)initCardReader:(CloverGoCardReaderType)readerType shouldAutoReset:(BOOL)shouldAutoReset;

- (void)startDummyTransaction;

- (void)releaseCardReader:(void(^)(BOOL success))completion;

- (BOOL)isCardReaderReady;

/**
 *  Enable debug console statements for the CloverGo Framework
 *  - enabling debug mode will print NSLog Statements from the reader as well.
 *
 *  @param debug type BOOL
 */

- (void)setDebugMode:(BOOL)debug;

/**
 *  Allow duplicate transactions. if YES, then we don't throw the error on proceedOnError delegate.
 *
 *  @param type BOOL
 */

- (void)allowDuplicateTransactions:(BOOL)allow;

/**
 *  ignore avs failure prompts. if YES, then we don't throw the error on proceedOnError delegate
 *
 *  @param type BOOL
 */

- (void)ignoreAVSCheck:(BOOL)ignore;


/**
 *  Enable manual transaction mode if you are not using CloverGo Inventory
 *
 *  @param manualTransaction type BOOL
 */

- (void)setManualTransaction:(BOOL)manualTransaction;


/**
 *  Returns a boolean if debug flag is set or not.
 *
 *  For PROD set it as NO.
 *
 *  @returns debug type BOOL
 */

+(BOOL)debugModeEnabled; // check if reader is in debug mode

/**
 *  Returns a boolean if allow du[plicate transactions flag is set or not.
 *  default value is NO
 *
 *  @returns debug type BOOL
 */
+(BOOL)allowDuplicateTransactions;

/**
 *  Returns a boolean if ignore AVS errors on transactions flag is set or not.
 *  default value is NO
 *
 *  @returns debug type BOOL
 */
+(BOOL)ignoreAVSErrorPrompt;


/**
 * returns the API url and creds required to access CloverGo Services
 */
+(NSDictionary*)apiCreds;

/**
 * returns the creds required for CloverGo Services to make a transaction
 *
 * @params returned
 *  deviceID    -   identifies the devices making transaction - attaches employee and merchant to specific device
 *  merchantID  -   merchant identifier of the account provisioned on Clover.
 *  employeeID  -   employee identifier linked to the account whose merchantID is as above.
 */

+(void)setDeviceID:(NSString*)dID
        employeeID:(NSString*)eID
        merchantID:(NSString*)mID
               env:(CloverGoEnvironment)env;

+(NSString*)getDeviceId;

+(NSString*)getEmployeeId;

+(NSString*)getMerchantId;

+ (CloverGoEnvironment)getEnv;


/**
 *  Get Reader info - Battery %, serial no & type
 */

+(CloverGoCardReaderInfo*)getReaderInfo;

/**
 *  Delete order - will refund all payments for the order
 *  @param
 *  orderID - This is available in CloverGoTransactionResponse class
 */


- (void)voidTransactionWithID:(NSString*)orderId
                   completion:(void (^)(BOOL success, CloverGoTransactionError *error))completion;


/**
 *  Add signature to a transaction / payment
 *  @param
 *  transactionID - This is available in CloverGoTransactionResponse class
 *  SignatureJson - This is available in CloverGoSignatureView class
 */

- (void)captureSignatureForTransaction:(NSString*)transactionId
                    signatureJSON:(NSDictionary*)signature
                       completion:(void (^)(BOOL success, CloverGoTransactionError *error))completion;

/**
 *  Send receipt of transaction / payment
 *  @param
 *  orderId - This is available in CloverGoTransactionResponse class
 *  email - recipient email address
 *  phone - recipient phone number
 */

- (void)sendReceipt:(NSString*)orderId
              email:(NSString*)email
        phoneNumber:(NSString*)phoneNumber
         completion:(void (^)(BOOL success, CloverGoTransactionError *error))completion;


// This method is being used for internal use.
- (void)setEventinfo:(NSString*)cat
             context:(NSString*)con
              detail:(NSString*)det;

- (void)setTrackingId:(NSString*)trackingId;

- (void)setTimeForAction:(NSString*)action
                   start:(NSDate*)startTime
                     end:(NSDate*)endTime;


/**
 *  Get all the Inventory Items configured for the merchant from Clover
 *  Response will be sent to the Callback methods as defined in the CloverGoInventoryDelegate protocol
 */
- (void)getInventoryItems;

/**
 *  Get all the Tax Rates configured for the merchant from Clover
 *  Response will be sent to the Callback methods as defined in the CloverGoTaxRateDelegate protocol
 */
- (void)getTaxRates;

/**
 *  Calculate Total Amount and Total Tax for the Order Items
 *  @param
 *  orderItems - An Array of orderItems(CloverGoOrderItem) added to the cart
 *  amount - Reference to Total amount that will be calculated
 *  tax - Reference to Total tax that will be calculated
 */
-(void)calculateTaxRatesForOrderItems:(NSArray*) orderItems
                          totalAmount:(NSNumber**) amount
                             totalTax:(NSNumber**) tax;

-(NSNumber*)calculateTaxWithAmount:(NSNumber*) amount
                           taxRate:(NSNumber*) taxRate;

-(NSNumber*) getOrderTotalForOrderItems:(NSArray*) orderItems;

-(NSNumber*) getOrderTotalIncludingTaxForOrderItems:(NSArray*) orderItems;

-(NSNumber*) getOrderTotalIncludingTaxAndTipForOrderItems:(NSArray*)orderItems
                                                tipAmount:(NSNumber*)tipAmount;

-(NSNumber*) getOrderTaxForOrderItems:(NSArray*)orderItems;

-(NSString*)receiptURL:(NSString*) orderId;

-(int)buletoothScanInterval;

@end


