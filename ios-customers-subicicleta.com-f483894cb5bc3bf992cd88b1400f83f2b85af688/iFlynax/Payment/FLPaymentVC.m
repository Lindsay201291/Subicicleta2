//
//  FLPaymentVC.m
//  iFlynax
//
//  Created by Alex on 10/28/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLPaymentHelper.h"
#import "FLPlansManager.h"
#import "FLPaymentVC.h"
// Gateways
#import "FLPayPaylKit.h"
#import "FLStoreKit.h"

@interface FLPaymentVC ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *orderTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderPriceLabel;
// payment buttons
@property (weak, nonatomic) IBOutlet UIButton *inAppPurchaseBtn;
@property (weak, nonatomic) IBOutlet UIButton *paypalBtn;
// contraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inAppTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *payPalTopConstraint;
@end

@implementation FLPaymentVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = FLLocalizedString(@"screen_purchase");
    [_cancelBtn setTitle:FLLocalizedString(@"button_cancel")];
    self.view.backgroundColor = FLHexColor(kColorBackgroundColor);
    _orderTitleLabel.textColor = FLHexColor(@"666666");
    _orderPriceLabel.textColor = FLHexColor(@"b66b00");

    [_inAppPurchaseBtn setTitle:FLLocalizedString(@"order_pay_by_apple") forState:UIControlStateNormal];
    [_paypalBtn setTitle:FLLocalizedString(@"order_pay_by_paypal") forState:UIControlStateNormal];

    _orderTitleLabel.text = _orderInfo.orderTitle;

    NSNumberFormatter *formatter = [_orderInfo.plan priceFormatter];
    _orderPriceLabel.text = [formatter stringFromNumber:@(_orderInfo.plan.price)];

    if (![FLPaymentHelper inAppPurchasesIsAvailable]) {
        _inAppPurchaseBtn.hidden = YES;
        _inAppPurchaseBtn.enabled = NO;
        _payPalTopConstraint.constant = _inAppTopConstraint.constant;
    }

    if (![FLPaymentHelper payPalIsConfigured]) {
        _paypalBtn.hidden = YES;
        _paypalBtn.enabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    self.screenName = _orderInfo.gaTitle;
    [super viewDidAppear:animated];
}

- (void)validateReceipt:(NSString *)receipt {
    [self validateReceipt:receipt paypalCompletion:nil];
}

- (void)validateReceipt:(NSString *)receipt paypalCompletion:(PayPalPaymentDelegateCompletionBlock)ppCompletion {
    [FLPaymentHelper validateReceipt:receipt
                              append:_orderInfo.toDictionary
                          completion:^(BOOL isValid) {
                              if (isValid) {
                                  [self dismissViewControllerAnimated:YES completion:self.completionBlock];
                              }
                              else {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                                  message:FLLocalizedString(@"payment_receipt_server_failed") delegate:nil
                                                                        cancelButtonTitle:nil otherButtonTitles:FLLocalizedString(@"button_ok"), nil];
                                  [alert show];
                              }

                              // trigger for PayPal NC
                              if (ppCompletion != nil) {
                                  ppCompletion();
                              }
                          }];
}

#pragma mark - Navigation

- (IBAction)paymentBtnDidTap:(UIButton *)sender {
    if (sender == _inAppPurchaseBtn) {
        SKProduct *product = [FLPlansManager sharedManager].skProducts[_orderInfo.plan.inAppKey];

        if (product == nil) {
            [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"inAppPurchase_invalid_product_identifier")];
            return;
        }

        [FLStoreKit buyProduct:product completionHandler:^(BOOL success, NSString *receipt) {
            if (success) {
                [FLProgressHUD showWithStatus:FLLocalizedString(@"processing")];
                _orderInfo.gateway = @"apple";
                [self validateReceipt:receipt];
            }
        }];
    }
    else if (sender == _paypalBtn) {
        [FLPayPaylKit sharedManager].parentController = self;
        [FLPayPaylKit buyOrderItem:_orderInfo completionHandler:^(NSString *receipt, PayPalPaymentDelegateCompletionBlock ppCompletion) {
            _orderInfo.gateway = @"paypal_ios";
            [self validateReceipt:receipt paypalCompletion:ppCompletion];
        }];
    }
}

- (IBAction)cancelBtnDidTap:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
