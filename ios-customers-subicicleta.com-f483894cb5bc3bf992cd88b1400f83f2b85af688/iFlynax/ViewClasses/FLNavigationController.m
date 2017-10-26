//
//  FLNavigationController.m
//  iFlynax
//
//  Created by Alex on 1/14/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLNavigationController.h"

@implementation FLNavigationController

- (void)setupUI {
    self.navigationBar.barTintColor = FLHexColor(kColorBarTintColor);
    self.navigationBar.tintColor    = [UIColor whiteColor];
    self.navigationBar.barStyle     = UIBarStyleBlack;
    self.modalPresentationStyle     = UIModalPresentationFormSheet;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
        [self setupUI];
	}
	return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
