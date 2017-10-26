//
//  FLRadioGroup.m
//  iFlynax
//
//  Created by Alex on 12/23/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLRadioGroup.h"

static NSArray * FLPrepareButtons(NSArray *buttons) {
	NSMutableArray *result = [NSMutableArray new];

	[buttons enumerateObjectsUsingBlock:^(NSDictionary *button, NSUInteger idx, BOOL *stop) {
		TNCircularCheckBoxData *radio = [[TNCircularCheckBoxData alloc] init];
		radio.identifier   = button[@"value"];
		radio.labelText    = button[@"title"];
		radio.checked      = [button[@"checked"] boolValue];
		radio.borderColor  = [UIColor hexColor:@"aaa296"];
		radio.circleColor  = [UIColor hexColor:@"0099cc"];
		radio.borderRadius = 15;
		radio.circleRadius = radio.borderRadius - 5;

		[result addObject:radio];
	}];

	return result;
}

@interface FLRadioGroup () {
	TNCircularCheckBoxData *_lastCheckedRadioButton;
}
@end

@implementation FLRadioGroup

- (instancetype)initWithButtons:(NSArray *)buttons {
	self = [super initWithCheckBoxData:FLPrepareButtons(buttons) style:TNCheckBoxLayoutVertical];

	if (self) {
		[self create];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(groupChanged:)
													 name:GROUP_CHANGED
												   object:self];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GROUP_CHANGED object:self];
}

#pragma mark - Target / Actions

- (void)groupChanged:(NSNotification *)notification {
	if (_lastCheckedRadioButton == nil && self.checkedCheckBoxes.count) {
		_lastCheckedRadioButton = self.checkedCheckBoxes[0];
	}
	else {
		[self.radioButtons enumerateObjectsUsingBlock:^(TNCircularCheckBox *input, NSUInteger idx, BOOL *stop) {
			if ([input.data isEqual:_lastCheckedRadioButton]) {
				input.data.checked = NO;
				[input checkWithAnimation:YES];

				*stop = YES; // Stop enumerating
			}
		}];

		if (self.checkedCheckBoxes.count)
			_lastCheckedRadioButton = self.checkedCheckBoxes[0];
	}
}

@end
