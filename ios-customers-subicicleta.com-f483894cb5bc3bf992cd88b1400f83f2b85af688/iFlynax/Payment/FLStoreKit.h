//
//  FLStoreKit.h
//  iFlynax
//
//  Created by Alex on 11/4/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import <StoreKit/StoreKit.h>

typedef void (^FLBuyProductCompletionHandler)(BOOL success, NSString *receipt);

@interface FLStoreKit : NSObject

+ (instancetype)sharedManager;

+ (void)buyProduct:(SKProduct *)product completionHandler:(FLBuyProductCompletionHandler)completion;
@end
