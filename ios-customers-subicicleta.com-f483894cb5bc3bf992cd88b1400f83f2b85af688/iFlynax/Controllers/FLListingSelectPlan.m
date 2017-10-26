//
//  FLListingSelectPlan.m
//  iFlynax
//
//  Created by Alex on 2/26/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLPlansCollectionViewCell.h"
#import "FLListingSelectPlan.h"
#import "FLPaymentHelper.h"
#import "FLPlansManager.h"
#import "FLPlansLayout.h"
#import "FLPlanModel.h"

@interface FLListingSelectPlan () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FLRadioButtonDelegate>
@property (nonatomic, strong) NSArray<FLPlanModel *> *entries;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *selectPlanBtn;
@property (nonatomic, assign) FLPlansManager *plansManager;
@end

@implementation FLListingSelectPlan

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = FLHexColor(kColorBackgroundColor);
    self.collectionView.backgroundColor = self.view.backgroundColor;
    [self.navigationItem.leftBarButtonItem setTitle:FLLocalizedString(@"button_cancel")];

    [FLBlankSlate attachTo:_collectionView withTitle:FLLocalizedString(@"no_plans_category")];
    _plansManager = [FLPlansManager sharedManager];

    [_selectPlanBtn setTitle:FLLocalizedString(@"button_select_plan") forState:UIControlStateNormal];

    if (!_upgradeMode) {
        self.title = FLLocalizedString(@"screen_select_plan");

        _selectPlanBtn.enabled = (_plansManager.selectedPlan != nil);
        _entries = _plansManager.plans;

        // flush prevs button's
        [_plansManager.planButtons removeAllObjects];
    }
    else {
        self.title = FLLocalizedString(@"loading");
        [FLPlansManager restoreToDefaults];

        _selectPlanBtn.enabled = NO;
        _selectPlanBtn.hidden  = YES;
        _collectionView.alpha  = 0;

        [flynaxAPIClient getApiItem:kApiItemRequests
                         parameters:@{@"cmd"           : kApiItemRequests_getPlans,
                                      @"cid"           : @(_categoryId),
                                      @"featured_only" : @(_featuredPlansOnly)}

                         completion:^(NSArray *response, NSError *error) {
                             if (!error && [response isKindOfClass:NSArray.class] && response.count) {

                                 /* prepare plans */
                                 NSMutableArray *plans = [NSMutableArray array];
                                 for (NSDictionary *planDict in response) {
                                     FLPlanModel *model = [FLPlanModel fromDictionary:planDict];
                                     // for upgrade mode
                                     if (_selectPlanById && _selectPlanById == model.pId) {
                                         _plansManager.selectedPlan = model;
                                         _plansManager.currentPlan  = model;
                                         _selectPlanBtn.enabled = YES;
                                     }
                                     [plans addObject:model];
                                 }
                                 /* prepare plans END */

                                 if ([FLPaymentHelper requiredToValidateListingPlans]) {
                                     self.title = FLLocalizedString(@"plans_synchronization");

                                     [FLPaymentHelper validateListingPlans:plans
                                                                completion:^(NSMutableArray *validPlans, NSError *error) {
                                                                    [self collectionViewReloadDataAsyncWithResponse:validPlans];
                                                                }];
                                 }
                                 else [self collectionViewReloadDataAsyncWithResponse:plans];
                             }
                             else [self fadeInCollectionView];
                         }];
    }
}

- (void)collectionViewReloadDataAsyncWithResponse:(NSMutableArray *)response {
    _entries = response;

    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = FLLocalizedString(@"screen_select_plan");
        [_collectionView reloadData];
        [self fadeInCollectionView];
        _selectPlanBtn.hidden = !response.count;
    });
}

- (void)fadeInCollectionView {
    [UIView animateWithDuration:.3f animations:^{
        _collectionView.alpha = 1;
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _entries.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FLPlansCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kStoryBoardPlansCellIdentifier
                                                                                forIndexPath:indexPath];
    [cell setRadioButtonDelegate:self];
    [cell withPlanInfo:_entries[indexPath.row]];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(FLPlansLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize itemSize;
    itemSize.width = collectionView.width - kGlobalPadding * 2;
    FLPlanModel *model = _entries[indexPath.row];
    itemSize.height = (model.planLimit > 0 && model.planUsing == 0) || !model.advancedMode ? 171 : 209;
    
    return itemSize;
}

#pragma mark - FLRadioButtonDelegate

- (void)FLRadioButtonDidTapped:(FLRadioButton *)button {
    self.selectPlanBtn.enabled = YES;
    _plansManager.selectedPlan = button.userInfo;
}

#pragma mark - Navigation

- (IBAction)cancelButtonDidTap:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectPlanButtonTapped:(UIButton *)sender {
    if (_plansManager.selectedPlan != nil) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if (self.completionBlock) {
                self.completionBlock(_plansManager.selectedPlan);
            }
        }];
    }
}

@end
