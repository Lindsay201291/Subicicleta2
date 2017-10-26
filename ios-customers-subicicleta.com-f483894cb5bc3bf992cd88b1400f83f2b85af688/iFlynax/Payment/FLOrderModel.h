//
//  FLOrderItem.h
//  iFlynax
//
//  Created by Alex on 11/4/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLPlanModel.h"

static NSString * const kOrderFromNotification = @"order";

typedef NS_ENUM(NSInteger, FLOrderItem) {
    FLOrderItemListing,
    FLOrderItemPackage,
    FLOrderItemFeatured
};

@interface FLOrderModel : NSObject
@property (nonatomic, assign) FLOrderItem item;
@property (nonatomic, copy  ) NSString    *itemString;

@property (nonatomic, copy  ) NSString    *orderTitle;
@property (nonatomic, copy  ) NSString    *gaTitle;

@property (nonatomic, assign) NSInteger   itemId;
@property (nonatomic, strong) FLPlanModel *plan;

@property (nonatomic, copy  ) NSString    *gateway;
@property (nonatomic, copy  ) NSString    *receipt;

@property (nonatomic, assign) NSDictionary *toDictionary;

+ (instancetype)withItem:(FLOrderItem)item;

- (NSDictionary *)toDictionary;
@end
