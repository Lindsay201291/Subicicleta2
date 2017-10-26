//
//  FLStoreKit.m
//  iFlynax
//
//  Created by Alex on 11/4/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLStoreKit.h"

static NSString * const FLStoreKitProductPurchasedNotification = @"com.flynax.storeKitProductPurchasedNotification";

@interface FLStoreKit () <SKPaymentTransactionObserver> {
    FLBuyProductCompletionHandler _buyProductCompletionHandler;
    SKProductsRequest *_productsRequest;
    NSSet *_productIdentifiers;
}
@end


@implementation FLStoreKit

+ (instancetype)sharedManager {
    static FLStoreKit *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[super alloc] init];

        [[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedManager];
    });
    return _sharedManager;
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark -

+ (void)buyProduct:(SKProduct *)product completionHandler:(FLBuyProductCompletionHandler)completion {
    [[FLStoreKit sharedManager] buyProduct:product completionHandler:completion];
}

- (void)buyProduct:(SKProduct *)product completionHandler:(FLBuyProductCompletionHandler)completion {
    _buyProductCompletionHandler = [completion copy];

    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = 1;

    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;

            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;

            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

    if (_buyProductCompletionHandler) {
        NSURL *receiptURL           = [[NSBundle mainBundle] appStoreReceiptURL];
        NSData *receipt             = [NSData dataWithContentsOfURL:receiptURL];
        NSString *receiptString     = [receipt base64EncodedStringWithOptions:0];

        if (receipt) {
            _buyProductCompletionHandler(YES, receiptString);
        }
        else {
            _buyProductCompletionHandler(NO, nil);
        }
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

    if (transaction.error.code == SKErrorPaymentCancelled) {
        [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"payment_canceledByUser")];
    }
    else [FLProgressHUD showErrorWithStatus:transaction.error.localizedDescription];

    if (_buyProductCompletionHandler) {
        _buyProductCompletionHandler(NO, nil);
    }
}

@end
