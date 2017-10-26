//
//  FLAccountTypeView.m
//  iFlynax
//
//  Created by Alex on 3/19/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "REFrostedViewController.h"
#import "FLAccountTypeView.h"

@interface FLAccountTypeView ()

@end

@implementation FLAccountTypeView

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = FLHexColor(kColorBackgroundColor);

    //account_type
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (IBAction)showSideMenu:(UIBarButtonItem *)sender {
    [self.frostedViewController presentMenuViewController];
}

@end
