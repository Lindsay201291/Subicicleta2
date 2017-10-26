//
//  FLDetailsTableViews.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 12/3/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLDetailsTableViews.h"
#import "FLGraphics.h"

static NSString * const kColorHGradFrom   = @"E0E0E0";
static NSString * const kColorHGradTo     = @"C6C6C6";
static NSString * const kColorHBottomLine = @"ABABAB";

@implementation FLLabel

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];

    if (self.numberOfLines == 0 && bounds.size.width != self.preferredMaxLayoutWidth) {
        self.preferredMaxLayoutWidth = self.bounds.size.width;
        [self setNeedsUpdateConstraints];
    }
}

@end

@implementation FLDetailsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    if ([_detailLabel isKindOfClass:FLAttributedLabel.class]) {
        _detailLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    }
}

- (void)setCondition:(NSString *)condition {
    _condition = condition;

    if ([_condition isEqualToString:kConditionisPhone]) {
        NSRange phoneRange = NSMakeRange(0, [_detailLabel.text length]);
        [_detailLabel addLinkToPhoneNumber:_detailLabel.userInfo[kPhoneNumberKey] withRange:phoneRange];
    }
}

@end


#pragma mark - FLDetailsTableViewHeader


@interface FLDetailsTableViewHeader ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pcwHeightConstraint;

@end

@implementation FLDetailsTableViewHeader {
    BOOL isReadyToDraw;
    UIInterfaceOrientation orientaion;
    CGFloat originHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    _priceLabel.textColor = FLHexColor(kColorThemePrice);
}

- (void)setShowPhotosCollectionView:(BOOL)show {
    if (!originHeight)
        originHeight = _pcwHeightConstraint.constant;
    
    _showPhotosCollectionView = show;
    _pcwHeightConstraint.constant = show ? originHeight : 0;
    _photosCollection.hidden = !show;
   [self setNeedsUpdateConstraints];

    _priceLabel.textColor = FLHexColor(kColorThemePrice);
    _priceLabel.textAlignment = IS_RTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
}

- (void)drawRect:(CGRect)rect {
    
    //Draw on a proper rect only(hardcode)
    UIInterfaceOrientation actualOrientatation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientaion != actualOrientatation) {
        isReadyToDraw = NO;
        orientaion = actualOrientatation;
    }
    
    //Fix the header height regarding to constraints
    CGFloat height = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
    
    // Drawing
    if (isReadyToDraw) {
        
        FLContextPainter *painter = [[FLContextPainter alloc] initWithCurrentContext];
        CGFloat infoHeight = height - self.photosCollection.bounds.size.height;
        
        //Gradient
        [painter linearGraientWithRect:CGRectMake(0, 0, self.bounds.size.width, infoHeight)
                             fromColor:FLHexColor(kColorHGradFrom)
                               toColor:FLHexColor(kColorHGradTo)];
        
        if (_showPhotosCollectionView) {
            //Bottom separating line
            [painter strokeLineFromPoint:CGPointMake(0, infoHeight)
                                 toPoint:CGPointMake(self.bounds.size.width, infoHeight)
                               withColor:FLHexColor(kColorHBottomLine)
                            andLineWidth:1];
        }
    }
    else
        isReadyToDraw = YES;
    
}

@end

@implementation FLDetailsTableView

- (void)drawRect:(CGRect)rect {
    [self.headerView drawRect:self.headerView.bounds];
    self.tableHeaderView = self.headerView;
}

@end
