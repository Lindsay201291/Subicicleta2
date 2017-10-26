//
//  FLFieldAcceptCell.m
//  iFlynax
//
//  Created by Alex on 10/13/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLFieldAcceptCell.h"
#import "FLRadioButton.h"
#import "FLPolicyVC.h"

static NSString * const kLinkSearchPattern = @"\\[(.*)\\]";

@interface FLFieldAcceptCell () <FLRadioButtonDelegate> {
    NSString *_buttonTitle;
}
@property (weak, nonatomic) IBOutlet FLRadioButton *checkbox;
@property (weak, nonatomic) IBOutlet UIButton *button;
@end

@implementation FLFieldAcceptCell
@dynamic item;

- (void)cellDidLoad {
    [super cellDidLoad];
    [_checkbox setDelegate:self];
    [_checkbox setIconSquare:YES];
}

- (void)cellWillAppear {
    if (!_buttonTitle) {
        _buttonTitle = FLCleanString(self.item.model.name);

        NSAttributedString *attributedTitle =
        [[NSAttributedString alloc] initWithString:_buttonTitle
                                        attributes:@{NSForegroundColorAttributeName:FLHexColor(@"006ec2")}];
        [_button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    }

    _checkbox.selected = self.item.value;
    [self highlightAsErrorIfNecessary];
}

- (NSAttributedString *)attributedCheckboxTitleTextWitColor:(UIColor *)color {
    NSAttributedString *title =
    [[NSAttributedString alloc] initWithString:FLLocalizedString(@"button_accept_agreement_checkbox")
                                    attributes:@{NSForegroundColorAttributeName:color}];
    return title;
}

- (void)highlightAsErrorIfNecessary {
    _checkbox.iconColor = FLHexColor(self.item.errorTrigger ? kColorFieldHasError : @"000");
    [_checkbox setAttributedTitle:[self attributedCheckboxTitleTextWitColor:_checkbox.iconColor]
                         forState:UIControlStateNormal];
}

- (IBAction)buttonDidTap:(UIButton *)sender {
    UINavigationController *policyNC = [self.item.parentVC.storyboard instantiateViewControllerWithIdentifier:kStoryBoardPolicyVC];
    FLPolicyVC *policyVC = (FLPolicyVC *)policyNC.topViewController;
    policyVC.title = _buttonTitle;

    [self.item.parentVC presentViewController:policyNC animated:YES completion:^{
        NSString *_html = [self.item.model.data stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
        [policyVC.webview loadHTMLString:F(@"<div style=\"padding: 8px;\">%@</div>", _html) baseURL:nil];
    }];

    policyVC.buttonsTrigger = ^(BOOL accepted) {
        if (!self.item.value || !accepted) {
            _checkbox.selected = accepted;
            [self FLRadioButtonDidTapped:_checkbox];
        }
    };
}

#pragma mark - FLRadioButtonDelegate

- (void)FLRadioButtonDidTapped:(FLRadioButton *)button {
    if (self.item.value) {
        button.selected = NO;
    }

    self.item.value = button.selected;
    self.item.errorTrigger = !button.selected;

    [self highlightAsErrorIfNecessary];
}

@end
