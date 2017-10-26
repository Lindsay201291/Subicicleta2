//
//  FLPayPaylKit.h
//  iFlynax
//
//  Created by Alex on 11/4/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLOrderModel.h"
#import "PayPalMobile.h"

typedef void (^FLBuyOrderItemCompletionHandler)(NSString *receipt, PayPalPaymentDelegateCompletionBlock paypalCompletion);

@interface FLPayPaylKit : NSObject
@property (nonatomic, strong) UIViewController *parentController;

+ (instancetype)sharedManager;

+ (void)buyOrderItem:(FLOrderModel *)item completionHandler:(FLBuyOrderItemCompletionHandler)completion;
@end
