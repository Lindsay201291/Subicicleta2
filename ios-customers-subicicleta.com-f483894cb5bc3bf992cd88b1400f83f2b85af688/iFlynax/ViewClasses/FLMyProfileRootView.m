//
//  FLMyProfileRootView.m
//  iFlynax
//
//  Created by Alex on 12/11/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "REFrostedViewController.h"
#import "FLRemoteNotifications.h"
#import "FLMyProfileRootView.h"
#import "FLMainNavigation.h"
#import "CCActionSheet.h"

@implementation FLMyProfileRootView

- (void)awakeFromNib {
    [super awakeFromNib];

	self.gaScreenName = FLLocalizedString(@"screen_my_profile");
}

- (void)viewDidLoad {
	[super viewDidLoad];

    self.title = self.gaScreenName;

    // tabs
    [self setupPagesFromStoryboardWithIdentifiers:@[kStoryBoardMyProfileView,
                                                    kStoryBoardMyProfileChangePassword]];

	// it's tmp implementation
	UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:FLLocalizedString(@"button_logout")
																	 style:UIBarButtonItemStyleBordered
																	target:self action:@selector(logoutButtonTapped)];
	[self.navigationItem setRightBarButtonItem:logoutButton animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (void)logoutButtonTapped {
	CCActionSheet *sheet = [[CCActionSheet alloc] initWithTitle:F(FLLocalizedString(@"logged_as"), [FLAccount fullName])];
	[sheet addDestructiveButtonWithTitle:FLLocalizedString(@"button_logout") block:^{
        [FLProgressHUD showWithStatus:FLLocalizedString(@"loading")];

		[flynaxAPIClient postApiItem:kApiItemLogin
						  parameters:@{@"action"    : @"logout",
                                       @"favorites" : [FLFavorites allFavoritesAsString],
                                       @"push_token": [FLRemoteNotifications deviceTokenForRemoteNotifications]}

						  completion:^(NSDictionary *response, NSError *error) {
							  if (error == nil) {
								  if ([response isKindOfClass:NSDictionary.class] &&
									  response[@"unlogged"] != nil)
								  {
									  [self doLogout];
									  [FLProgressHUD showSuccessWithStatus:response[@"message"]];
								  }
							  }
							  else [FLDebug showAdaptedError:error apiItem:kApiItemLogin];
						  }];
	}];
	[sheet addCancelButtonWithTitle:FLLocalizedString(@"button_cancel")];
	[sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem];
}

- (void)doLogout {
	[[FLAccount loggedUser] resetSessionData];
    [FLRemoteNotifications unRegisterDevice];

	// TODO: make easier.. (3 lines below)
	FLMainNavigation *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardContentController];
	navigationController.viewControllers = @[[self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardLoginFormView]];
	self.frostedViewController.contentViewController = navigationController;
}

- (IBAction)showSideMenu:(UIBarButtonItem *)sender {
	[self.frostedViewController presentMenuViewController];
}

@end
