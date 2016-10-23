//
//  SignatureCaptureView.h
//  CloverGoSample
//
//  Created by Rajan Veeramani on 6/6/16.
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloverGo/CloverGo.h>

@protocol SignatureViewDelegate <NSObject>
@optional
- (void)isSignaturePresent:(BOOL)valid;
@end

@interface SignatureCaptureView : UIView

+(NSDictionary*)jsonDescription;

@property (nonatomic, weak) id <SignatureViewDelegate> delegate;

+ (SignatureCaptureView*)sharedInstance;

- (void)erase;

- (void)enableEraseSignatureOnLongPress:(BOOL)enable;

/**
 *  Use the below method to convert signature to CloverGo format, when taking signature
 *  @params
 *  pan & view
 */

- (NSDictionary*)getSignatureForCloverGo:(UIPanGestureRecognizer *)pan
                                  inView:(UIView*)view;

@end
