//
//  FLPlansCollectionViewCell.m
//  iFlynax
//
//  Created by Alex on 2/26/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLPlansCollectionViewCell.h"
#import "FLPlanModel.h"
#import "FLGraphics.h"

#import "DLRadioButton.h"
#import "FLPlansManager.h"
#import "FLPlanOptionsView.h"

static NSString * const kOptionTitleColorUsedUP = @"908f8f";

@interface FLPlansCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblPhotosAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblVideosAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblListingPeriod;
@property (weak, nonatomic) IBOutlet FLPlanOptionsView  *viewRadioGroup;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UILabel *usageLimitLabel;

@property (strong, nonatomic) FLPlanModel *planInfo;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleCalendarLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarVerticalSpacing;


@property (nonatomic, getter=isFeatured) BOOL featured;

@end

@implementation FLPlansCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    _viewRadioGroup.backgroundColor = [UIColor clearColor];
    _usageLimitLabel.text = FLLocalizedString(@"plan_usage_exceeded");
}

- (void)withPlanInfo:(FLPlanModel *)planInfo {
    self.planInfo = planInfo;

    // Assigning props
    _lblTitle.text         = planInfo.title;
    _lblType.text          = planInfo.typeShortName;
    _lblPrice.text         = planInfo.localizedPrice;
    _lblPhotosAmount.text  = planInfo.imagesMaxString;
    _lblVideosAmount.text  = planInfo.videosMaxString;
    _lblListingPeriod.text = planInfo.listingPeriodString;

    _lblPrice.textAlignment = IS_RTL ? NSTextAlignmentLeft : NSTextAlignmentRight;
    
    self.featured = (planInfo.type == FLPlanTypeFeatured);
    
    if (planInfo.planLimit > 0 && planInfo.planUsing == 0) {
        _viewRadioGroup.hidden = YES;
        _usageLimitLabel.hidden = NO;
    }
    else {
        _viewRadioGroup.hidden = NO;
        _usageLimitLabel.hidden = YES;
    }
    
    [_viewRadioGroup clear];
    
    [self addPlanOptions];
}

- (void)setFeatured:(BOOL)featured {
    _featured = featured;
    _titleCalendarLeading.priority = featured ? UILayoutPriorityDefaultHigh : UILayoutPriorityDefaultLow;
    _calendarVerticalSpacing.priority = featured ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh;
    _photoImageView.hidden = featured;
    _lblPhotosAmount.hidden = featured;
    _videoImageView.hidden = featured;
    _lblVideosAmount.hidden = featured;
    [self setNeedsUpdateConstraints];
}

- (void)addPlanOptions {
    if (_planInfo.advancedMode) {
        /* standard plan mode */
        FLPlanModel *standardPlanModel = _planInfo;
        standardPlanModel.planMode = FLPlanModeStandard;

        FLRadioButton *standardButton = [self radioButtonWithUserInfo:standardPlanModel];
        [self buildPlanOptionTitleForButton:standardButton advanced:YES featured:NO];

        [_viewRadioGroup addView:standardButton];
        /* standard plan mode END */

        /* featured plan mode */
        FLPlanModel *featuredPlanModel = [_planInfo copy];
        featuredPlanModel.planMode = FLPlanModeFeatured;

        FLRadioButton *featuredButton = [self radioButtonWithUserInfo:featuredPlanModel];
        [self buildPlanOptionTitleForButton:featuredButton advanced:YES featured:YES];
        [_viewRadioGroup addView:featuredButton];
        /* featured plan mode END */
    }
    else {
        self.planInfo.planMode = _planInfo.featured ? FLPlanModeFeatured : FLPlanModeStandard;

        FLRadioButton *standardButton = [self radioButtonWithUserInfo:_planInfo];
        [self buildPlanOptionTitleForButton:standardButton advanced:NO featured:_planInfo.featured];

        [_viewRadioGroup addView:standardButton];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [super setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    FLContextPainter *painter = [[FLContextPainter alloc] initWithCurrentContext];
    [painter fillRect:rect withColor:[_planInfo.color colorWithAlphaComponent:.3f]];

    static float leftLineWidth = 7.5;
    float mlY = _lblPhotosAmount.top + _lblPhotosAmount.height + 15;
    static float lh = .5f;

    // middle line
    [painter strokeLineFromPoint:CGPointMake(leftLineWidth, mlY)
                         toPoint:CGPointMake(CGRectGetMaxX(rect), mlY)
                       withColor:FLHexColor(kColorBackgroundColor) andLineWidth:lh * 2];

    // left massive line
    [painter strokeRect:CGRectMake(0, 0, leftLineWidth, CGRectGetHeight(rect))
              withColor:_planInfo.color andLineWidth:leftLineWidth];

    // Border
    self.layer.borderColor = [UIColor hexColor:@"b7b7b7"].CGColor;
    self.layer.borderWidth = lh;
}

- (FLRadioButton *)radioButtonWithUserInfo:(FLPlanModel *)planModel {
    FLPlansManager *_manager = [FLPlansManager sharedManager];

    CGRect frame = CGRectMake(0, 0, self.viewRadioGroup.width, 30);
    FLRadioButton *button = [FLRadioButton withFrame:frame];
    button.delegate = self.radioButtonDelegate;
    button.userInfo = planModel;

    if (_manager.selectedPlan != nil && _manager.selectedPlan.pId == _planInfo.pId) {
        if (planModel.planMode == _manager.selectedPlan.planMode) {
            button.selected = YES;
        }
    }

    button.otherButtons = [_manager.planButtons copy];
    [_manager.planButtons addObject:button];

    return button;
}

- (void)buildPlanOptionTitleForButton:(FLRadioButton *)button advanced:(BOOL)advanced featured:(BOOL)featured {
    NSString *titleKey = featured ? @"featured_listing" : @"standard_listing";
    NSMutableString *title = [NSMutableString stringWithString:FLLocalizedString(titleKey)];
    BOOL _optionUsedUP = NO;

    if (_planInfo.advancedMode) {
        NSInteger planListings = (featured ? _planInfo.featuredListings : _planInfo.standardListings);
        NSInteger planRemains  = (featured ? _planInfo.featuredRemains  : _planInfo.standardRemains);

        if (planListings != 0) {
            [title appendString:@" ("];

            if (_planInfo.listingsRemains) {
                if (!planRemains) {
                    [title appendString:FLLocalizedString(@"used_up")];
                    _optionUsedUP = YES;
                }
                else [title appendFormat:@"%d", (int) planRemains];
            }
            else {
                [title appendFormat:@"%d", (int) planListings];
            }
            [title appendString:@")"];
        }
    }

    if (_optionUsedUP) {
        UIColor *titleColor = [UIColor hexColor:kOptionTitleColorUsedUP];
        NSAttributedString *attributedTitle =
        [[NSAttributedString alloc] initWithString:title
                                        attributes:@{NSForegroundColorAttributeName:titleColor}];
        [button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
        [button setEnabled:NO];
    }
    else [button setTitle:title forState:UIControlStateNormal];
}

@end

