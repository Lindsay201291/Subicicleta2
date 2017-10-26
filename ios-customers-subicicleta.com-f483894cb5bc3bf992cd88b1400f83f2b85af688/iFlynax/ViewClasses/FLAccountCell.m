//
//  FLAccountCell.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 5/22/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLAccountCell.h"
#import "FLListingCellBackgroundView.h"
#import "FLGraphics.h"


@implementation FLAccountCell {
    BOOL _isBlank;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor clearColor];
    self.avatarImageView.backgroundColor = FLHexColor(@"eeeeee");
    self.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarImageView.layer.borderWidth = 2.0f;
    self.avatarImageView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.avatarImageView.layer.shadowOpacity = 0.75f;

    self.backgroundView = [[FLListingCellBackgroundView alloc] init];
    self.backgroundView.backgroundColor = FLHexColor(kColorBackgroundColor);
    
    _isBlank = YES;
}

- (void)fillWithAccountInfo:(NSDictionary *)accountInfo {
    self.nameLabel.text = FLCleanString(accountInfo[@"fullName"]);
    self.locationLabel.text = FLCleanString(accountInfo[@"middleField"]);
    self.dateLabel.text = FLCleanString(accountInfo[@"date"]);

    int lcount = [accountInfo[@"lcount"] intValue];
    _adsNumberLabel.hidden = _listImage.hidden = (lcount == 0);

    if (lcount) {
        self.adsNumberLabel.text = F(FLLocalizedString(@"seller_ads_count"), lcount);
    }
}

@end
