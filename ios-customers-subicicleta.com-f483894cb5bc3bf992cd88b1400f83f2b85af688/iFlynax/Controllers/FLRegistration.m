//
//  FLRegistration.m
//  iFlynax
//
//  Created by Alex on 3/17/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLRegistration.h"
#import "FLTextField.h"
#import "FLDropDown.h"
#import "FLInputAccessoryToolbar.h"
#import "FLKeyboardHandler.h"
#import "FLValidatorManager.h"
#import "FLPersonalAddress.h"

static NSString * const kAccountTypeKeyName  = @"key";
static NSString * const kAccountTypeNameKey  = @"name";

static NSString * const kApiResultSuccessKey = @"success";
static NSString * const kApiResultMessageKey = @"message_key";
static NSString * const kApiResultErrorKey   = @"error";

static NSString * const kApiResultLoggedKey  = @"logged";
static NSString * const kApiResultProfileKey = @"profile";

@interface FLRegistration () <FLKeyboardHandlerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet FLTextField *userNameField;
@property (weak, nonatomic) IBOutlet FLTextField *passwordField;
@property (weak, nonatomic) IBOutlet FLTextField *emailField;
@property (weak, nonatomic) IBOutlet FLDropDown *typeDropDown;
@property (weak, nonatomic) IBOutlet FLPersonalAddress *personalAddress;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (strong, nonatomic) IBOutletCollection(id) NSArray *inputsCollection;

@property (strong, nonatomic) FLKeyboardHandler *keyboardHandler;
@property (strong, nonatomic) FLValidatorManager *validatorManager;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonEmailConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonPersonalAddressContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailTopConstraint;

@property (nonatomic) BOOL showUserNameInput;
@property (nonatomic) BOOL showPersonalAddress;

@end

@implementation FLRegistration {
    FLInputAccessoryToolbar *_accessoryToolbar;
    BOOL _afterKeyboardDismiss;
    NSArray *_accountTypes;
    NSMutableArray *_inputsMutableCollection;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.screenName = FLLocalizedString(@"screen_registration");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.screenName;
    self.view.backgroundColor = FLHexColor(kColorBackgroundColor);
    self.navigationItem.leftBarButtonItem.title = FLLocalizedString(@"button_cancel");
    
    _accountTypes = [FLAccountTypes getList];
    _inputsMutableCollection = [_inputsCollection mutableCopy];
    
    self.showUserNameInput   = [FLAccount loginModeIs:FLAccountLoginModeUsername];
    self.showPersonalAddress = NO;
    
    // init form controls
    _userNameField.placeholder = FLLocalizedString(@"placeholder_username");
    _emailField.placeholder    = FLLocalizedString(@"placeholder_email");
    _passwordField.placeholder = FLLocalizedString(@"placeholder_password");
    
    _typeDropDown.title        = FLLocalizedString(@"dropdown_title_account_types");
    for (NSDictionary *typeData in _accountTypes) {
        [_typeDropDown addOption:typeData[kAccountTypeNameKey] forKey:typeData[kAccountTypeKeyName]];
    }
    
    [_submitButton setTitle:FLLocalizedString(@"button_submit") forState:UIControlStateNormal];
    
    // validation inits
    _validatorManager = [FLValidatorManager new];
    FLValiderRequired *inputRequiredValider = [FLValiderRequired validerWithHint:FLLocalizedString(@"valider_fillin_the_field")];
    FLValiderRequired *dropDownRequiredValider = [FLValiderRequired validerWithHint:FLLocalizedString(@"valider_select_an_option")];
    FLValiderEmail *inputEmailValider = [FLValiderEmail validerWithHint:FLLocalizedString(@"valider_proper_email_address")];
    FLValiderPasswordPolicy *passwordPolicyValider = [FLValiderPasswordPolicy validerWithHint:FLLocalizedString(@"valider_password_weak")];

    if (_showUserNameInput) {
        [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_userNameField withValider:@[inputRequiredValider]]];
    }

    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_passwordField withValider:@[inputRequiredValider, passwordPolicyValider]]];
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_emailField    withValider:@[inputRequiredValider, inputEmailValider]]];
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_typeDropDown  withValider:@[dropDownRequiredValider]]];

    // accessory toolbar
    if (!_showUserNameInput) {
        [_inputsMutableCollection removeObject:_userNameField];
    }
    _accessoryToolbar = [FLInputAccessoryToolbar toolbarWithInputItems:_inputsMutableCollection];
    
    // keyboard handler
    _keyboardHandler = [[FLKeyboardHandler alloc] initWithScroll:self.scrollView];
    _keyboardHandler.delegate = self;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropDownDidChange:) name:FLDropDownDidChangedNotification object:nil];
}

/*
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FLDropDownDidChangedNotification object:nil];
}

- (void)dropDownDidChange:(NSNotification *)notification {
    //TODO: change the form regarding to the selected account type.
    //NSString *selectedTypeKey = _typeDropDown.selectedOptionKey;
}
*/

- (void)submitForm {
    if ([_validatorManager validate]) {
        [flynaxAPIClient postApiItem:kApiItemRequests
                          parameters:@{@"cmd"      : kApiItemRequests_registration,
                                       @"username" : _userNameField.text,
                                       @"password" : _passwordField.text,
                                       @"email"    : _emailField.text,
                                       @"type"     : _typeDropDown.selectedOptionKey}

                          completion:^(NSDictionary *result, NSError *error) {
                              if (error == nil && [result isKindOfClass:NSDictionary.class]) {
                                  if (FLTrueBool(result[kApiResultSuccessKey])) {

                                      [self.navigationController dismissViewControllerAnimated:YES completion:^{
                                          // auto-login and move to my profile
                                          if (result[kApiResultLoggedKey] && result[kApiResultProfileKey]) {
                                              [[FLAccount loggedUser] saveSessionData:result];
                                              [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSimulateLogin object:nil];
                                          }

                                          [[[UIAlertView alloc] initWithTitle:FLLocalizedString(@"alert_title_congratulations")
                                                                      message:FLLocalizedString(result[kApiResultMessageKey])
                                                                     delegate:nil cancelButtonTitle:nil
                                                            otherButtonTitles:FLLocalizedString(@"button_alert_ok"), nil] show];
                                      }];
                                  }
                                  else [FLProgressHUD showErrorWithStatus:result[kApiResultErrorKey]];
                              }
                              else [FLDebug showAdaptedError:error apiItem:kApiItemRequests_addComment];
                          }];
    }
}

- (void)setShowUserNameInput:(BOOL)show {
    _userNameField.enabled       = show;
    _userNameField.hidden        = !show;
    _emailTopConstraint.constant = show ? 74 : 15;
    _showUserNameInput           = show;
}

- (void)setShowPersonalAddress:(BOOL)show {
    _personalAddress.hidden = !show;
}

#pragma mark - FLKeyboardHandler delegate

- (void)keyboardHandlerDidHideKeyboard {
    if (_afterKeyboardDismiss) {
        [self dismiss];
    }
}

#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_accessoryToolbar goToNextItem];
    return YES;
}

#pragma mark - Navigation

- (IBAction)submitButtonDidTap:(UIButton *)sender {
    [self submitForm];
}

- (IBAction)dissmissViewController:(UIBarButtonItem *)sender {
    _afterKeyboardDismiss = _keyboardHandler.isKeyboardOn;

    if (_afterKeyboardDismiss) {
        [self.view endEditing:YES];
    }
    else [self dismiss];
}

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
