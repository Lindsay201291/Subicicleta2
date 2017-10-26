//
//  FLKeywordSearchCell.m
//  iFlynax
//
//  Created by Alex on 12/11/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLKeywordSearchCell.h"

static NSString * const kLabelTextColorStateNormal      = @"ffffff";
static NSString * const kLabelTextColorStateHighlighted = @"555555";

@implementation FLKeywordSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = FLHexColor(kColorMenuBackground);
    self.textLabel.textColor = FLHexColor(kLabelTextColorStateNormal);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    self.textLabel.textColor = FLHexColor(highlighted
                                          ? kLabelTextColorStateHighlighted
                                          : kLabelTextColorStateNormal);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {}

@end
