//
//  SignatureViewController.m
//  CloverGoSample
//
//  Created by Raghu Vamsi on 2/4/16.
//  Copyright © 2016 First Data Inc. All rights reserved.
//

#import "SignatureViewController.h"
#import <CloverGo/CloverGo.h>
#import <QuartzCore/QuartzCore.h>
#import "KVNProgress.h"
#import "UIAlertController+CustomUIAlertController.h"
#import "SignatureCaptureView.h"

@interface SignatureViewController ()<SignatureViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *signLabel;

@property (strong, nonatomic) SignatureCaptureView *signingBox;

@property (strong, nonatomic) UIButton *doneButton;

@end

@implementation SignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@""
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem=btnBack;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.signLabel.hidden = NO;
    [self setSigningBox];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setSigningBox
{
    
    

    self.signingBox = [[SignatureCaptureView alloc] initWithFrame:CGRectMake(self.signLabel.frame.origin.x, self.signLabel.frame.origin.y+100, self.signLabel.frame.size.width, 250)];
    self.signingBox.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.signingBox.delegate = self;
    
    [self.signingBox enableEraseSignatureOnLongPress:YES];
    
    CGRect frame = self.signingBox.frame;
    
    frame.origin.y = frame.origin.y+frame.size.height+50;
    frame.size.height = 49;
    
    self.doneButton = [[UIButton alloc] initWithFrame:frame];
    
    [self.doneButton addTarget:self action:@selector(doneClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    
    self.doneButton.backgroundColor = [UIColor darkGrayColor];
    
    [self.doneButton setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateNormal];
    
    self.doneButton.layer.cornerRadius = 8;
    self.doneButton.layer.masksToBounds = YES;
    
    self.signingBox.layer.cornerRadius = 8;
    self.signingBox.layer.masksToBounds = YES;
    
    [self.view addSubview:self.signingBox];
    
    [self.view addSubview:self.doneButton];
    
    [self.view bringSubviewToFront:self.signingBox];
    [self.view bringSubviewToFront:self.doneButton];
    
    self.doneButton.hidden = YES;
    self.signingBox.hidden = YES;
    
    
    [self sendReceiptWithEmail:@"harvestmoney2020@nicklupien.com" phone:nil];


}

- (void)doneClicked{
    NSLog(@"Done Button Tapped");
    [KVNProgress showWithStatus:@"Processing"];
    
    [[CloverGo sharedInstance] captureSignatureForTransaction:self.transactionID signatureJSON:[SignatureCaptureView jsonDescription] completion:^(BOOL success, CloverGoTransactionError *error) {
        // take the user to receipt screen
        
        if (success) NSLog(@"Capture - Signature - success"); else NSLog(@"Capture - Signature - success");
                
        self.title = @"Send Receipt";
        
        [self.view.subviews setValue:@YES forKeyPath:@"hidden"];

        [self sendReceipt];
        
    }];
    
}

- (void)sendReceipt {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Send Receipt \nTo"
                                          message:@"email / phone number"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"ra.dummy@xyz.com", @"email");
         [textField addTarget:self
                       action:@selector(alertTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
         
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"555555555", @"phone");
         textField.secureTextEntry = NO;
         
         [textField addTarget:self
                       action:@selector(alertTextFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *email = alertController.textFields.firstObject;
                                   UITextField *phone = alertController.textFields.lastObject;
                                   
                                   [self sendReceiptWithEmail:email.text phone:phone.text];
                               }];
    
    okAction.enabled = NO;
    
    [alertController addAction:okAction];
    
    [KVNProgress dismiss];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

- (BOOL)validateEmailAddress:(NSString*)emailaddress{
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    return [emailTest evaluateWithObject:emailaddress];
}

- (BOOL)validateMobileNumber:(NSString*)phoneNumber{
    
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    if (phoneNumber.length !=10) {
        return NO;
    }else{
        NSString *regexCheckForIntegers = @"^([+-]?)(?:|0|[1-9]\\d*)?$";
        NSPredicate *integerCheckPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexCheckForIntegers];
        return [integerCheckPredicate evaluateWithObject:phoneNumber];
    }
    
}

- (void)sendReceiptWithEmail:(NSString*)email
                       phone:(NSString*)phone
{
    NSString* emailAddress, *phoneNumber;
    
    if ([self validateEmailAddress:email])
        emailAddress = email;
    else
        emailAddress = nil;
    
    
    if ([self validateMobileNumber:phone])
        phoneNumber = phone;
    else
        phoneNumber = nil;
    
    
    if (emailAddress || phoneNumber) {
        [[CloverGo sharedInstance] sendReceipt:self.orderID email:email phoneNumber:phone
                                    completion:^(BOOL success, CloverGoTransactionError *error) {
                                        
                                        [self performSegueWithIdentifier:@"homeScreen" sender:self];
                                        
                                        /*
                                         
                                         
                                        NSString* message = (success)?@"success":[NSString stringWithFormat:@"failed - %@",error.errorMessage];
                                        
                                        

                                        NSLog(@"receipt Sent");
                                            [UIAlertController showAlertInViewController:self withTitle:@"Receipt Sent" message:message otherButtonTitles:nil tapBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
//                                                [self. popViewControllerAnimated:YES];
                                                [self performSegueWithIdentifier:@"homeScreen" sender:self];
                                            }];
                                         
                                         */
                                        
                                    }];
    } else {
        [UIAlertController showAlertInViewController:self withTitle:@"Invalid Email / Phone number" message:@"Please correct it and try again" otherButtonTitles:nil tapBlock:^(UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
            [self sendReceipt];
        }];
    }
    
}


- (void)alertTextFieldDidChange:(UITextField *)sender
{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController)
    {
        UITextField *email = alertController.textFields.firstObject;
        UITextField *phone = alertController.textFields.lastObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = (email.text.length > 2) || (phone.text.length > 2);
    }
}

- (void)isSignaturePresent:(BOOL)valid{
    self.doneButton.hidden = !valid;
}

@end
