//
//  FLLoginTextField.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 12/23/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLTextField.h"
#import "FLGraphics.h"
#import "FLTooltipView.h"

@implementation FLTextField

- (void)awakeFromNib {
    [super awakeFromNib];

    [self prepareLayerUI];
}

- (void)prepareForInterfaceBuilder {
    [self prepareLayerUI];
}

- (void)prepareLayerUI {
    
    CGRect paddingFrame      = CGRectMake(0, 0, 8, self.height);
    UIView *paddingView      = [[UIView alloc] initWithFrame:paddingFrame];

    self.leftView            = paddingView;
    self.rightView           = paddingView;
    self.leftViewMode        = UITextFieldViewModeAlways;
    self.rightViewMode       = UITextFieldViewModeAlways;
    self.textAlignment       = IS_RTL ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.layer.borderWidth   = 1;
    self.layer.borderColor   = FLHexColor(kColorFLTextFieldBorder).CGColor;
    self.layer.shadowColor   = [UIColor whiteColor].CGColor;
    self.layer.shadowOffset  = CGSizeMake(0, 1);
    self.layer.shadowOpacity = .5f;
    self.layer.shadowRadius  = .0f;
    self.layer.masksToBounds = YES;

    self.tintColor = [UIColor darkGrayColor];
}

- (void)setPlaceholder:(NSString *)placeholder {
    super.placeholder = placeholder;
    
    NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: FLHexColor(kColorPlaceholderFont),
                                                                                                                    NSFontAttributeName: [UIFont systemFontOfSize:14.0f]}];
    
    self.attributedPlaceholder = attributedPlaceholder;
}

- (void)drawRect:(CGRect)rect {
    FLContextPainter *painter = [[FLContextPainter alloc] initWithCurrentContext];
    [painter linearGraientWithRect:self.bounds fromColor:FLHexColor(@"DEDEDE")
                           toColor:[UIColor whiteColor]];
}
@end
