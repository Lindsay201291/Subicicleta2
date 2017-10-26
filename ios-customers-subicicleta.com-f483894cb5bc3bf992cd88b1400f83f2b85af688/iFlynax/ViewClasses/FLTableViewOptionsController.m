//
//  FLTableViewOptionsController.m
//  iFlynax
//
//  Created by Alex on 10/22/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLTableViewOptionsController.h"

@interface FLTableViewOptionsController () {
    FLNavigationController *_flNavigationController;
}
@end

@implementation FLTableViewOptionsController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (FLNavigationController *)flNavigationController {
    if (!_flNavigationController) {
        _flNavigationController = [[FLNavigationController alloc] initWithRootViewController:self];

        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:FLLocalizedString(@"button_done")
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(doneButtonDidTap:)];
        self.navigationItem.leftBarButtonItem = doneButton;
    }
    return _flNavigationController;
}

#pragma mark - Navigation

- (void)doneButtonDidTap:(UIButton *)button {
    [self.rowItem isValid];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
