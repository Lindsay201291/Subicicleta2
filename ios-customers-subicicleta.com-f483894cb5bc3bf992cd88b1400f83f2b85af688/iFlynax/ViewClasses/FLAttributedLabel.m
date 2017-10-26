//
//  FLAttributedLabel.m
//  iFlynax
//
//  Created by Alex on 11/12/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLAttributedLabel.h"

@implementation FLAttributedLabel

- (void)awakeFromNib {
    [super awakeFromNib];

	self.linkAttributes       = @{(NSString *)kCTForegroundColorAttributeName: FLHexColor(kColorThemeLinks),
								  (NSString *)kCTUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)};
	self.activeLinkAttributes = @{(NSString *)kCTForegroundColorAttributeName: [UIColor hexColor:kColorThemeLinks alpha:.5f]};
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.numberOfLines == 0 && self.preferredMaxLayoutWidth != CGRectGetWidth(self.frame)) {
        self.preferredMaxLayoutWidth = self.frame.size.width;
        [self needsUpdateConstraints];
    }
    self.textAlignment = IS_RTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
}

@end
