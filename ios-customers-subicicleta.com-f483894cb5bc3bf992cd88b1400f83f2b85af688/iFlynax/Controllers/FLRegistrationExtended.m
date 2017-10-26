//
//  FLRegistrationExtended.m
//  iFlynax
//
//  Created by Alex on 10/20/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import "FLRegistrationExtended.h"
#import "FLTableViewManager.h"

#import "FLInputAccessoryToolbar.h"
#import "FLValidatorManager.h"
#import "FLTextField.h"
#import "FLDropDown.h"

static NSString * const kAccountTypeKeyName   = @"key";
static NSString * const kAccountTypeNameKey   = @"name";
static NSString * const kAccountTypeFields    = @"fields";

static NSString * const kApiResultSuccessKey  = @"success";
static NSString * const kApiResultMessageKey  = @"message_key";
static NSString * const kApiResultErrorKey    = @"error";
static NSString * const kApiResultLoggedKey   = @"logged";
static NSString * const kApiResultProfileKey  = @"profile";

static CGFloat    const kPaddingBetweenFields = 15;
static CGFloat    const kInputFieldsHeight    = 44;

@interface FLRegistrationExtended () <RETableViewManagerDelegate> {
    FLInputAccessoryToolbar *_accessoryToolbar;
    NSMutableArray *_inputsMutableCollection;
    NSArray *_twoStepAccountFields;
    NSArray *_accountTypes;
}
@property (weak, nonatomic) IBOutlet UIView      *tableHeaderView;
@property (weak, nonatomic) IBOutlet FLTextField *userNameField;
@property (weak, nonatomic) IBOutlet FLTextField *emailField;
@property (weak, nonatomic) IBOutlet FLTextField *passwordField;
@property (weak, nonatomic) IBOutlet FLDropDown  *typeDropDown;
@property (weak, nonatomic) IBOutlet UIButton    *submitButton;

@property (strong, nonatomic) IBOutletCollection(id) NSArray *inputsCollection;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint    *emailTopConstraint;

@property (strong, nonatomic) FLValidatorManager *validatorManager;
@property (strong, nonatomic) FLTableViewManager *formManager;
@property (strong, nonatomic) NSString           *accountTypeKey;

@property (nonatomic) BOOL showUserNameInput;
@end

@implementation FLRegistrationExtended

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = FLLocalizedString(@"screen_registration");
    self.tableView.backgroundColor = FLHexColor(kColorBackgroundColor);
    self.navigationItem.leftBarButtonItem.title = FLLocalizedString(@"button_cancel");

    _formManager = [FLTableViewManager withTableView:self.tableView];
    _formManager.delegate = self;

    _twoStepAccountFields = @[];
    _accountTypes = [FLAccountTypes getList];
    _inputsMutableCollection = [_inputsCollection mutableCopy];

    self.showUserNameInput = [FLAccount loginModeIs:FLAccountLoginModeUsername];

    // init form controls
    [_submitButton setTitle:FLLocalizedString(@"button_submit") forState:UIControlStateNormal];
    _typeDropDown.title        = FLLocalizedString(@"dropdown_title_account_types");
    _userNameField.placeholder = FLLocalizedString(@"placeholder_username");
    _passwordField.placeholder = FLLocalizedString(@"placeholder_password");
    _emailField.placeholder    = FLLocalizedString(@"placeholder_email");

    for (NSDictionary *typeData in _accountTypes) {
        [_typeDropDown addOption:typeData[kAccountTypeNameKey] forKey:typeData[kAccountTypeKeyName]];
    }

    // validation inits
    FLValiderRequired *inputRequiredValider = [FLValiderRequired validerWithHint:FLLocalizedString(@"valider_fillin_the_field")];
    FLValiderRequired *dropDownRequiredValider = [FLValiderRequired validerWithHint:FLLocalizedString(@"valider_select_an_option")];
    FLValiderEmail *inputEmailValider = [FLValiderEmail validerWithHint:FLLocalizedString(@"valider_proper_email_address")];
    FLValiderPasswordPolicy *passwordPolicyValider = [FLValiderPasswordPolicy validerWithHint:FLLocalizedString(@"valider_password_weak")];

    _validatorManager = [FLValidatorManager new];

    if (_showUserNameInput) {
        [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_userNameField withValider:@[inputRequiredValider]]];
    }

    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_emailField    withValider:@[inputRequiredValider, inputEmailValider]]];
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_passwordField withValider:@[inputRequiredValider, passwordPolicyValider]]];
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_typeDropDown  withValider:@[dropDownRequiredValider]]];

    // accessory toolbar
    if (!_showUserNameInput) {
        [_inputsMutableCollection removeObject:_userNameField];
        _tableHeaderView.height -= (kInputFieldsHeight + kPaddingBetweenFields);
    }
    _accessoryToolbar = [FLInputAccessoryToolbar toolbarWithInputItems:_inputsMutableCollection];

    if (kFeatureExtendedRegistration == YES) {
        __unsafe_unretained typeof(self) weakSelf = self;
        _accessoryToolbar.didDoneTapBlock = ^(id activeItem) {
            if (activeItem == weakSelf.typeDropDown) {
                if (weakSelf.typeDropDown.selected ) {
                    if (weakSelf.typeDropDown.selectedOptionKey != weakSelf.accountTypeKey) {
                        weakSelf.accountTypeKey = weakSelf.typeDropDown.selectedOptionKey;
                        NSArray *accountTypeFields = [FLAccountTypes withKey:weakSelf.accountTypeKey][kAccountTypeFields];

                        if (accountTypeFields && accountTypeFields.count) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                _twoStepAccountFields = accountTypeFields;
                                [weakSelf buildTwoStepForm];
                            });
                        } else {
                            [weakSelf clearTwoStepForm];
                        }
                    }
                } else {
                    [weakSelf clearTwoStepForm];
                }
            }
        };
    }
}

- (void)setShowUserNameInput:(BOOL)show {
    _userNameField.enabled       = show;
    _userNameField.hidden        = !show;
    _emailTopConstraint.constant = show ? 74 : kPaddingBetweenFields;
    _showUserNameInput           = show;
}

#pragma mark - Dynamic two-step form

- (void)clearTwoStepForm {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_formManager removeAllSections];
        [self.tableView reloadData];
    });
}

- (void)buildTwoStepForm {
    RETableViewSection *formSection = [RETableViewSection section];

    [_formManager removeAllSections];
    [_formManager addSection:formSection];

    for (NSDictionary *fieldDict in _twoStepAccountFields) {
        FLFieldModel *field = [FLFieldModel fromDictionary:fieldDict];
        RETableViewItem *item = nil;

        if (field.type == FLFieldTypeText) {
            item = [FLFieldText fromModel:field];
        }
        else if (field.type == FLFieldTypeSelect) {
            item = [FLFieldSelect fromModel:field tableView:self.tableView];
        }
        else if (field.type == FLFieldTypeBool) {
            item = [FLFieldBool fromModel:field];
        }
        else if (field.type == FLFieldTypeDate) {
            item = [FLFieldDate fromModel:field];
        }
        else if (field.type == FLFieldTypeNumber) {
            item = [FLFieldNumber fromModel:field];
        }
        else if (field.type == FLFieldTypeTextarea) {
            item = [FLFieldTextArea fromModel:field];
        }
        else if (field.type == FLFieldTypeMixed
                 || field.type == FLFieldTypePrice)
        {
            item = [FLFieldMixed fromModel:field];
        }
        else if (field.type == FLFieldTypeRadio) {
            item = [FLFieldRadio fromModel:field tableView:self.tableView];
        }
        else if (field.type == FLFieldTypePhone) {
            item = [FLFieldPhone fromModel:field];
        }
        else if (field.type == FLFieldTypeAccept) {
            item = [FLFieldAccept fromModel:field parentVC:self];
        }
        else if (field.type == FLFieldTypeCheckbox) {
            item = [FLFieldCheckbox fromModel:field parentVC:self];
        }

        if (item != nil) {
            [formSection addItem:item];
        }
    }
    [self.tableView reloadData];
}

- (void)postFormToAPIWithData:(NSDictionary *)data {
    [FLProgressHUD showWithStatus:FLLocalizedString(@"loading")];

    [flynaxAPIClient postApiItem:kApiItemRequests
                      parameters:@{@"cmd"      : kApiItemRequests_registration,
                                   @"username" : _userNameField.text,
                                   @"password" : _passwordField.text,
                                   @"email"    : _emailField.text,
                                   @"type"     : _typeDropDown.selectedOptionKey,
                                   @"account"  : data}
     
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
                                  [FLProgressHUD dismiss];
                              }
                              else [FLProgressHUD showErrorWithStatus:result[kApiResultErrorKey]];
                          }
                          else [FLDebug showAdaptedError:error apiItem:kApiItemRequests_addComment];
                      }];
}

#pragma mark - RETableViewManagerDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    RETableViewSection *section = _formManager.sections[indexPath.section];
    FLTableViewItem *item = section.items[indexPath.row];

    if ([item isKindOfClass:FLFieldCheckbox.class]) {
        cell.backgroundColor = [UIColor clearColor];
        UIImage *accessoryImage = [UIImage imageNamed:@"select_icon"];
        cell.accessoryView = [[UIImageView alloc] initWithImage:accessoryImage];
    }
}

#pragma mark - Navigation

- (IBAction)submitBtnTapped:(UIButton *)sender {
    if ([_validatorManager validate]) { // validate first-step form
        if ([_formManager isValidForm] && _formManager.formAccepted) {  // validate two-step form
            [self postFormToAPIWithData:_formManager.formValues];
        }
        else if (!_formManager.formAccepted) {
            [FLProgressHUD showErrorWithStatus:[FLFieldAccept agreeFieldRequiredMessage:_formManager.fieldAcceptTitle]];
        }
        else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"fill_required_fields")];
    }
    [self.tableView reloadData];
}

- (IBAction)cancelBtnDidTap:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
