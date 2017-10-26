//
//  FLPayPaylKit.m
//  iFlynax
//
//  Created by Alex on 11/4/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLPayPaylKit.h"

@interface FLPayPaylKit () <PayPalPaymentDelegate> {
    FLBuyOrderItemCompletionHandler _buyOrderItemCompletionHandler;
    PayPalConfiguration *_configuration;
}
@end

@implementation FLPayPaylKit

+ (instancetype)sharedManager {
    static FLPayPaylKit *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[super alloc] init];
        [_sharedManager configure];
    });
    return _sharedManager;
}

- (void)configure {
    _configuration = [[PayPalConfiguration alloc] init];
    _configuration.acceptCreditCards = [FLConfig boolWithKey:@"paypal_accept_credit_cards"];
    _configuration.payPalShippingAddressOption = PayPalShippingAddressOptionNone;

    // Start out working with the test environment! When you are ready, switch to PayPalEnvironmentProduction.
    NSString *environment = [FLConfig boolWithKey:@"paypal_sandbox"]
    ? PayPalEnvironmentSandbox
    : PayPalEnvironmentProduction;

    [PayPalMobile preconnectWithEnvironment:environment];
}

+ (void)buyOrderItem:(FLOrderModel *)item completionHandler:(FLBuyOrderItemCompletionHandler)completion {
    [[FLPayPaylKit sharedManager] buyOrderItem:item completionHandler:completion];
}

- (void)buyOrderItem:(FLOrderModel *)item completionHandler:(FLBuyOrderItemCompletionHandler)completion {
    _buyOrderItemCompletionHandler = [completion copy];

    // Create a PayPalPayment
    PayPalPayment *payment = [[PayPalPayment alloc] init];

    // Amount, currency, and description
    payment.amount = [NSDecimalNumber decimalNumberWithString:F(@"%.2f", item.plan.price)];
    payment.currencyCode = item.plan.currencyCode;
    payment.shortDescription = F(@"%@ (#%@)", item.plan.title, @(item.plan.pId));
    payment.intent = PayPalPaymentIntentSale;

    // Check whether payment is processable.
    if (!payment.processable) {
        // If, for example, the amount was negative or the shortDescription was empty, then
        // this payment would not be processable. You would want to handle that here.
    }
    else {
        PayPalPaymentViewController *paymentViewController =
        [[PayPalPaymentViewController alloc] initWithPayment:payment
                                               configuration:_configuration
                                                    delegate:self];

        [self.parentController presentViewController:paymentViewController
                                            animated:YES completion:nil];
    }
}

#pragma mark - PayPalPaymentDelegate methods

-(void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController
               willCompletePayment:(PayPalPayment *)completedPayment
                   completionBlock:(PayPalPaymentDelegateCompletionBlock)completionBlock {

    NSString *receipt = completedPayment.confirmation[@"response"][@"id"];
    _buyOrderItemCompletionHandler(receipt, completionBlock);
}

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController
                 didCompletePayment:(PayPalPayment *)completedPayment {

    [self.parentController dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    [self.parentController dismissViewControllerAnimated:YES completion:^{
        [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"payment_canceledByUser")];
    }];
}

@end
