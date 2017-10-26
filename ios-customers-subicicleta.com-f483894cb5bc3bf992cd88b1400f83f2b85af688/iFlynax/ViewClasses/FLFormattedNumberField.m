//
//  FLFormattedNumberField.m
//  iFlynax
//
//  Created by Alex on 9/1/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFormattedNumberField.h"
#import "FLGraphics.h"

@implementation FLFormattedNumberField

- (void)awakeFromNib {
    [super awakeFromNib];
    [self prepareLayerUI];
}

- (void)prepareLayerUI {
    CGRect paddingFrame      = CGRectMake(0, 0, 8, self.height);
    self.leftView            = [[UIView alloc] initWithFrame:paddingFrame];
    self.leftViewMode        = UITextFieldViewModeAlways;

    self.layer.borderWidth   = 1;
    self.layer.borderColor   = FLHexColor(@"919191").CGColor;
    self.layer.shadowColor   = [UIColor whiteColor].CGColor;
    self.layer.shadowOffset  = CGSizeMake(0, 1);
    self.layer.shadowOpacity = .5f;
    self.layer.shadowRadius  = .0f;
    self.layer.masksToBounds = YES;
}

- (void)drawRect:(CGRect)rect {
    FLContextPainter *painter = [[FLContextPainter alloc] initWithCurrentContext];
    [painter linearGraientWithRect:self.bounds fromColor:FLHexColor(@"DEDEDE")
                           toColor:[UIColor whiteColor]];
}

@end
