//
//  FLMenuItemCell.m
//  iFlynax
//
//  Created by Alex on 4/25/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLMenuItemCell.h"
#import "FLGraphics.h"

static CGFloat const kSeparatorPadding = 10.0f;

@implementation FLMenuItemCell

- (void)awakeFromNib {
    [super awakeFromNib];

	self.backgroundColor = FLHexColor(kColorMenuBackground);
	self.badgeTextColor = FLHexColor(kColorMenuBackground);
	self.badgeTextColorHighlighted = self.badgeTextColor;
	self.badgeColor = FLHexColor(kColorThemeGlobal);
	self.showShadow = NO; // for badge
    
	self.selectorView.backgroundColor = FLHexColor(kColorThemeGlobal);
    self.selectorView.hidden = NO;
    
	self.badgeRightOffset = 10.0f;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    _selectorView.hidden = !highlighted;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    _selectorView.hidden = !selected;
    [super setSelected:selected animated:animated];
}

- (void)setBadgeInteger:(NSInteger)badgeInteger {
    NSString *badgeString = badgeInteger ? F(@"%@", @(badgeInteger)) : @"";
    [super setBadgeString:badgeString];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_bottomSeparator) {
        FLContextPainter *painter = [[FLContextPainter alloc] initWithCurrentContext];
        CGFloat padding = kSeparatorPadding;
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat offsetY = rect.size.height - 2 / scale;
        
        [painter fillRect:CGRectMake(padding, offsetY, rect.size.width - 2 * padding, 1 / scale) withColor:FLHexColor(kColorMenuSeparator)];
        [painter fillRect:CGRectMake(padding, offsetY + 1 / scale, rect.size.width - 2 * padding, 1 / scale) withColor:FLHexColor(kColorMenuSeparatorStroke)];
    }
}

@end
