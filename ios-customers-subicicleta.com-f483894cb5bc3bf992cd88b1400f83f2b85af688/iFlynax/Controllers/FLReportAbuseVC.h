//
//  FLReportAbuseVC.h
//  iFlynax
//
//  Created by Alex on 2/13/17.
//  Copyright © 2017 Flynax. All rights reserved.
//

#import "FLViewController.h"
#import "FLNavigationController.h"

@interface FLReportAbuseVC : FLViewController
@property (strong, nonatomic) FLNavigationController *flNavigationController;
@property (strong, nonatomic) dispatch_block_t sendButtonBlock;
@property (assign, nonatomic) NSInteger lId; // Listing ID
@end
