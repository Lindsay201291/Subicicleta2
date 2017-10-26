//
//  FLImageMGItemCell.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/16/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLImageMGItemCell.h"
#import "FLImageMGItemModel.h"

@interface FLImageMGItemCell ()

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *primaryLabel;

@end

@implementation FLImageMGItemCell {
    CGAffineTransform _hideDownTransform;
    CGFloat _animDuration;
}

@dynamic data;

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _hideDownTransform = CGAffineTransformMakeTranslation(0, self.frame.size.height / 2);
        _animDuration = .3f;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    _primaryLabel.text = FLLocalizedString(@"label_primary");
    self.bottomView.transform = _hideDownTransform;
}

- (void)setPrimary:(BOOL)primary {
    if (primary && !_primary) {
        [self showUp];
    }
    else if (!primary && _primary) {
        [self hideDown];
    }
    _primary = primary;
}

- (void)showUp {
    [UIView animateWithDuration:_animDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.bottomView.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
}

- (void)hideDown {
    
    [UIView animateWithDuration:_animDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.bottomView.transform = _hideDownTransform;
                     }
                     completion:nil];
}

@end
