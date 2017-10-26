//
//  FLCommentCell.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 8/14/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLCommentCell.h"
#import "FLGraphics.h"

static NSString * const kColorSeparator  = @"9f9f9f";
static NSString * const kColorRStarsBack = @"a5a5a5";
static NSString * const kColorRStarsFill = @"171717";
static CGFloat    const kSeparatorHeight = 1.0f;

static CGFloat const kInsertedCellAnimationDuration = 1.0f;
static CGFloat const kInsertedCellAnimationDelay    = .2f;

@implementation FLCommentCellBackgroundView

- (void)drawRect:(CGRect)rect {
   
    FLContextPainter *painter = [[FLContextPainter alloc] initWithCurrentContext];
    
    CGFloat bY = self.bounds.size.height - kSeparatorHeight + 0.5f;
    
    [painter strokeLineFromPoint:CGPointMake(0, bY)
                         toPoint:CGPointMake(self.bounds.size.width, bY)
                       withColor:FLHexColor(kColorSeparator)
                    andLineWidth:kSeparatorHeight];
}

@end

@interface FLCommentCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation FLCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.isRaitingEnabled = [FLConfig boolWithKey:kConfigCommentsRatingModuleKey];
    self.statusLabel.text = FLLocalizedString(@"label_awating_approval");
    
    self.backgroundView = [[FLCommentCellBackgroundView alloc] init];
    self.backgroundView.backgroundColor = FLHexColor(kColorBackgroundColor);
    
    // Rating Stars init
    self.ratingStars.starsNumber = [FLConfigWithKey(kConfigCommentsStarsNumberKey) integerValue];
    self.ratingStars.backColor   = FLHexColor(kColorRStarsBack);
    self.ratingStars.fillColor   = FLHexColor(kColorRStarsFill);
    self.ratingStars.userInteractionEnabled = NO;
}

- (void)fillWithCommentModel:(FLCommentModel *)model {
    
    _titleLabel.text    = model.title;
    _messageLabel.text  = model.body;
    _authorLabel.text   = model.author;
    _dateLabel.text     = model.date;
    
    if (model.rating > 0)
        _ratingStars.rating = model.rating;
    else
        self.isRaitingEnabled = NO;
    
    self.isPendingApproval = model.status == FLCommentStatusPending;
}

- (void)setIsRaitingEnabled:(BOOL)enabled {
    _isRaitingEnabled = enabled;
    
    _ratingStars.hidden = !enabled;
    _titleTrailingConstraint.constant = enabled ? 132 : 15;
}

- (void)setIsPendingApproval:(BOOL)pending {
    _dateLabel.hidden   = pending;
    _statusLabel.hidden = !pending;
}

- (void)blink {
    CGFloat duration = kInsertedCellAnimationDuration / 2;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    [UIView animateWithDuration: duration
                          delay: kInsertedCellAnimationDelay
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^(void) {
                         self.contentView.backgroundColor = FLHexColor(kColorTabsSelectionIndicator);
                     }
                     completion: ^(BOOL finished) {
                         [UIView animateWithDuration:duration
                                               delay:0
                                             options: UIViewAnimationOptionCurveEaseOut
                                          animations:  ^{
                                              self.contentView.backgroundColor = [UIColor clearColor];
                                          }
                                          completion:nil];
                     }];
    
}

@end
