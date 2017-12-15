//
//  FLRegistrationExtended.m
//  iFlynax
//
//  Created by Alex on 10/20/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import "FLRegistrationExtended.h"
#import "FLViewController.h"
#import "FLTableViewManager.h"
#import "FLEditProfileRegisterView.h"
#import "FLInputAccessoryToolbar.h"
#import "FLValidatorManager.h"
#import "FLTextField.h"
#import "FLDropDown.h"
#import "FLRemoteNotifications.h"

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
    NSArray *_accountTypes;
}

@property (weak, nonatomic) IBOutlet UIView      *tableHeaderView;
@property (weak, nonatomic) IBOutlet FLTextField *userNameField;
@property (weak, nonatomic) IBOutlet FLTextField *emailField;
@property (weak, nonatomic) IBOutlet FLTextField *passwordField;
@property (weak, nonatomic) IBOutlet FLTextField *rePasswordField;
@property (weak, nonatomic) IBOutlet FLDropDown  *typeDropDown;
@property (weak, nonatomic) IBOutlet UIButton    *submitButton;
@property (strong, nonatomic) IBOutletCollection(id) NSArray *inputsCollection;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint    *emailTopConstraint;
@property (strong, nonatomic) FLValidatorManager *validatorManager;
@property (strong, nonatomic) FLTableViewManager *formManager;
@property (strong, nonatomic) NSString           *accountTypeKey;
@property (nonatomic) NSString *record_type;
@property (nonatomic) NSString *record_mail;
@property (nonatomic) NSString *record_nick;
@property (nonatomic) BOOL showUserNameInput;
@end

@implementation FLRegistrationExtended

- (void)viewDidLoad {
    [super viewDidLoad];

    if (![self.emailField.text isEqual: @""]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
    self.title = FLLocalizedString(@"screen_registro");
    self.tableView.backgroundColor = FLHexColor(kColorBackgroundColor);
    self.navigationItem.leftBarButtonItem.title = FLLocalizedString(@"button_cancelar");

    _formManager = [FLTableViewManager withTableView:self.tableView];
    _formManager.delegate = self;

    _accountTypes = [FLAccountTypes getList];
    _inputsMutableCollection = [_inputsCollection mutableCopy];

    self.showUserNameInput = [FLAccount loginModeIs:FLAccountLoginModeUsername];

    // init form controls
    [_submitButton setTitle:FLLocalizedString(@"button_paso_siguiente") forState:UIControlStateNormal];
    _typeDropDown.title        = FLLocalizedString(@"dropdown_titulo_tipos_cuenta");
    _userNameField.placeholder = FLLocalizedString(@"placeholder_usuario");
    _passwordField.placeholder = FLLocalizedString(@"placeholder_contraseña");
    _rePasswordField.placeholder = FLLocalizedString(@"placeholder_verificar_contraseña");
    _emailField.placeholder    = FLLocalizedString(@"placeholder_email");

    for (NSDictionary *typeData in _accountTypes) {
        [_typeDropDown addOption:typeData[kAccountTypeNameKey] forKey:typeData[kAccountTypeKeyName]];
    }

    // validation inits
    FLValiderRequired *inputRequiredValider = [FLValiderRequired validerWithHint:FLLocalizedString(@"valider_fillin_the_field")];
    FLValiderRequired *dropDownRequiredValider = [FLValiderRequired validerWithHint:FLLocalizedString(@"valider_select_an_option")];
    FLValiderEmail *inputEmailValider = [FLValiderEmail validerWithHint:FLLocalizedString(@"valider_proper_email_address")];
    FLValiderPasswordPolicy *passwordPolicyValider = [FLValiderPasswordPolicy validerWithHint:FLLocalizedString(@"valider_password_weak")];
    FLValiderEqualInput *equalInputValider = [FLValiderEqualInput validerWithControl:_passwordField withHint:FLLocalizedString(@"alert_password_does_not_match")];
    _validatorManager = [FLValidatorManager new];

    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_userNameField withValider:@[inputRequiredValider]]];
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_emailField    withValider:@[inputRequiredValider, inputEmailValider]]];
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_passwordField withValider:@[inputRequiredValider, passwordPolicyValider]]];
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_rePasswordField withValider:@[inputRequiredValider, passwordPolicyValider]]];
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll: _rePasswordField  withValider:@[inputRequiredValider, equalInputValider]]];
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_typeDropDown  withValider:@[dropDownRequiredValider]]];
    
    // accessory toolbar
    if (!_showUserNameInput) {
        [_inputsMutableCollection removeObject:_userNameField];
        _tableHeaderView.height -= (kInputFieldsHeight + kPaddingBetweenFields);
    }
    _accessoryToolbar = [FLInputAccessoryToolbar toolbarWithInputItems:_inputsMutableCollection];
}

#pragma mark - Dynamic two-step form

- (void)completar_registro
{
    [self performSegueWithIdentifier:@"editProfileRegisterSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    FLEditProfileRegisterView* controller =
    (FLEditProfileRegisterView*)[[segue destinationViewController] topViewController];
    [controller setRegType:_record_type];
    [controller setRegMail:_record_mail];
    [controller setRegNick:_record_nick];
    [controller setParentVC:self];
}

- (void)postFormToAPIWithData:(NSDictionary *)data {
  
    [FLProgressHUD showWithStatus:FLLocalizedString(@"cargando")];
    
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
                                  [FLProgressHUD dismiss];
                                  [self completar_registro];
                              }
                              else { [FLProgressHUD showErrorWithStatus:result[kApiResultErrorKey]];
                              }
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
    self.record_type= _typeDropDown.selectedOptionKey;
    self.record_mail= _emailField.text;
    self.record_nick= _userNameField.text;
    
    if ([_validatorManager validate]) {
        if ([_formManager isValidForm] && _formManager.formAccepted) {
            [self postFormToAPIWithData:_formManager.formValues];
        }
        else if (!_formManager.formAccepted) {
            [FLProgressHUD showErrorWithStatus:[FLFieldAccept agreeFieldRequiredMessage:_formManager.fieldAcceptTitle]];
        }
        else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"fill_campos_requeridos")];
    }
}

- (IBAction)cancelBtnDidTap:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
