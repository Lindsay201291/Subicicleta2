//
//  FLDemoVC.m
//  iFlynax
//
//  Created by Exe on 1/2/13.
//  Copyright (c) 2013 Flynax. All rights reserved.
//

#import "REFrostedViewController.h"
#import "FLInputAccessoryToolbar.h"
#import "FLValidatorManager.h"
#import "FLKeyboardHandler.h"
#import "CCActionSheet.h"
#import "FLTextField.h"
#import "FLDemoVC.h"
#import "FLRootView.h"

static NSString * const kApiPingRequestKey = @"ping";

@interface FLDemoVC () <FLKeyboardHandlerDelegate> {
    FLInputAccessoryToolbar *_accessoryToolbar;
}
@property (weak, nonatomic) IBOutlet FLTextField *domainTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) FLKeyboardHandler *keyboardHandler;
@property (strong, nonatomic) FLValidatorManager *validatorManager;
@end

@implementation FLDemoVC

- (void)viewDidLoad {
	[super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"demoVCbackground"]];
    _domainTextField.placeholder = NSLocalizedString(@"enter_domain_name", nil);

    // validation inits
    _validatorManager = [FLValidatorManager new];
    NSString *urlValiderHint = F(@"%@\n%@", NSLocalizedString(@"valider_incorrect_url", nil), @"Example:\nhttp(s)://www.example.com\nwww.example.com");
    FLValiderURL *urlValider = [FLValiderURL validerWithHint:urlValiderHint];
    urlValider.autoValidated = NO;
    urlValider.autoHinted    = NO;
    [_validatorManager addValidator:[FLInputControlValidator validerWithInputControll:_domainTextField withValider:@[urlValider]]];

    _accessoryToolbar = [FLInputAccessoryToolbar toolbarWithInputItems:@[_domainTextField]];

    __unsafe_unretained typeof(self) weakSelf = self;
    _accessoryToolbar.didDoneTapBlock = ^(id activeItem) {
        [weakSelf checkDomainAndSaveIfValid];
    };

    // keyboard handler
    _keyboardHandler = [[FLKeyboardHandler alloc] initWithScroll:_scrollView];
    _keyboardHandler.delegate = self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)checkDomainAndSaveIfValid {
    if (_validatorManager.validate) {
        NSURL *candidateDomain = [NSURL URLWithString:_domainTextField.text];
        if (candidateDomain.scheme == nil) {
            candidateDomain = [[NSURL alloc] initWithScheme:@"http" host:_domainTextField.text path:@"/"];
        }

        // prevent "/" at end of the domain
        NSRange range = [candidateDomain.absoluteString rangeOfString:@"\\/+$" options:NSRegularExpressionSearch];
        if (range.length) {
            candidateDomain = URLIFY([candidateDomain.absoluteString stringByReplacingCharactersInRange:range withString:@""]);
        }

        [self saveValidDomainAndContinueToInitialApp:candidateDomain.absoluteString demoPackage:NO];
    }
}

- (void)dryRunConnectionToAPI:(NSString *)domain {
    [FLProgressHUD showWithStatus:NSLocalizedString(@"processing", nil)];

    flynaxAPIClient *apiClient = [flynaxAPIClient sharedInstance];
    NSString *websiteUrl = F(@"%@/plugins/iFlynaxConnect/%@", domain, kApiItemUrl);
    NSDictionary *params = [apiClient requestParametersForItem:nil withParameters:@{kApiPingRequestKey: @(YES)}];

    [apiClient POST:websiteUrl
    parameters:params success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        switch (((NSHTTPURLResponse *)task.response).statusCode) {
            case 200:
                if (response && [response isKindOfClass:NSDictionary.class] && FLTrueBool(response[@"available"])) {
                    if ([self versionsIsCompatible:response]) {
                        [self pointToDomain:domain];
                    }
                }
                else {
                    [self displayHostUnavailable];
                }
                break;

            default:
                [self displayHostUnavailable];
                break;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self displayHostUnavailable];
    }];
}

- (void)pointToDomain:(NSString *)domain {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[FLAccount loggedUser] resetSessionData];
    [FLUserDefaults pointToDomain:domain];
    [FLCache refreshAppCache];

    [[UIApplication sharedApplication].delegate performSelector:@selector(setupAdditionalAppServices)];

    NSBundle *maniBundle         = [NSBundle mainBundle];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:maniBundle.infoDictionary[@"UIMainStoryboardFile"] bundle:maniBundle];
    UIViewController *contentVC  = [mainStoryboard instantiateViewControllerWithIdentifier:@"contentController"];
    UIViewController *menuVC     = [mainStoryboard instantiateViewControllerWithIdentifier:@"menuController"];

    FLRootView *rootVC = [[FLRootView alloc] initWithContentViewController:contentVC menuViewController:menuVC];
    [[UIApplication sharedApplication] keyWindow].rootViewController = rootVC;
}

- (void)displayHostUnavailable {
    [self displayAlertWithTitle:@"host_unavailable"];
}

- (void)displayAlertWithTitle:(NSString *)titleKey {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:NSLocalizedString(titleKey, nil)
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"button_ok", nil), nil];
    [FLProgressHUD dismiss];
    [alert show];
}

- (BOOL)versionsIsCompatible:(NSDictionary *)versions {
    NSString *minAppVersion     = FLTrueString(versions[@"app_version"]);
    NSString *currentAPIVersion = FLTrueString(versions[@"version"]);
    NSString *currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

    if ([kMinAPIVersion compare:currentAPIVersion options:NSNumericSearch] == NSOrderedDescending) {
        [self displayAlertWithTitle:@"required_to_update_plugin"];
        return NO;
    }
    else if ([minAppVersion compare:currentAppVersion options:NSNumericSearch] == NSOrderedDescending) {
        [self displayAlertWithTitle:@"required_to_update_app"];
        return NO;
    }
    return YES;
}

- (void)saveValidDomainAndContinueToInitialApp:(NSString *)domain demoPackage:(BOOL)demoPackage {
    if (demoPackage) {
        NSString *demoDomain = F(@"https://%@.demoflynax.com", domain);
        [self dryRunConnectionToAPI:demoDomain];
    }
    else {
        [self dryRunConnectionToAPI:domain];
    }
}

#pragma mark - Navigation

- (IBAction)goBtnDidTap:(UIButton *)sender {
    [self checkDomainAndSaveIfValid];
}

- (IBAction)tryDemoDidTap:(UIButton *)sender {
    NSArray *packages = @[@"classifieds", @"auto", @"realty", @"boats", @"pets"];

    CCActionSheet *sheet = [[CCActionSheet alloc] initWithTitle:NSLocalizedString(@"select_demo_package", nil)];

    for (NSString *package in packages) {
        [sheet addButtonWithTitle:NSLocalizedString(F(@"package_%@", package), nil) block:^{
            [self saveValidDomainAndContinueToInitialApp:package demoPackage:YES];
        }];
    }

    [sheet addCancelButtonWithTitle:NSLocalizedString(@"button_cancel", nil)];
    [sheet showFromRect:sender.frame inView:self.view animated:YES];
}

@end
