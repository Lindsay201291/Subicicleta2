//
//  FLMyProfileView.m
//  iFlynax
//
//  Created by Alex on 11/20/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLMyProfileView.h"
#import "REFrostedViewController.h"
#import "UIImageView+AFNetworking.h"
#import "FLProfileTableViewCell.h"
#import "FLInfoTileView.h"
#import "FLAssetsPickerController.h"
#import "FLEditProfileView.h"
#import "FLAddListingController.h"

@interface FLMyProfileView () <UzysAssetsPickerControllerDelegate> {
	UIRefreshControl           *_refreshControl;
}

@property (strong, nonatomic) FLAssetsPickerController *assetsPicker;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (weak, nonatomic) IBOutlet UIButton *editProfilePictureButton;
@property (strong, nonatomic) NSArray *statistics;
@end

@implementation FLMyProfileView

static NSString * const cellReuseIdentifier = @"profileTableViewCell";

- (void)awakeFromNib {
    [super awakeFromNib];

	self.title = FLLocalizedString(@"screen_my_profile");
}

- (FLAssetsPickerController *)assetsPicker {
	if (_assetsPicker == nil) {
		_assetsPicker = [[FLAssetsPickerController alloc] init];
		_assetsPicker.maximumNumberOfSelectionVideo = 0;
		_assetsPicker.maximumNumberOfSelectionPhoto = 1;
		_assetsPicker.delegate = self;
	}
	return _assetsPicker;
}

- (void)prepareUI {
	self.view.backgroundColor = FLHexColor(kColorBackgroundColor);

	[_editProfileButton setTitle:FLLocalizedString(@"button_edit_profile") forState:UIControlStateNormal];
	[_editProfilePictureButton setTitle:FLLocalizedString(@"button_edit") forState:UIControlStateNormal];
    _thumbnail.backgroundColor = FLHexColor(@"eeeeee");
	_thumbnail.layer.borderColor = [UIColor whiteColor].CGColor;
	_thumbnail.layer.borderWidth = 2.0f;
    _thumbnail.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    _thumbnail.layer.shadowOpacity = 0.75f;

	// append refresh control
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl setTintColor:FLHexColor(kColorBarTintColor)];
	[_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview:_refreshControl];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self prepareUI];
    [self updateUserProfile];
}

- (void)viewDidAppear:(BOOL)animated {
	self.screenName = self.title;
	[super viewDidAppear:animated];
    [self refreshUI];
}

#pragma mark -

- (void)handleRefresh:(UIRefreshControl *)sender {
	[self updateUserProfile];
}

- (void)refreshProfileThumbnail {
    NSURL *sellerThumbnailURL = [NSURL URLWithString:FLUserInfo(kUserInfoThumbnailKey)];

    if (sellerThumbnailURL) {
        NSMutableURLRequest *thumbnailRequest = [NSMutableURLRequest requestWithURL:sellerThumbnailURL];
        [thumbnailRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        [_thumbnail setImageWithURLRequest:thumbnailRequest
                          placeholderImage:[UIImage imageNamed:@"blank_avatar"]
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       if (image) {
                                           _thumbnail.image = [image imageScaledToFitSize:_thumbnail.size];
                                       }
                                   } failure:nil];
    }
}

- (void)refreshUI {
    _usernameLabel.text = [FLAccount fullName];
    _userTypeLabel.text = [FLAccount userInfo:@"type"][@"name"];

    // set thumbnail if exists
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshProfileThumbnail];
    });

    // assign statistics
    NSMutableArray *statistics = [NSMutableArray new];

    for (NSDictionary *item in [FLAccount statistics]) {
        if ([item[@"caption"] isEqualToString:@"stat_listings"] && ![FLAccount canPostAds]) {
            return;
        }
        [statistics addObject:item];
    }

    self.statistics = statistics;
}

- (void)updateUserProfile {
    [self updateUserProfile:NO];
}

- (void)updateUserProfile:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:.3f animations:^{
            _tableView.contentOffset = CGPointMake(0, -64);
        }];
        [_refreshControl beginRefreshing];
    }

	[flynaxAPIClient getApiItem:kApiItemMyProfile
					 parameters:@{@"action": kApiItemMyProfile_profileInfo,
								  kUserInfoId: [NSNumber numberWithInteger:[FLAccount userId]]}

					 completion:^(NSDictionary *response, NSError *error) {
						 if (error == nil && [response isKindOfClass:NSDictionary.class]) {
							 [[FLAccount loggedUser] saveSessionData:response];
                             [self refreshUI];
                             [self swithToPostAdScreenIfNecessary];

							 dispatch_async(dispatch_get_main_queue(), ^{
								 [_refreshControl endRefreshing];
								 [_tableView reloadData];
							 });
						 }
                         else [FLDebug showAdaptedError:error apiItem:kApiItemMyProfile];
					 }];
}

#pragma mark - Actions

- (void)swithToPostAdScreenIfNecessary {
    if ([FLAppSession itemWithKey:kSessionPostAdScreenAfterLogin] == nil) {
        return;
    }

    if ([FLAccount canPostAds] == NO) {
        [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"alert_account_type_not_allow_to_submit_ads")];
        return;
    }

    FLAddListingController *addListingVC =
    [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAAFillOutFormView];
    [self.frostedViewController.contentViewController presentViewController:addListingVC.flNavigationController
                                                                   animated:YES completion:nil];
    [FLAppSession removeItemWithKey:kSessionPostAdScreenAfterLogin];
}

- (IBAction)editProfilePicture:(id)sender {
    [self presentViewController:self.assetsPicker animated:YES completion:nil];
}

#pragma mark - UzysAssetsPickerControllerDelegate

- (void)uzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
        ALAsset *asset = assets[0];
        UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage
                                             scale:asset.defaultRepresentation.scale
                                       orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];

    if (image) {
        NSInteger thumbWidth   = [FLConfig integerWithKey:@"account_thumb_width"];
        NSInteger thumbHeight  = [FLConfig integerWithKey:@"account_thumb_height"];
        NSInteger thumbQuality = [FLConfig integerWithKey:@"img_quality"];

        NSInteger trueWidth  = MIN(image.size.width, thumbWidth * 3);
        NSInteger trueHeight = MIN(image.size.height, thumbHeight * 3);

        UIImage *scaledImage = [image imageScaledToFitSize:(CGSize){trueWidth, trueHeight}];

        [FLProgressHUD showWithStatus:FLLocalizedString(@"uploading")];

        [flynaxAPIClient uploadWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(scaledImage, thumbQuality)
                                        name:@"profile-image"
                                    fileName:@"file.jpg"
                                    mimeType:@"image/jpeg"];
        }
        toApiItem:kApiItemMyProfile
        parameters:@{@"action": kApiItemMyProfile_uploadImage}
        progress:^(NSProgress *uploadProgress) {
             float progress = ((float) uploadProgress.completedUnitCount / (float) uploadProgress.totalUnitCount); // 0.0 - 1.0
             [FLProgressHUD showProgress:progress status:FLLocalizedString(@"processing")];
        }
        completion:^(NSDictionary *response, NSError *error) {
            if (error == nil && [response isKindOfClass:NSDictionary.class]) {
                if (response[@"image"] != nil) {
                    NSURL *newProfileImageUrl = URLIFY(response[@"image"]);

                    if (newProfileImageUrl) {
                        [self updateProfileImageUrl:response[@"image"]];
                        [self refreshProfileThumbnail];
                    }
                    [FLProgressHUD dismiss];
                }
                else if (response[@"error"] != nil) {
                    [FLProgressHUD showErrorWithStatus:FLCleanString(response[@"error"])];
                }
            }
            else [FLDebug showAdaptedError:error apiItem:kApiItemMyProfile];
        }];
    }
    else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"error_code_unknown")];
}

- (void)updateProfileImageUrl:(NSString *)urlString {
    NSMutableDictionary *updateProfile = [[FLAccount loggedUser].userInfo mutableCopy];
    [updateProfile setValue:FLCleanString(urlString) forKey:kUserInfoThumbnailKey];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:updateProfile forKey:kUserStorageProfileKey];
    [defaults synchronize];

    [[FLAccount loggedUser] reloadLocalVariables];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return FLLocalizedString(self.statistics[section][@"caption"]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.statistics.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    
    NSArray *items = self.statistics[indexPath.section][@"items"];
    NSMutableArray *tiles = [[NSMutableArray alloc] init];

    for (NSDictionary *item in items) {
		NSString *info = [NSString stringWithFormat:@"%@", item[@"number"]];
        FLInfoTileView *tile = [[FLInfoTileView alloc] initWithTitle:FLLocalizedString(item[@"name"]) andInfo:info];
        [tiles addObject:tile];
    }

    cell.tiles = tiles;

	return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 34.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.contentView.backgroundColor = [UIColor clearColor];
    headerView.backgroundView.backgroundColor = [UIColor clearColor];
    headerView.textLabel.font = [UIFont boldSystemFontOfSize:11];
    headerView.textLabel.textColor = FLHexColor(@"1b1b1b");
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.0f;
}

#pragma mark - Navigation

- (IBAction)editProfileBtnDidTap:(UIButton *)sender {
    UINavigationController *eProfileNC = [self.storyboard instantiateViewControllerWithIdentifier:@"editProfileNC"];
    [self presentViewController:eProfileNC animated:YES completion:nil];

    // update profile
    ((FLEditProfileView *)eProfileNC.visibleViewController).completionBlock = ^{
        [self updateUserProfile:YES];
    };
}

@end
