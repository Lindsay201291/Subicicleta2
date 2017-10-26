//
//  FLMenuItemCell.h
//  iFlynax
//
//  Created by Alex on 4/25/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBadgedCell.h"

@interface FLMenuItemCell : TDBadgedCell

@property (weak, nonatomic) IBOutlet UIView *selectorView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, getter=hasBottomSeparator) BOOL bottomSeparator;

- (void)setBadgeInteger:(NSInteger)badgeInteger;
@end
