//
//  FLManageCategory.m
//  iFlynax
//
//  Created by Alex on 3/4/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLCategoryBox.h"
#import "FLView.h"

static NSString * const kArrowLeft  = @"❯";
static NSString * const kArrowRight = @"❮";

@interface FLCategoryBox ()
@property (strong, nonatomic) IBOutlet UIView  *view;
@property (weak, nonatomic)   IBOutlet FLView  *categoryBox;
@property (weak, nonatomic)   IBOutlet FLView  *planBox;
@property (weak, nonatomic)   IBOutlet UILabel *titleLabel;
@property (weak, nonatomic)   IBOutlet UILabel *planTitleLabel;
@property (weak, nonatomic)   IBOutlet UILabel *breadcrumbLabel;
@property (weak, nonatomic)   IBOutlet UIButton *editCategoryBtn;
@end

@implementation FLCategoryBox

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
        _view.backgroundColor = FLHexColor(kColorBackgroundColor);
        self.frame = self.view.bounds;
        [self insertSubview:_view atIndex:0];

        self.planBox.centerLine = NO;
        self.planBtnActive      = NO;
        self.titleLabel.text    = FLLocalizedString(@"listing_category");
        self.planTitle          = FLLocalizedString(@"select_plan");
        self.breadcrumbs        = [NSMutableArray array];

        self.breadcrumbLabel.textAlignment = (IS_RTL
                                              ? NSTextAlignmentRight
                                              : NSTextAlignmentLeft);
    }
    return self;
}

- (void)removePlanBoxFromSuperview {
    if (!_planBox) {
        return;
    }

    CGFloat newBoxHeight = self.height - (_planBox.height + kGlobalPadding);
    [_planBox removeFromSuperview];
    self.height = newBoxHeight;
}

- (IBAction)editCategoryTapped:(UIButton *)sender {
    if (self.delegate != nil) {
        [self.delegate categoryBox:self buttonTapped:FLCategoryBoxBtnEdit];
    }
}

- (IBAction)selectPlanTapped:(UITapGestureRecognizer *)sender {
    if (self.planBtnActive && self.delegate != nil) {
        [self.delegate categoryBox:self buttonTapped:FLCategoryBoxBtnSelectPlan];
    }
}

- (void)buildBreadcrumbs {
    NSString *arrow = kArrowLeft;

    if (IS_RTL) {
        self.breadcrumbs = [[[self.breadcrumbs reverseObjectEnumerator] allObjects] mutableCopy];
        arrow = kArrowRight;
    }
    _breadcrumbLabel.text = [self.breadcrumbs componentsJoinedByString:F(@" %@ ", arrow)];
}

#pragma mark - Setters

- (void)setEditCategoryBtnActive:(BOOL)editCategoryBtnActive {
    _editCategoryBtnActive   = editCategoryBtnActive;
    _editCategoryBtn.hidden  = !editCategoryBtnActive;

    /* //for future purpose
    _editCategoryBtn.alpha   = editCategoryBtnActive ? 1 : .75f;
    _editCategoryBtn.enabled = editCategoryBtnActive;
     */
}

- (void)setPlanTitle:(NSString *)planTitle {
    _planTitle = planTitle;
    _planTitleLabel.text = planTitle;
}

- (void)setPlanTitleColor:(NSString *)planTitleColor {
    _planTitleColor = planTitleColor;
    _planTitleLabel.textColor = FLHexColor(planTitleColor);
}

@end
