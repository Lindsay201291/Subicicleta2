//
//  FLMyListingsView.m
//  iFlynax
//
//  Created by Alex on 3/19/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLMyListingsView.h"
#import "FLMyListingsCell.h"
#import "CCActionSheet.h"

#import "FLMyAdShortDetailsModel.h"
#import "FLNavigationController.h"
#import "FLAddListingController.h"
#import "FLListingSelectPlan.h"
#import "FLPaymentHelper.h"
#import "FLAdStatistics.h"
#import "FLPaymentVC.h"

@implementation FLMyListingsView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = FLLocalizedString(@"screen_myListings_view");

    UINib *cellNib = [UINib nibWithNibName:kNibNameMyListingsViewCell bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kStoryBoardMyListingsCellIdentifier];
    
    self.apiItem = kApiItemMyListings;
    [self addApiParameter:@"fetch" forKey:@"cmd"];
    
    self.initStack    = 1;
    self.currentStack = 1;
    
    self.blankSlate.title   = FLLocalizedString(@"blankSlate_myListings_title");
    self.blankSlate.message = FLLocalizedString(@"blankSlate_myListings_message");
    
    [self loadDataWithRefresh:YES];

    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makePayment:)
                                                 name:kNotificationMakePayment
                                               object:nil];
}

- (void)makePayment:(NSNotification *)notification {
    [FLProgressHUD dismiss]; //dismiss loading content of this controller

    FLNavigationController *paymentNC = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardPaymentNC];
    FLPaymentVC *paymentVC = (FLPaymentVC *)paymentNC.topViewController;
    paymentVC.orderInfo = [notification.userInfo objectForKey:kOrderFromNotification];

    [self presentViewController:paymentNC animated:YES completion:^{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationMakePayment object:nil];
    }];

    paymentVC.completionBlock = ^{
        [[FLLang sharedInstance] showSuccessUpdatedListing:NO];
        [self updateTableViewWithAnimation];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCellAccessory:)
                                                 name:kMyListingShowAccessoryNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMyListingShowAccessoryNotification object:nil];
}

#pragma mark -- UITableViewDataSouce

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLMyListingsCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoryBoardMyListingsCellIdentifier];
    [self fillUpAdsCell:cell ForRowAtIndexPath:indexPath];
    return cell;
}

- (void)fillUpAdsCell:(FLMyListingsCell *)cell ForRowAtIndexPath:(NSIndexPath *)indexPath {
    [super fillUpAdsCell:cell ForRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static FLMyListingsCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [tableView dequeueReusableCellWithIdentifier:kStoryBoardMyListingsCellIdentifier];
    });
    
    [self fillUpAdsCell:cell ForRowAtIndexPath:indexPath];
    
    return [self heightForCell:cell];
}

- (void)showCellAccessory:(NSNotification *)notification {
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:notification.object];
    FLMyAdShortDetailsModel *listing = [FLMyAdShortDetailsModel fromDictionary:self.entries[cellIndexPath.row]];

    CCActionSheet *sheet = [[CCActionSheet alloc] initWithTitle:nil];

    /* edit listing || continue posting */
    NSString *editBtnTitleKey = @"button_myads_edit";
    if (listing.status == FLListingStatusIncomplete) {
        if (![listing.formLastStep isEqualToString:kFormLastStepCheckout]) {
            editBtnTitleKey = @"button_myads_continue_posting";
        }
    }

    [sheet addButtonWithTitle:FLLocalizedString(editBtnTitleKey) block:^{
        FLAddListingController *editListingVC = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAAFillOutFormView];
        editListingVC.listing  = listing;
        editListingVC.editMode = YES;
        [self.navigationController presentViewController:editListingVC.flNavigationController animated:YES completion:nil];
    }];
    /* edit listing || continue posting END */

    if (listing.status == FLListingStatusActive) {
        /* statistics */
        [sheet addButtonWithTitle:FLLocalizedString(@"button_myads_view_statistics") block:^{
            FLNavigationController *adStatisticsNC = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardListingStatisticsNC];
            ((FLAdStatistics *)adStatisticsNC.visibleViewController).listing = listing;
            
            [self.navigationController presentViewController:adStatisticsNC animated:YES completion:nil];
        }];
        /* statistics end */
        
        /* upgrade to featured */
        if (!listing.featured) {
            [self addUpgradeRenewButtonIntoSheet:sheet listing:listing featured:YES];
        }
        /* upgrade to featured END */

        // upgrade/renew plan
        [self addUpgradeRenewButtonIntoSheet:sheet listing:listing];
    }
    else if (listing.status == FLListingStatusInActive) {
        
    }
    else if (listing.status == FLListingStatusIncomplete &&
             [listing.formLastStep isEqualToString:kFormLastStepCheckout] &&
             [FLPaymentHelper canMakePayments])
    {
        [sheet addButtonWithTitle:FLLocalizedString(@"button_myads_make_payment") block:^{
            [self getPlanDetailsForListing:listing andProcessToPaymentVC:YES];
        }];
    }
    else if (listing.status == FLListingStatusExpired) {
        [self addUpgradeRenewButtonIntoSheet:sheet listing:listing];
    }
    
    /* remove listing */
    FLMyListingsCell *cell = notification.object;
    
    [sheet addDestructiveButtonWithTitle:FLLocalizedString(@"button_remove") block:^{
        CCActionSheet *confirmSheet = [[CCActionSheet alloc] initWithTitle:FLLocalizedString(@"dialog_confirm_listing_removal")];
        [confirmSheet addDestructiveButtonWithTitle:FLLocalizedString(@"button_remove") block:^{
            [self removeListingById:listing.lId atIndexPath:cellIndexPath];
        }];
        [confirmSheet addCancelButtonWithTitle:FLLocalizedString(@"button_cancel")];
        [confirmSheet showFromRect:cell.accessoryButton.frame inView:cell.contentView animated:YES];
    }];
    /* remove listing end */
    
    [sheet addCancelButtonWithTitle:FLLocalizedString(@"button_cancel")];
    [sheet showFromRect:cell.accessoryButton.frame inView:cell.contentView animated:YES];
    
}

- (void)getPlanDetailsForListing:(FLMyAdShortDetailsModel *)listing andProcessToPaymentVC:(BOOL)makePayment {
    [FLProgressHUD showWithStatus:FLLocalizedString(@"processing")];

    [flynaxAPIClient getApiItem:kApiItemRequests
                     parameters:@{@"cmd"    : kApiItemRequests_getPlans,
                                  @"plan_id": @(listing.planId),
                                  @"cid"    : @(listing.categoryId)}

                     completion:^(NSDictionary *planDict, NSError *error) {
                         if (!error && [planDict isKindOfClass:NSDictionary.class]) {
                             FLPlanModel *plan = [FLPlanModel fromDictionary:planDict];

                             [self initializePaymentForListing:listing withPlan:plan];
                             [FLProgressHUD dismiss];
                         }
                         else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"Something is wrong, please contact the Administrator.")];
                     }];
}

- (void)initializePaymentForListing:(FLMyAdShortDetailsModel *)listing withPlan:(FLPlanModel *)plan {
    FLNavigationController *paymentNC = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardPaymentNC];
    FLPaymentVC *paymentVC = (FLPaymentVC *)paymentNC.topViewController;

    FLOrderItem item;

    // TODO: look at me
    switch (plan.type) {
        case FLPlanTypeFeatured:
            item = FLOrderItemFeatured;
            break;

        case FLPlanTypeListing:
        case FLPlanTypeUnknown:
            item = FLOrderItemListing;
            break;

        case FLPlanTypePackage:
            item = FLOrderItemPackage;
            break;
    }

    FLOrderModel *order = [FLOrderModel withItem:item];
    order.itemId = listing.lId;
    order.plan   = plan;
    paymentVC.orderInfo = order;

    [self.navigationController presentViewController:paymentNC animated:YES completion:nil];

    paymentVC.completionBlock = ^{
        [[FLLang sharedInstance] showSuccessUpdatedListing:NO];
        [self updateTableViewWithAnimation];
    };
}

- (void)addUpgradeRenewButtonIntoSheet:(CCActionSheet *)sheet listing:(FLMyAdShortDetailsModel *)listing {
    [self addUpgradeRenewButtonIntoSheet:sheet listing:listing featured:NO];
}

- (void)addUpgradeRenewButtonIntoSheet:(CCActionSheet *)sheet listing:(FLMyAdShortDetailsModel *)listing featured:(BOOL)featured {
    NSString *sheetBtnTitleKey = featured ? @"button_myads_upgrade_to_featured" : @"button_myads_upgrade_renew";

    [sheet addButtonWithTitle:FLLocalizedString(sheetBtnTitleKey) block:^{
        FLNavigationController *selectPlanNC = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAASelectPlanView];
        FLListingSelectPlan *selectPlanVC = (FLListingSelectPlan *)selectPlanNC.topViewController;
        selectPlanVC.categoryId  = listing.categoryId;
        selectPlanVC.upgradeMode = YES;

        if (featured) {
            selectPlanVC.featuredPlansOnly = YES;
        }
        else {
            selectPlanVC.selectPlanById = listing.planId;
        }

        [self.navigationController presentViewController:selectPlanNC animated:YES completion:nil];

        // present payment gateways if plan is selected
        selectPlanVC.completionBlock = ^(FLPlanModel *listingPlan) {
            if (listingPlan) {
                if ([listingPlan paymentIsRequired]) {
                    FLNavigationController *paymentNC = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardPaymentNC];
                    FLPaymentVC *paymentVC = (FLPaymentVC *)paymentNC.topViewController;

                    FLOrderModel *order = [FLOrderModel withItem:(featured ? FLOrderItemFeatured : FLOrderItemListing)];
                    order.itemId = listing.lId;
                    order.plan   = listingPlan;
                    paymentVC.orderInfo = order;

                    [self.navigationController presentViewController:paymentNC animated:YES completion:nil];

                    paymentVC.completionBlock = ^{
                        NSString *successMessage = featured ? @"listing_upgraded_to_featured" : @"listing_plan_upgraded";
                        [FLProgressHUD showSuccessWithStatus:FLLocalizedString(successMessage)];
                        [self updateTableViewWithAnimation];
                    };
                }

                /* upgrade free or existing package plan */
                else {
                    [FLProgressHUD showWithStatus:FLLocalizedString(@"processing")];
                    NSString *appearance = (listingPlan.planMode == FLPlanModeFeatured) ? @"featured" : @"standard";

                    [flynaxAPIClient postApiItem:kApiItemRequests
                                      parameters:@{@"cmd"       : kApiItemRequests_upgradePlan,
                                                   @"lid"       : @(listing.lId),
                                                   @"plan_id"   : @(listingPlan.pId),
                                                   @"appearance": appearance}

                                      completion:^(NSDictionary *response, NSError *error) {
                                          if (!error && [response isKindOfClass:NSDictionary.class]) {
                                              if (FLTrueBool(response[@"success"])) {
                                                  [[FLLang sharedInstance] showSuccessUpdatedListing:NO];
                                                  [self updateTableViewWithAnimation];
                                              }
                                              else {
                                                  [FLProgressHUD showErrorWithStatus:@"FAK! see logs"];

                                                  NSLog(@"response: %@", response);
                                              }
                                          }
                                          else [FLDebug showAdaptedError:error apiItem:kApiItemRequests_upgradePlan];
                                      }];
                }
                /* upgrade free or existing package plan END */
            }
        };
    }];
}

- (void)updateTableViewWithAnimation {
    [FLProgressHUD dismiss];

    [UIView animateWithDuration:.3f animations:^{
        self.tableView.contentOffset = CGPointMake(0, -64);
    }];
    [self.refreshControl beginRefreshing];
    [self loadDataWithRefresh:YES];
}

- (void)removeListingById:(NSInteger)listingId atIndexPath:(NSIndexPath *)indexPath {
    [FLProgressHUD showWithStatus:FLLocalizedString(@"dialog_deleting")];

    [flynaxAPIClient postApiItem:kApiItemRequests
                      parameters:@{@"cmd": kApiItemRequests_removeListing,
                                   @"lid": @(listingId)}
                      completion:^(NSDictionary *response, NSError *error) {
                          if (!error && [response isKindOfClass:NSDictionary.class] && FLTrueBool(response[@"success"])) {
                              [FLProgressHUD showSuccessWithStatus:FLLocalizedString(@"dialog_listing_removed")];

                              // remove cell from table
                              [self.entries removeObjectAtIndex:indexPath.row];

                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [self.tableView reloadData];
                              });
                          }
                          else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"remove_listing_fail")];
                      }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMyListingShowAccessoryNotification object:nil];
}

@end
