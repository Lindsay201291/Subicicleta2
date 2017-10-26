//
//  FLPaymentVC.h
//  iFlynax
//
//  Created by Alex on 10/28/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLViewController.h"
#import "FLOrderModel.h"

@interface FLPaymentVC : FLViewController
@property (nonatomic, strong) FLOrderModel *orderInfo;
@property (nonatomic, copy) dispatch_block_t completionBlock;
@end
