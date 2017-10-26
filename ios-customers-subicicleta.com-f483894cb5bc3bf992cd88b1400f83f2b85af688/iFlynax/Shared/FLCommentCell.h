//
//  FLCommentCell.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 8/14/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLDetailsTableViews.h"
#import "FLCommentModel.h"
#import "FLRatingStars.h"

@interface FLCommentCellBackgroundView: UIView

@end

@interface FLCommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet FLLabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet FLRatingStars *ratingStars;

@property (nonatomic) BOOL isRaitingEnabled;
@property (nonatomic) BOOL isPendingApproval;

- (void)fillWithCommentModel:(FLCommentModel *)model;
- (void)blink;

@end
