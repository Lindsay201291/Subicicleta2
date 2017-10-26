//
//  FLStoreManager.h
//  iFlynax
//
//  Created by Alex on 10/28/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLOrderModel.h"

typedef void (^FLStoreCompletionBlock)(NSMutableArray *validProducts, NSError *error);
typedef void (^FLValidateReceiptCompletionBlock)(BOOL success);

@interface FLPaymentHelper : NSObject

+ (instancetype)sharedInstance;

+ (BOOL)requiredToValidateListingPlans;
+ (BOOL)inAppPurchasesIsAvailable;
+ (BOOL)payPalIsConfigured;
+ (BOOL)canMakePayments;

+ (void)validateListingPlans:(NSMutableArray *)listingPlans completion:(FLStoreCompletionBlock)completion;

+ (void)validateReceipt:(NSString *)receipt append:(NSDictionary *)params
             completion:(FLValidateReceiptCompletionBlock)completion;
@end
