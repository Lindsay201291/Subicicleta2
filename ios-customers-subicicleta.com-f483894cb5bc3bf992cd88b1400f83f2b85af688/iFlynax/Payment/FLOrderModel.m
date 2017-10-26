//
//  FLOrderItem.m
//  iFlynax
//
//  Created by Alex on 11/4/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLOrderModel.h"

@implementation FLOrderModel

+ (instancetype)withItem:(FLOrderItem)item {
    FLOrderModel *_model = [[FLOrderModel alloc] init];
    if (_model) {
        _model.item = item;
    }
    return _model;
}

- (NSString *)itemString {
    switch (_item) {
        case FLOrderItemListing:
            return @"listing";
        case FLOrderItemPackage:
            return @"package";
        case FLOrderItemFeatured:
            return @"featured";
    }
    return @"";
}

- (NSString *)orderTitle {
    return F(@"%@ (#%lu)", _plan.title, (long)_plan.pId);
}

- (NSString *)gaTitle {
    return F(@"Order Screen: [T:%@|L#%lu, P#%lu]", self.itemString, (long)_itemId, (long)_plan.pId);
}

- (NSDictionary *)toDictionary {
    return @{@"payment_item"      : self.itemString,
             @"payment_title"     : self.orderTitle,
             @"payment_plan"      : @(_plan.pId),
             @"payment_id"        : @(_itemId),
             @"payment_gateway"   : _gateway,
             @"plan_mode_featured": @(_plan.advancedMode && _plan.planMode == FLPlanModeFeatured),
             // Pay info
             @"payment_amount"        : @(_plan.price),
             @"payment_currencyCode"  : _plan.currencyCode,
             @"payment_currencySymbol": _plan.currencySymbol};
}

@end
