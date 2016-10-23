//
//  UIAlertController+CustomUIAlertController.m
//  MVP1.0.1
//
//  Created by Raghu Vamsi on 11/6/15.
//  Copyright © 2015 FirstData. All rights reserved.
//

#import "UIAlertController+CustomUIAlertController.h"


@implementation UIAlertController (CustomUIAlertController)

+ (nonnull instancetype)showInViewController:(nonnull UIViewController *)viewController
                                   withTitle:(nullable NSString *)title
                                     message:(nullable NSString *)message
                              preferredStyle:(UIAlertControllerStyle)preferredStyle
                                buttonTitles:(nullable NSArray *)buttonTitles
                                    tapBlock:(nullable AlertControllerCompletionBlock)tapBlock {
    
    UIAlertController *alertController = [self alertControllerWithTitle:title
                                                                message:message
                                                         preferredStyle:preferredStyle];
    
    if (buttonTitles && ([buttonTitles count]>0)) {
        for (NSUInteger i = 0; i < buttonTitles.count; i++) {
            NSString *otherButtonTitle = buttonTitles[i];
            
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action){
                                                                    if (tapBlock) {
                                                                        tapBlock(action, UIAlertControllerOtherButtonIndex + i);
                                                                    }
                                                                }];
            [alertController addAction:otherAction];
        }
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        /*
         *  For iPad we need to set the source view for popoverPresentationController else it will crash
         *  this is the center of the screen currently but it can be any point in the view
         */
        
        alertController.popoverPresentationController.sourceView = viewController.view;
        
        alertController.popoverPresentationController.sourceRect = CGRectMake(viewController.view.bounds.size.width / 2.0 - (viewController.view.bounds.size.width / 4.0), viewController.view.bounds.size.height / 2.0, 1.0, 1.0);
        
        [alertController setModalPresentationStyle:UIModalPresentationFormSheet];
        
        // set cancel button for iPad - normally for UIAlertActionStyleCancel - it is not visible on iPad
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action){
                                                                 if (tapBlock) {
                                                                     tapBlock(action, UIAlertControllerCancelButtonIndex + [buttonTitles count]);
                                                                 }
                                                             }];
        [alertController addAction:cancelAction];
        
    } else {
        // set cancel button
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action){
                                                                 if (tapBlock) {
                                                                     tapBlock(action, UIAlertControllerCancelButtonIndex);
                                                                 }
                                                             }];
        [alertController addAction:cancelAction];
        
    }
    
    [viewController presentViewController:alertController animated:YES completion:nil];
    
    
    return alertController;
    
}

+ (nonnull instancetype)showAlertInViewController:(nonnull UIViewController *)viewController
                                        withTitle:(nullable NSString *)title
                                          message:(nullable NSString *)message
                                otherButtonTitles:(nullable NSArray *)buttonTitles
                                         tapBlock:(nullable AlertControllerCompletionBlock)tapBlock{
    
    return [self showInViewController:viewController withTitle:title message:message preferredStyle:UIAlertControllerStyleAlert buttonTitles:buttonTitles tapBlock:tapBlock];
}

+ (nonnull instancetype)showActionSheetInViewController:(nonnull UIViewController *)viewController
                                              withTitle:(nullable NSString *)title
                                                message:(nullable NSString *)message
                                           buttonTitles:(nullable NSArray *)buttonTitles
                                               tapBlock:(nullable AlertControllerCompletionBlock)tapBlock{
    
    return [self showInViewController:viewController withTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet buttonTitles:buttonTitles tapBlock:tapBlock];
    
}


+ (nonnull instancetype)showSpinnerAlertInViewController:(nonnull UIViewController *)viewController
                                               withTitle:(nullable NSString *)title
                                                 message:(nullable NSString *)message{
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:title message:[NSString stringWithFormat:@"%@\n\n\n",message] preferredStyle:UIAlertControllerStyleAlert];
    
    UIActivityIndicatorView *loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loader.center = CGPointMake(130.5, 105.5);
    loader.color = [UIColor blackColor];
    [loader startAnimating];
    [controller.view addSubview:loader];
    [viewController presentViewController:controller animated:NO completion:nil];
    return controller;
}

- (BOOL)visible
{
    return self.view.superview != nil;
}

@end
