//
//  FLPhotosCell.m
//  iFlynax
//
//  Created by Alex on 6/4/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLPhotosCell.h"

@implementation FLPhotosCell

@end

@implementation FLPhotoView

- (void)layoutSubviews {
	self.clipsToBounds = NO;
	self.layer.borderWidth = 2.0f;
	self.layer.borderColor = [UIColor whiteColor].CGColor;

	self.layer.shadowColor = [UIColor blackColor].CGColor;
	self.layer.shadowOpacity = 0.35f;
	self.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);

	UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
	self.layer.shadowPath = shadowPath.CGPath;
}

@end