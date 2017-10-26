//
//  FLLoginForm.m
//  iFlynax
//
//  Created by Alex on 11/17/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLLoginForm.h"
#import "FLAttributedLabel.h"
#import "REFrostedViewController.h"
#import "FLMainNavigation.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "FLKeyboardHandler.h"
#import "FLTextField.h"
#import "FLInputAccessoryToolbar.h"
#import "FLValidatorManager.h"
#import "FLRemoteNotifications.h"

static NSString * const kLinkSearchPattern    = @"\\[(.*)\\]";
static NSString * const kFakeLinkRemind       = @"remind";
static CGFloat    const topMargin             = 16.0f;

typedef void (^searchLinksResultBlock)(NSRange range, NSString *resultString);

@interface FLLoginForm () {
	BOOL fbAuthUse;
    FLInputAccessoryToolbar *_accessoryToolbar;
}

@property (weak, nonatomic) IBOutlet UIButton           *fbLoginButton;
@property (weak, nonatomic) IBOutlet UIButton           *loginButton;
@property (weak, nonatomic) IBOutlet UIButton           *registrationBtn;
@property (weak, nonatomic) IBOutlet UILabel            *orLabel;
@property (weak, nonatomic) IBOutlet FLTextField        *usernameField;
@property (weak, nonatomic) IBOutlet FLTextField        *passwordField;
@property (weak, nonatomic) IBOutlet FLAttributedLabel  *remindPasswordLabel;
@property (weak, nonatomic) IBOutlet UIScrollView       *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMargin;

@property (strong, nonatomic) FLKeyboardHandler *keyboardHandler;
@property (strong, nonatomic) FLValidatorManager *validatorManager;

@end

@implementation FLLoginForm

#pragma mark - Live circle

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = FLLocalizedString(@"screen_login_form");
	self.view.backgroundColor = FLHexColor(kColorBackgroundColor);

    // init form controls
    NSString *loginModePlaceholder = FLLocalizedString(@"placeholder_username");
    if ([FLAccount loginModeIs:FLAccountLoginModeEmail]) {
        _usernameField.keyboardType = UIKeyboardTypeEmailAddress;
        loginModePlaceholder = FLLocalizedString(@"placeholder_email");
        _usernameField.keyboardType = UIKeyboardTypeEmailAddress;
    }

    [_fbLoginButton setTitle:FLLocalizedString(@"button_facebook_login") forState:UIControlStateNormal];
    [_loginButton setTitle:FLLocalizedString(@"button_login") forState:UIControlStateNormal];

	_usernameField.placeholder = loginModePlaceholder;
	_passwordField.placeholder = FLLocalizedString(@"placeholder_password");

    NSDictionary *_linkAttributes = @{NSForegroundColorAttributeName : FLHexColor(kColorThemeLinks),
                                      NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle)};
    NSAttributedString *_string = [[NSAttributedString alloc] initWithString:FLLocalizedString(@"button_loginForm_registration")
                                                                  attributes:_linkAttributes];
    [_registrationBtn setAttributedTitle:_string forState:UIControlStateNormal];

    _orLabel.text = FLLocalizedString(@"label_or");
    fbAuthUse = [FLConfig boolWithKey:@"facebook_login"];

	[self searchLinksAsPatternInString:FLLocalizedString(@"label_loginForm_reset_password")
							  useBlock:^(NSRange range, NSString *resultString) {
								  @try {
									  _remindPasswordLabel.text = resultString;
									  [_remindPasswordLabel addLinkToURL:URLIFY(@"remind") withRange:range];
								  }
								  @catch (NSException *exception) {}
								  @finally {}
							  }];

    if (!fbAuthUse) {
        _topMargin.constant = topMargin;
        _fbLoginButton.hidden = YES;
        _orLabel.hidden = YES;
    }
    
    // validation
    _validatorManager = [FLValidatorManager new];
    FLValiderRequired *inputRequiredValider = [FLValiderRequired validerWithHint:FLLocalizedString(@"valider_fillin_the_field")];
    
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_usernameField withValider:@[inputRequiredValider]]];
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_passwordField withValider:@[inputRequiredValider]]];
    
    // accessory toolbar
    _accessoryToolbar = [FLInputAccessoryToolbar toolbarWithInputItems:@[_usernameField, _passwordField]];
    __unsafe_unretained typeof(self) weakSelf = self;
    _accessoryToolbar.didDoneTapBlock = ^(id activeItem) {
        if (activeItem == _passwordField) {
            [weakSelf submitForm];
        }
    };
    
    // keyboard handler
    _keyboardHandler = [[FLKeyboardHandler alloc] initWithScroll:self.scrollView];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(switchToMyProfileScreen)
                                                 name:kNotificationSimulateLogin
                                               object:nil];
}

- (void)setSuccessBlock:(dispatch_block_t)successBlock {
    _successBlock = successBlock;
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	self.screenName = self.title;
	[super viewDidAppear:animated];
}

#pragma mark - button actions

- (void)switchToMyProfileScreen {
    [FLRemoteNotifications registerDevice];

    FLMainNavigation *nc = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardContentController];
    nc.viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardMyProfileRootView]];
    self.frostedViewController.contentViewController = nc;
}

- (IBAction)facebookButtonTapped:(UIButton *)sender {
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];

    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    login.loginBehavior = FBSDKLoginBehaviorNative;

    [login logInWithReadPermissions:@[@"email"]
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                if (error) {
                                    // This error already was displayed in separate FB window.
                                }
                                else if (result.isCancelled) {
                                    [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"alert_facebook_user_cancelled_login")];
                                }
                                else {
                                    if ([result.grantedPermissions containsObject:@"email"]) {
                                        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                                                      initWithGraphPath:@"/me"
                                                                      parameters:@{@"fields": @"id,email,verified,first_name,last_name"}
                                                                      HTTPMethod:@"GET"];
                                        
                                        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, NSDictionary *result, NSError *error) {
                                            if (!error && result[@"email"] != nil) {
                                                [self loginWithFacebookProfile:result];
                                            }
                                            else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"alert_facebook_user_login_fail")];
                                        }];
                                    }
                                    else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"alert_facebook_user_login_fail")];
                                }
                            }];
}

- (void)loginWithFacebookProfile:(NSDictionary *)profile {
    BOOL deviceIsRegistered = [FLRemoteNotifications isRegisteredForRemoteNotifications];

	[FLProgressHUD showWithStatus:FLLocalizedString(@"loading")];
	[flynaxAPIClient postApiItem:kApiItemLogin
					  parameters:@{@"action"    : kApiItemLogin_fb,
								   @"email"     : profile[@"email"],
								   @"fid"       : profile[@"id"],
                                   @"verified"  : @(FLTrueBool(profile[@"verified"])),
                                   @"first_name": FLCleanString(profile[@"first_name"]),
                                   @"last_name" : FLCleanString(profile[@"last_name"]),
                                   @"favorites" : [FLFavorites allFavoritesAsString],
                                   @"push_token": [FLRemoteNotifications deviceTokenForRemoteNotifications]}

					  completion:^(id result, NSError *error) {
						  if (error == nil) {
							  [self loginHandlerWithResponse:result registerDevice:deviceIsRegistered];
						  }
						  else [FLDebug showAdaptedError:error apiItem:kApiItemLogin];
					  }];
}

- (IBAction)loginButtonTapped:(UIButton *)sender {
    [self submitForm];
}

- (void)submitForm {
    if ([_validatorManager validate]) {
        BOOL deviceIsRegistered = [FLRemoteNotifications isRegisteredForRemoteNotifications];

        [FLProgressHUD showWithStatus:FLLocalizedString(@"loading")];
        [flynaxAPIClient postApiItem:kApiItemLogin
                          parameters:@{@"action"    : kApiItemLogin_default,
                                       @"username"  : _usernameField.text,
                                       @"password"  : _passwordField.text,
                                       @"favorites" : [FLFavorites allFavoritesAsString],
                                       @"push_token": [FLRemoteNotifications deviceTokenForRemoteNotifications]}

                          completion:^(id result, NSError *error) {
                              if (error == nil) {
                                  [self loginHandlerWithResponse:result registerDevice:deviceIsRegistered];
                              }
                              else [FLDebug showAdaptedError:error apiItem:kApiItemLogin];
                          }];
    }
}

- (void)loginHandlerWithResponse:(id)response registerDevice:(BOOL)registerDevice {
	if (![response isKindOfClass:NSDictionary.class]) {
		[FLProgressHUD showErrorWithStatus:FLLocalizedString(@"unknown_error")];
		return;
	}
	NSDictionary *result = response;

	if (result[@"error"] != nil) {
		[FLProgressHUD showErrorWithStatus:FLCleanString(result[@"error"])];
	}
	else if (result[@"logged"] != nil && [result[@"logged"] boolValue]) {
		[FLProgressHUD showSuccessWithStatus:FLLocalizedString(@"alert_login_success")];
        [[FLAccount loggedUser] saveSessionData:result];

        // register device for remote Notifications if necessary
        if (!registerDevice) {
            [FLRemoteNotifications registerDevice];
        }

        // synchronize favorites
        if (result[@"favorites"] != nil) {
            [FLFavorites synchronizeFavorites:result[@"favorites"]];
        }

        if (self.successBlock != nil) {
            [self.navigationController popViewControllerAnimated:YES];
            self.successBlock();
        }
        else {
            [self switchToMyProfileScreen];
        }
	}
	else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"unknown_error")];
}

#pragma mark - helpers

- (void)searchLinksAsPatternInString:(NSString *)string useBlock:(searchLinksResultBlock)resultBlock {
	NSRange linkRange = [string rangeOfString:kLinkSearchPattern options:NSRegularExpressionSearch];
	linkRange = NSMakeRange(linkRange.location, linkRange.length - 2);
	NSString *resultString = [string stringByReplacingOccurrencesOfString:kLinkSearchPattern
															   withString:@"$1"
																  options:NSRegularExpressionSearch
																	range:NSMakeRange(0, string.length)];
	if (resultBlock != nil)
		resultBlock(linkRange, resultString);
}

#pragma mark - Navigation

- (void)presentViewControllerWithIdentifier:(NSString *)identifier {
    UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)attributedLabel:(FLAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
	if ([url.description isEqualToString:kFakeLinkRemind]) {
        [self presentViewControllerWithIdentifier:kStoryBoardRemindPasswordVC];
	}
}

- (IBAction)registrationBtnDidTap:(UIButton *)sender {
    [self presentViewControllerWithIdentifier:kStoryBoardRegistrationExtendedNC];
}

- (IBAction)showSideMenu:(UIBarButtonItem *)sender {
	[self.frostedViewController presentMenuViewController];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _usernameField) {
        [_accessoryToolbar goToNextItem];
    }
    else if (textField == _passwordField) {
        [self submitForm];
    }
    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationSimulateLogin object:nil];
    [_keyboardHandler unRegisterNotifications];
}

@end
