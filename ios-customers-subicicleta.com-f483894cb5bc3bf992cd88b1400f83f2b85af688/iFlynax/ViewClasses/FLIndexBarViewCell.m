//
//  FLIndexBarViewCell.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 5/26/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLIndexBarViewCell.h"

@implementation FLIndexBarViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.contentView.backgroundColor = FLHexColor(kColorThemeGlobal);
        self.charLabel.textColor = FLHexColor(kColorIndexBarBackground);
    }
    else {
        self.contentView.backgroundColor =[UIColor clearColor];
        self.charLabel.textColor = FLHexColor(kColorIndexBarText);
    }
}

@end
