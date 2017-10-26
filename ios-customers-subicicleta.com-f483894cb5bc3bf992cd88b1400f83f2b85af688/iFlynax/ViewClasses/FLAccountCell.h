//
//  FLAccountCell.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 5/22/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLDetailsTableViews.h"

@interface FLAccountCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet FLLabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *adsNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *listImage;

- (void)fillWithAccountInfo:(NSDictionary *)accountInfo;

@end
