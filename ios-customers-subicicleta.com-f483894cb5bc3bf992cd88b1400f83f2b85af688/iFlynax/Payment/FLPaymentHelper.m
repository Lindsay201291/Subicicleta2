//
//  FLStoreManager.m
//  iFlynax
//
//  Created by Alex on 10/28/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "FLPaymentHelper.h"
#import "FLPlansManager.h"
#import "FLPlanModel.h"

static BOOL const kDebugValidationListingPlans = NO;

@interface FLPaymentHelper () <SKProductsRequestDelegate>
@property (nonatomic, copy) FLStoreCompletionBlock validateProductsCompletion;
@property (nonatomic, strong) NSMutableArray<FLPlanModel *> *plans;
@end

@implementation FLPaymentHelper

+ (instancetype)sharedInstance {
    static FLPaymentHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

+ (BOOL)requiredToValidateListingPlans {
    return [[FLPaymentHelper sharedInstance] requiredToValidateListingPlans];
}

+ (BOOL)inAppPurchasesIsAvailable {
    return [[FLPaymentHelper sharedInstance] inAppPurchasesIsAvailable];
}

+ (BOOL)payPalIsConfigured {
    return [[FLPaymentHelper sharedInstance] payPalIsConfigured];
}

+ (BOOL)canMakePayments {
    return [[FLPaymentHelper sharedInstance] canMakePayments];
}

+ (void)validateListingPlans:(NSMutableArray *)listingPlans completion:(FLStoreCompletionBlock)completion {
    [[FLPaymentHelper sharedInstance] validateListingPlans:listingPlans completion:completion];
}

#pragma mark - Private methods

- (BOOL)requiredToValidateListingPlans {
    return (kDebugValidationListingPlans ||
            [self inAppPurchasesIsAvailable]);
}

- (BOOL)inAppPurchasesIsAvailable {
    return (kDebugValidationListingPlans ||
            ([FLConfig boolWithKey:@"inapp_module"] &&
             [SKPaymentQueue canMakePayments]));
}

- (BOOL)payPalIsConfigured {
    return ([FLConfig boolWithKey:@"paypal_module"] &&
            ![[FLConfig stringWithKey:@"paypal_client_id"] isEmpty] &&
            ![[FLConfig stringWithKey:@"paypal_secret"] isEmpty]);
}

- (BOOL)canMakePayments {
    return ([self inAppPurchasesIsAvailable] || [self payPalIsConfigured]);
}

- (void)validateListingPlans:(NSMutableArray *)listingPlans completion:(FLStoreCompletionBlock)completion {
    NSMutableArray *_planKeysTovalidate = [NSMutableArray array];

    for (FLPlanModel *plan in listingPlans) {
        if (plan.paymentIsRequired) {
            [_planKeysTovalidate addObject:plan.inAppKey];
        }
    }

    SKProductsRequest *productsRequest =
    [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:_planKeysTovalidate]];
    productsRequest.delegate = self;
    [productsRequest start];

    self.plans = listingPlans;
    self.validateProductsCompletion = completion;
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSMutableArray *filteredPlans = [NSMutableArray array];

    // plans mapping between Store and API
    for (SKProduct *product in response.products) {
        [[FLPlansManager sharedManager].skProducts setObject:product forKey:product.productIdentifier];
    }

    for (FLPlanModel *plan in self.plans) {
        if (![response.invalidProductIdentifiers containsObject:plan.inAppKey]) {
            if (plan.paymentIsRequired) {
                SKProduct *skProduct = [FLPlansManager sharedManager].skProducts[plan.inAppKey];

                plan.price = skProduct.price.floatValue;
                plan.currencyCode = [skProduct.priceLocale objectForKey:NSLocaleCurrencyCode];

                [filteredPlans addObject:plan];
            }
            else [filteredPlans addObject:plan];
        }
    }

    if (self.validateProductsCompletion) {
        self.validateProductsCompletion(filteredPlans, nil);
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    if (self.validateProductsCompletion) {
        self.validateProductsCompletion(self.plans, error);
    }
}

#pragma mark - Transactions

+ (void)validateReceipt:(NSString *)receipt append:(NSDictionary *)params
             completion:(FLValidateReceiptCompletionBlock)completion
{
    [[FLPaymentHelper sharedInstance] validateReceipt:receipt append:params
                                           completion:completion];
}

- (void)validateReceipt:(NSString *)receipt append:(NSDictionary *)params
             completion:(FLValidateReceiptCompletionBlock)completion
{
    NSMutableDictionary *requestParams =
    [@{@"cmd": kApiItemRequests_validateTransaction,
       @"payment_receipt": FLTrueString(receipt)} mutableCopy];
    [requestParams addEntriesFromDictionary:params];

    [flynaxAPIClient postApiItem:kApiItemRequests
                      parameters:requestParams
                      completion:^(NSDictionary *result, NSError *error) {
                          if (!error && [result isKindOfClass:NSDictionary.class] && FLTrueBool(result[@"success"])) {
                              completion(YES);
                          }
                          else {
                              completion(NO);
                          }
                      }];
}

@end
