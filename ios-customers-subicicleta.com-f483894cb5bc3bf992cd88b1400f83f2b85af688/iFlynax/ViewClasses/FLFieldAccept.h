//
//  FLFieldAccept.h
//  iFlynax
//
//  Created by Alex on 10/13/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLTableViewItem.h"

@interface FLFieldAccept : FLTableViewItem
@property (strong, nonatomic) UIViewController *parentVC;
@property (assign, nonatomic) BOOL errorTrigger;
@property (assign, nonatomic) BOOL value;

+ (instancetype)fromModel:(FLFieldModel *)model parentVC:(UIViewController *)parentVC;
+ (NSString *)agreeFieldRequiredMessage:(NSString *)fieldName;

- (BOOL)isAccepted;
@end
