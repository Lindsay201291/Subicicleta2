//
//  FLRemindPassword.m
//  iFlynax
//
//  Created by Alex on 3/12/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLRemindPassword.h"
#import "FLTextField.h"
#import "FLInputAccessoryToolbar.h"
#import "FLKeyboardHandler.h"
#import "FLValidatorManager.h"

@interface FLRemindPassword () <FLKeyboardHandlerDelegate>

@property (weak, nonatomic) IBOutlet FLTextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (strong, nonatomic) FLKeyboardHandler *keyboardHandler;
@property (strong, nonatomic) FLValidatorManager *validatorManager;

@end

@implementation FLRemindPassword {
    FLInputAccessoryToolbar *_accessoryToolbar;
    BOOL _afterKeyboardDismiss;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = FLLocalizedString(@"screen_remind_password");
    self.view.backgroundColor = FLHexColor(kColorBackgroundColor);
    self.navigationItem.leftBarButtonItem.title = FLLocalizedString(@"button_cancel");
    
    _afterKeyboardDismiss = NO;
    
    _emailTextField.placeholder = FLLocalizedString(@"placeholder_email");
    [_submitButton setTitle:FLLocalizedString(@"button_submit") forState:UIControlStateNormal];
    
    // validation inits
    _validatorManager = [FLValidatorManager new];
    
    FLValiderRequired *inputRequiredValider = [FLValiderRequired validerWithHint:FLLocalizedString(@"valider_fillin_the_field")];
    FLValiderEmail *inputEmailValider = [FLValiderEmail validerWithHint:FLLocalizedString(@"valider_proper_email_address")];
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_emailTextField withValider:@[inputRequiredValider, inputEmailValider]]];
    
    // accessory toolbar
    _accessoryToolbar = [FLInputAccessoryToolbar toolbarWithInputItems:@[_emailTextField]];
    
    // keyboard handler
    _keyboardHandler = [[FLKeyboardHandler alloc] initWithScroll:nil];
    _keyboardHandler.delegate = self;

}

- (void)submitForm {
    if ([_validatorManager validate]) {
        
        [FLProgressHUD showWithStatus:FLLocalizedString(@"loading")];
        
        [flynaxAPIClient postApiItem:kApiItemRequests
                          parameters:@{@"cmd"  : kApiItemRequests_resetPassword,
                                       @"email": _emailTextField.text}
                          completion:^(NSDictionary *response, NSError *error) {
                              if (!error && [response isKindOfClass:NSDictionary.class]) {
                                  if (response[@"success"] != nil) {
                                      [FLProgressHUD showSuccessWithStatus:FLCleanString(response[@"message"])];
                                      
                                  }
                                  else if (response[@"error"] != nil) {
                                      [FLProgressHUD showErrorWithStatus:FLCleanString(response[@"error"])];
                                  }
                              }
                              else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"error")];
                          }];
    }
}

#pragma mark - FLKeyboardHandler delegate

- (void)keyboardHandlerDidHideKeyboard {
    if (_afterKeyboardDismiss) {
        [self dismiss];
    }
}

#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _emailTextField) {
        [self submitForm];
    }
    return YES;
}

#pragma mark - Actions

- (IBAction)sumbitButtonDidTap:(UIButton *)sender {
    [self submitForm];
}

- (IBAction)dissmissViewController:(UIBarButtonItem *)sender {
    _afterKeyboardDismiss = _keyboardHandler.isKeyboardOn;
    if (_afterKeyboardDismiss) {
        [self.view endEditing:YES];
    }
    else {
        [self dismiss];
    }
}

#pragma mark - Navigation

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
