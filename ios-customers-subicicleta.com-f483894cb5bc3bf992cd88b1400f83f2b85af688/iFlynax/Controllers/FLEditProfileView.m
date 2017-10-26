//
//  FLEditProfileView.m
//  iFlynax
//
//  Created by Alex on 1/14/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLEditProfileHeader.h"
#import "FLTableViewManager.h"
#import "FLKeyboardHandler.h"
#import "FLEditProfileView.h"
#import "FLFieldModel.h"
#import "FLBlankSlate.h"
#import "CCAlertView.h"

static NSString * const kAccountTypeKeyName = @"key";
static NSString * const kAccountTypeNameKey = @"name";

@interface FLEditProfileView () <RETableViewManagerDelegate> {
    RETableViewSection *_section;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FLTableViewManager *manager;
@property (strong, nonatomic) FLKeyboardHandler  *keyboardHandler;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (strong, nonatomic) FLEditProfileHeader *profileHeader;
@end

@implementation FLEditProfileView

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = FLLocalizedString(@"screen_edit_profile");
	self.view.backgroundColor = FLHexColor(kColorBackgroundColor);
	[self.navigationItem.leftBarButtonItem setTitle:FLLocalizedString(@"button_cancel")];
    self.tableView.backgroundColor = self.view.backgroundColor;

    self.manager = [FLTableViewManager withTableView:self.tableView];
    self.manager.delegate = self;
    _keyboardHandler = [[FLKeyboardHandler alloc] initWithScroll:self.tableView];

    /* table header */
    _profileHeader = [[FLEditProfileHeader alloc] init];
    _profileHeader.usernameLabel.text = [FLAccount fullName];
    _profileHeader.emailLabel.text = [FLAccount userInfo:kUserInfoMail];
    self.tableView.tableHeaderView = _profileHeader;

    __unsafe_unretained typeof(self) weakSelf = self;
    _profileHeader.onTapEditMail = ^(UIButton *button) {
        BOOL changeEmailConfirm = [FLConfig boolWithKey:@"account_edit_email_confirmation"];

        NSString *alertMessage = FLLocalizedString(changeEmailConfirm
                                                   ? @"dialog_confirm_email_changing"
                                                   : @"dialog_email_changing");
        CCAlertView *alert = [[CCAlertView alloc] initWithTitle:nil message:alertMessage];

        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *emailField = [alert textFieldAtIndex:0];
        emailField.keyboardType = UIKeyboardTypeEmailAddress;

        [alert addButtonWithTitle:FLLocalizedString(@"button_cancel") block:nil];
        [alert addButtonWithTitle:FLLocalizedString(@"button_ok") block:^{
            [weakSelf updateProfileEmail:emailField.text];
        }];
        [alert show];
    };
    /* table header end */

    [_cancelBtn setTitle:FLLocalizedString(@"button_cancel") forState:UIControlStateNormal];
    [_submitBtn setTitle:FLLocalizedString(@"button_edit_profile") forState:UIControlStateNormal];
    [self actionsButtonHidden:YES];

    _section = [RETableViewSection section];
    [self.manager addSection:_section];

    [FLProgressHUD showWithStatus:FLLocalizedString(@"loading")];
    [flynaxAPIClient getApiItem:kApiItemMyProfile
                     parameters:@{@"action" : kApiItemMyProfile_profileForm,
                                  @"id"     : [NSNumber numberWithInteger:[FLAccount userId]],
                                  @"type"   : [FLAccount userInfo:@"type"][@"key"]}

                     completion:^(NSArray *response, NSError *error) {
                         if (error == nil && [response isKindOfClass:NSArray.class]) {
                             // account types
                             //[self appendAccountTypesSelectorToSection:_section];

                             // dynamic form
                             for (NSDictionary *fieldDict in response) {
                                 FLFieldModel *field = [FLFieldModel fromDictionary:fieldDict];
                                 RETableViewItem *item;

                                 if (field.type == FLFieldTypeText) {
                                     item = [FLFieldText fromModel:field];
                                 }
                                 else if (field.type == FLFieldTypeSelect) {
                                     item = [FLFieldSelect fromModel:field tableView:_tableView];
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
                                 else if (field.type == FLFieldTypeMixed ||
                                          field.type == FLFieldTypePrice)
                                 {
                                     item = [FLFieldMixed fromModel:field];
                                 }
                                 else if (field.type == FLFieldTypeRadio) {
                                     item = [FLFieldRadio fromModel:field tableView:_tableView];
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
                                 else {
                                     // skip another field types. (like: image,file)
                                     continue;
                                 }
                                 [_section addItem:item];
                             };

                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self actionsButtonHidden:NO];
                                 [_tableView reloadData];
                                 [FLProgressHUD dismiss];
                             });
                         }
                         else [FLDebug showAdaptedError:error apiItem:kApiItemMyProfile];
                     }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    RETableViewSection *section = self.manager.sections[indexPath.section];
    RETableViewItem *item = section.items[indexPath.row];

    if ([item isKindOfClass:FLFieldCheckbox.class]) {
        cell.backgroundColor = [UIColor clearColor];
        UIImage *accessoryImage = [UIImage imageNamed:@"select_icon"];
        cell.accessoryView = [[UIImageView alloc] initWithImage:accessoryImage];
    }
}

- (void)appendAccountTypesSelectorToSection:(RETableViewSection *)section {
    FLFieldModel *accountTypes = [[FLAccountTypes sharedInstance] buildValuesAsSelectField];
    FLFieldSelect *typesSelect = [FLFieldSelect fromModel:accountTypes tableView:_tableView];
    [section addItem:typesSelect];
}

- (void)actionsButtonHidden:(BOOL)hidden {
    CGFloat alpha = hidden ? 0.0 : 1.0;

    [UIView animateWithDuration:.3f animations:^{
        if (hidden || _section.items.count > 0) {
            _cancelBtn.alpha = _submitBtn.alpha = alpha;
        }
        _tableView.alpha = alpha;
    }];
}

- (void)updateProfileEmail:(NSString *)email {
    if (![email isEmpty] && [FLUtilities isValidEmail:email]) {
        [FLProgressHUD showWithStatus:FLLocalizedString(@"processing")];

        [flynaxAPIClient postApiItem:kApiItemMyProfile
                          parameters:@{@"action": kApiItemMyProfile_updateProfileEmail,
                                       @"email" : email}
                          completion:^(NSDictionary *result, NSError *error) {
                              if (!error && [result isKindOfClass:NSDictionary.class]) {
                                  if (FLTrueBool(result[@"success"])) {
                                      if (result[@"success_key"] != nil) {
                                          [FLProgressHUD showSuccessWithStatus:FLLocalizedString(result[@"success_key"])];
                                      } else {
                                          [FLProgressHUD dismiss];
                                      }
                                      _profileHeader.emailLabel.text = email;
                                  }
                                  else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"dialog_unable_save_data_on_server")];
                              }
                              else [FLDebug showAdaptedError:error apiItem:kApiItemMyProfile_updateProfileEmail];
                          }];
    }
    else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"valider_proper_email_address")];
}

#pragma mark - Navigation

- (IBAction)editProfileBtnDidTap:(UIButton *)sender {
    BOOL _validForm = self.manager.isValidForm;

    if (_validForm && !self.manager.formAccepted) {
        [FLProgressHUD showErrorWithStatus:[FLFieldAccept agreeFieldRequiredMessage:self.manager.fieldAcceptTitle]];

        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    }
    else if (!_validForm) {
        [_tableView reloadData];
        [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"fill_required_fields")];
    }
    else [self prepareprofileDataAndSendToAPI];
}

- (void)prepareprofileDataAndSendToAPI {
    NSDictionary *data = @{@"action": kApiItemMyProfile_updateProfile,
                           @"f"     : self.manager.formValues};

    [FLProgressHUD showWithStatus:FLLocalizedString(@"processing")];

    [flynaxAPIClient postApiItem:kApiItemMyProfile
                      parameters:data
                      completion:^(NSDictionary *response, NSError *error) {
                          if (!error && [response isKindOfClass:NSDictionary.class]) {
                              if (FLTrueBool(response[@"success"])) {
                                  [FLProgressHUD showSuccessWithStatus:FLLocalizedString(@"profile_updated")];
                                  [self dismissViewControllerAnimated:YES completion:self.completionBlock];
                              }
                              else [FLProgressHUD showErrorWithStatus:FLLocalizedString(response[@"error_message_key"])];
                          }
                          else [FLDebug showAdaptedError:error apiItem:kApiItemMyProfile_updateProfile];
                      }];
}

- (IBAction)cancelEditProfileButtonTapped:(UIButton *)sender {
    [flynaxAPIClient cancelAllTasks];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
