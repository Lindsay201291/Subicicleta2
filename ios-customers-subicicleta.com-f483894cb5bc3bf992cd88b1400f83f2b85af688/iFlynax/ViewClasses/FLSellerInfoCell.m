//
//  FLSellerInfoCell.m
//  iFlynax
//
//  Created by Alex on 10/27/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLSellerInfoCell.h"

@interface FLSellerInfoCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation FLSellerInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];

    // Initialization code
	_titleLabel.textColor = FLHexColor(@"646464");
	_valueLabel.textColor = FLHexColor(@"000000");

    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;

	// Automatically detect links when the label text is subsequently changed
	_valueLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
}

#pragma mark - setters

- (void)setTitle:(NSString *)title {
	_title = title;
	_titleLabel.text = title;
}

- (void)setCondition:(NSString *)condition {
	_condition = condition;

	if ([_condition isEqualToString:kConditionisPhone]) {
		NSRange phoneRange = NSMakeRange(0, [_valueLabel.text length]);
		[_valueLabel addLinkToPhoneNumber:_valueLabel.userInfo[kPhoneNumberKey] withRange:phoneRange];
	}
}

@end
