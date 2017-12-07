//
//  FLEditProfileRegisterView.h
//  iFlynax
//
//  Created by MAC on 11/28/17.
//  Copyright © 2017 Flynax. All rights reserved.
//

#import "FLViewController.h"

@interface FLEditProfileRegisterView : FLViewController

@property (copy) dispatch_block_t completionBlock;
@property (nonatomic, assign) NSString * regType;
@property (nonatomic, assign) NSString * regMail;
@property (nonatomic, assign) NSString * regNick;

@end
