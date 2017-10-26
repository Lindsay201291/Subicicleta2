//
//  FLSellerInfoView.h
//  iFlynax
//
//  Created by Alex on 8/21/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLViewController.h"

@class FLMessaging;

@interface FLSellerInfoView : FLViewController
@property (nonatomic, strong) NSDictionary *sellerInfo;

- (FLMessaging *)prepareContactOwnerMessaging;
@end
