//
//  FLEditProfileHeader.m
//  iFlynax
//
//  Created by Alex on 9/16/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLEditProfileHeader.h"
#import "FLView.h"

@interface FLEditProfileHeader ()
@property (strong, nonatomic) IBOutlet UIView  *view;
@property (weak, nonatomic)   IBOutlet FLView  *emailBox;
@property (weak, nonatomic)   IBOutlet UILabel *titleLabel;
@end

@implementation FLEditProfileHeader

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
        _view.backgroundColor = FLHexColor(kColorBackgroundColor);
        self.frame = _view.bounds;
        [self insertSubview:_view atIndex:0];

        _emailBox.centerLine = YES;
        _titleLabel.text = FLLocalizedString(@"label_email");
        _emailLabel.textAlignment = IS_RTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    }
    return self;
}

- (IBAction)editMailBtnTapped:(UIButton *)sender {
    if (self.onTapEditMail != nil) {
        self.onTapEditMail(sender);
    }
}

@end
