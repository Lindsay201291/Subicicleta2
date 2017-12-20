//
//  FLChangePasswordView.m
//  iFlynax
//
//  Created by Alex on 12/11/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLChangePasswordView.h"
#import "FLKeyboardHandler.h"
#import "FLTextField.h"
#import "FLValidatorManager.h"
#import "FLInputAccessoryToolbar.h"

@interface FLChangePasswordView ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet FLTextField  *passwordCurrentField;
@property (weak, nonatomic) IBOutlet FLTextField  *passwordNewField;
@property (weak, nonatomic) IBOutlet FLTextField  *passwordVerifyField;

@property (strong, nonatomic) FLValidatorManager  *validatorManager;
@property (strong, nonatomic) FLKeyboardHandler   *keyboardHandler;
@property (weak, nonatomic) IBOutlet UIButton *savePasswordBtn;
@end

@implementation FLChangePasswordView {
    FLInputAccessoryToolbar *_accessoryToolbar;
}

- (void)awakeFromNib {
    [super awakeFromNib];

	self.title = FLLocalizedString(@"screen_cambiar_contraseña");
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = FLHexColor(kColorBackgroundColor);

	_passwordCurrentField.placeholder = FLLocalizedString(@"placeholder_contraseña_actual");
	_passwordNewField.placeholder     = FLLocalizedString(@"placeholder_nueva_contraseña");
	_passwordVerifyField.placeholder  = FLLocalizedString(@"placeholder_confirmar_contraseña");
    [_savePasswordBtn setTitle:FLLocalizedString(@"button_guardar_contraseña") forState:UIControlStateNormal];
    
    // validation
    _validatorManager = [FLValidatorManager new];
    
    FLValiderRequired       *inputRequiredValider  = [FLValiderRequired       validerWithHint:FLLocalizedString(@"valider_completar_el_campo")];
    FLValiderPasswordPolicy *passwordPolicyValider = [FLValiderPasswordPolicy validerWithHint:FLLocalizedString(@"valider_password_debil")];
    FLValiderEqualInput     *equalInputValider     = [FLValiderEqualInput     validerWithControl:_passwordNewField withHint:FLLocalizedString(@"alert_password_no_coincide")];
    
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_passwordCurrentField withValider:@[inputRequiredValider]]];
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_passwordNewField     withValider:@[inputRequiredValider, passwordPolicyValider]]];
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_passwordVerifyField  withValider:@[inputRequiredValider, equalInputValider]]];
    
    // accessory toolbar
    _accessoryToolbar = [FLInputAccessoryToolbar toolbarWithInputItems:@[_passwordCurrentField, _passwordNewField, _passwordVerifyField]];
    __unsafe_unretained typeof(self) weakSelf = self;
    _accessoryToolbar.didDoneTapBlock = ^(id activeItem) {
        if (activeItem == _passwordVerifyField) {
            [weakSelf submitForm];
        }
    };
    
    // keyboard handler
    _keyboardHandler = [[FLKeyboardHandler alloc] initWithScroll:_scrollView];
}

- (void)viewDidAppear:(BOOL)animated {
	self.screenName = self.title;
	[super viewDidAppear:animated];
}

#pragma mark - Data

- (void)submitForm {
    if ([_validatorManager validate]) {
        
        [FLProgressHUD showWithStatus:FLLocalizedString(@"cargando")];
        
        [flynaxAPIClient postApiItem:kApiItemMyProfile
                          parameters:@{@"action"  : kApiItemMyProfile_changePassword,
                                       @"id"      : @([FLAccount userId]),
                                       @"old_pass": _passwordCurrentField.text,
                                       @"new_pass": _passwordNewField.text}
         
                          completion:^(NSDictionary *response, NSError *error) {
                              if (error == nil) {
                                  if (response[@"error"] != nil)
                                      [FLProgressHUD showErrorWithStatus:response[@"error"]];
                                  
                                  else if (response[@"success"] != nil) {
                                      _passwordCurrentField.text = @"";
                                      _passwordNewField.text     = @"";
                                      _passwordVerifyField.text  = @"";
                                      [self.view endEditing:YES];
                                      
                                      [FLProgressHUD showSuccessWithStatus:response[@"success"]];
                                  }
                                  else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"unknown_error")];
                              }
                              else [FLDebug showAdaptedError:error apiItem:kApiItemMyProfile];
                          }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _passwordVerifyField) {
        [self submitForm];
    }
    else {
        [_accessoryToolbar goToNextItem];
    }
    return NO;
}

#pragma mark - Buttons Actions

- (IBAction)updatePassword:(UIButton *)sender {
    [self submitForm];
}

- (void)dealloc {
    [_keyboardHandler unRegisterNotifications];
}

@end
