//
//  UIAlertController+CustomUIAlertController.h
//  MVP1.0.1
//
//  Created by Raghu Vamsi on 11/6/15.
//  Copyright © 2015 FirstData. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AlertControllerCompletionBlock) (UIAlertAction * __nonnull action, NSInteger buttonIndex);

static NSInteger const UIAlertControllerCancelButtonIndex = 0; // this is default index for cancel button
static NSInteger const UIAlertControllerDestructiveButtonIndex = 1; // this is default index for destructive button

static NSInteger const UIAlertControllerOtherButtonIndex = 2;// this is default index for other buttons added to the UIAlertController - so we don't have to deal much with getting the button clicked index



@interface UIAlertController (CustomUIAlertController)

+ (nonnull instancetype)showInViewController:(nonnull UIViewController *)viewController
                                   withTitle:(nullable NSString *)title
                                     message:(nullable NSString *)message
                              preferredStyle:(UIAlertControllerStyle)preferredStyle
                           buttonTitles:(nullable NSArray *)buttonTitles
                                    tapBlock:(nullable AlertControllerCompletionBlock)tapBlock;

+ (nonnull instancetype)showAlertInViewController:(nonnull UIViewController *)viewController
                                        withTitle:(nullable NSString *)title
                                          message:(nullable NSString *)message
                                otherButtonTitles:(nullable NSArray *)buttonTitles
                                         tapBlock:(nullable AlertControllerCompletionBlock)tapBlock;

+ (nonnull instancetype)showActionSheetInViewController:(nonnull UIViewController *)viewController
                                              withTitle:(nullable NSString *)title
                                                message:(nullable NSString *)message
                                      buttonTitles:(nullable NSArray *)buttonTitles
                                               tapBlock:(nullable AlertControllerCompletionBlock)tapBlock;

+ (nonnull instancetype)showSpinnerAlertInViewController:(nonnull UIViewController *)viewController
                                        withTitle:(nullable NSString *)title
                                          message:(nullable NSString *)message;


//+ (NSInteger)cancelButtonIndex;
//
//+ (NSInteger)otherButtonIndex;

@property (readonly, nonatomic) BOOL visible;

@end
