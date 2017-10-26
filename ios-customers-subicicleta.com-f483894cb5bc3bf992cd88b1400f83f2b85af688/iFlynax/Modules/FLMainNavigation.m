//
//  FLNavigationController.m
//  iFlynax
//
//  Created by Alex on 4/25/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLMainNavigation.h"

@interface FLMainNavigation ()
@end

@implementation FLMainNavigation

- (void)viewDidLoad {
    [super viewDidLoad];

	// add swipe gesture
	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
									   initWithTarget:self action:@selector(panGestureRecognized:)];
    [self.view addGestureRecognizer:panGesture];

	//
	self.navigationBar.barTintColor = FLHexColor(kColorBarTintColor);
	self.navigationBar.tintColor = [UIColor whiteColor];
	self.navigationBar.barStyle = UIBarStyleBlack;
	//
	self.view.backgroundColor = FLHexColor(kColorBackgroundColor);
}

#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender {
    [self.frostedViewController panGestureRecognized:sender];
}

- (BOOL)shouldAutorotate {
	return self.topViewController.shouldAutorotate;
}

@end