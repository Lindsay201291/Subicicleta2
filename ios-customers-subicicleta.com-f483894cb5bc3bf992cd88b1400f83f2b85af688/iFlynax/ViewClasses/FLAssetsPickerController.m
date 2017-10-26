//
//  FLAssetsPickerController.m
//  iFlynax
//
//  Created by Alex on 1/15/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLAssetsPickerController.h"

static NSInteger const kTagTopView    = 200;
static NSInteger const kTagBottomView = 201;
static NSInteger const kTagSelectedMediaLabel = 80;

@interface FLAssetsPickerController()

@property (copy, nonatomic) NSArray *pickedAssets;

@end

@implementation FLAssetsPickerController

- (instancetype)init {
	self = [super initWithNibName:@"FLAssetsPickerController" bundle:nil];
	if(self) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(assetsLibraryUpdated:)
													 name:ALAssetsLibraryChangedNotification object:nil];
		// picker customization
		UzysAppearanceConfig *appearanceConfig = [[UzysAppearanceConfig alloc] init];
        appearanceConfig.finishSelectionButtonColor   = FLHexColor(@"ff961d");
        appearanceConfig.assetsGroupSelectedImageName = @"assets_check_mark";
		appearanceConfig.assetDeselectedImageName     = @"clear_point";
		appearanceConfig.assetSelectedImageName       = @"assets_check";
        appearanceConfig.cameraImageName              = @"assets_camera";
        appearanceConfig.cellSpacing                  = 5.0f;
        appearanceConfig.assetsCountInALine           = 4;
		[UzysAssetsPickerController setUpAppearanceConfig:appearanceConfig];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	// UI customizations
    UILabel *selectedMedia = (UILabel *)[self.view viewWithTag:kTagSelectedMediaLabel];
	UIView *pickerBottomView = (UIView *)[self.view viewWithTag:kTagBottomView];
    UIView *pickerTopView = (UIView *)[self.view viewWithTag:kTagTopView];
    UIButton *cancelButton = (UIButton *)[self.view viewWithTag:kTagButtonClose];
    UIButton *doneButton = (UIButton *)[self.view viewWithTag:kTagButtonDone];

    selectedMedia.text = FLLocalizedString(@"label_choose_photo");
	pickerTopView.layer.backgroundColor = [UIColor hexColor:@"2e393b"].CGColor;
	pickerBottomView.layer.backgroundColor = [UIColor hexColor:@"2e393b"].CGColor;
    [cancelButton setTitle:FLLocalizedString(@"button_cancel") forState:UIControlStateNormal];

    if (IS_RTL && [doneButton respondsToSelector:@selector(setSemanticContentAttribute:)]) {
        [doneButton setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
    }

    // collection customizations
    UICollectionView *collectionView = (UICollectionView *)self.view.subviews[0];
    collectionView.backgroundColor = FLHexColor(kColorBackgroundColor);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self.delegate respondsToSelector:@selector(flAssetsPickerControllerDidDisappear:)]) {
        [(id)self.delegate flAssetsPickerControllerDidDisappear:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

@end
