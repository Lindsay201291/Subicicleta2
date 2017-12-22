//
//  FLPolicyVC.m
//  iFlynax
//
//  Created by Alex on 1/14/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import "FLPolicyVC.h"

@interface FLPolicyVC ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *disagreeBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *agreeBtn;
@end

@implementation FLPolicyVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [_agreeBtn setTitle:FLLocalizedString(@"button_de_acuerdo")];
    [_disagreeBtn setTitle:FLLocalizedString(@"button_disentir")];
}

- (IBAction)buttonDidTap:(UIBarButtonItem *)sender {
    [self dismissVCWithResult:(sender == _agreeBtn)];
}

- (void)dismissVCWithResult:(BOOL)accepted {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.buttonsTrigger) {
            self.buttonsTrigger(accepted);
        }
    }];
}

@end
