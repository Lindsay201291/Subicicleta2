//
//  FLRootView.m
//  iFlynax
//
//  Created by Alex on 4/25/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLRootView.h"
#import "FLDemoVC.h"

@interface FLRootView () <REFrostedViewControllerDelegate>
@property (nonatomic, assign) BOOL frostedMenuIsOpen;
@end

@implementation FLRootView

- (void)awakeFromNib {
    [super awakeFromNib];

    // required for Labeled Solution
    if ([FLUserDefaults appPointedToDomain]) {
        self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
        self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
    }
    else {
        FLDemoVC *demoVC = [[FLDemoVC alloc] initWithNibName:@"FLDemoVC" bundle:nil];
        self.contentViewController = demoVC;
    }

	self.menuViewSize = CGSizeMake(kSideMenuWidth, 0); // 0 = auto calculation
	self.limitMenuViewSize = YES;
	self.frostedMenuIsOpen = NO;
	self.delegate = self;

    if (IS_RTL) {
        self.direction = REFrostedViewControllerDirectionRight;
    }

	self.blurTintColor = FLHexColor(kColorMenuBackground);
	self.backgroundFadeAmount = 0.5f;
	self.liveBlur = NO;
}

#pragma mark - REFrostedViewControllerDelegate

- (void)frostedViewController:(REFrostedViewController *)frostedViewController didShowMenuViewController:(UIViewController *)menuViewController {
	self.frostedMenuIsOpen = YES;
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController didHideMenuViewController:(UIViewController *)menuViewController {
	self.frostedMenuIsOpen = NO;
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan && self.frostedMenuIsOpen == NO) {
		CGPoint location = [recognizer locationInView:recognizer.view];
		frostedViewController.panGestureEnabled = (location.x <= kSideMenuSwipeLocationMinX);
	}
}

@end
