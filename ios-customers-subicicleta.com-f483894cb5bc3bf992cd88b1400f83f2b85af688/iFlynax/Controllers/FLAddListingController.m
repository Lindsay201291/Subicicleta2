//
//  FLAddListingController.m
//  iFlynax
//
//  Created by Alex on 3/12/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "REFrostedViewController.h"
#import "FLAddListingController.h"
#import "FLListingSelectPlan.h"
#import "FLListingFormModel.h"
#import "FLTableViewManager.h"
#import "FLKeyboardHandler.h"
#import "FLMainNavigation.h"
#import "FLPlansManager.h"
#import "FLTableSection.h"
#import "FLCategoryBox.h"
#import "FLFieldModel.h"
#import "CCAlertView.h"
#import "FLRootView.h"

/* media uploader */
#import "YTPlayerView.h"
#import "FLAssetsPickerController.h"
#import "FLYTAddingViewController.h"
#import "FLImageMediaGallery.h"
#import "FLImageMGItemModel.h"
#import "FLYouTubeGallery.h"
#import "FLMediaGallery.h"
#import "FLYTWebView.h"

#import "FLMediaUploader.h"
/* media uploader end */

/* payment */
#import "FLPaymentHelper.h"
#import "FLPaymentVC.h"

#define localizedSectionAddPictures FLLocalizedString(@"section_add_pictures")
#define localizedSectionAddYouTube  FLLocalizedString(@"section_add_youtube")

static NSString * const kItemName           = @"name";
static NSString * const kMediaSectionPhotos = @"isPhotoSection";
static NSString * const kMediaSectionVideos = @"isVideoSection";
// response key's
static NSString * const kResponseKeyCategoriesIDs = @"categories_ids";
static NSString * const kResponseKeyCategories    = @"categories";
static NSString * const kResponseKeyFields        = @"form";
static NSString * const kResponseKeyPlans         = @"plans";
static NSString * const kResponseKeyPhotos        = @"photos";
static NSString * const kResponseKeyVideos        = @"videos";
static NSString * const kResponseKeyListingType   = @"listing_type_key";
static NSString * const kResponseKeyCategory      = @"category";
static NSString * const kResponseKeyPlan          = @"plan";

typedef NS_ENUM(NSInteger, FLSectionType) {
    FLSectionTypeListingType,
    FLSectionTypeCategory
};

typedef NS_ENUM(NSInteger, FLFormState) {
    FLFormStateSelectCategory,
    FLFormStateFillOut
};

@interface FLAddListingController () <FLCategoryBoxDelegate, RETableViewManagerDelegate, FLKeyboardHandlerDelegate, UzysAssetsPickerControllerDelegate, FLImageMediaGalleryDelegate, FLYTAddingDelegate>
{
    NSMutableArray<RETableViewSection *> *_savedSections;
    NSMutableArray<RETableViewSection *> *_savedFormSections;
    NSMutableArray *_savedHeaders;
    NSMutableArray *_headers;

    NSInteger _sectionPictures;
    NSInteger _sectionVideos;

    FLNavigationController *_flNavigationController;
}
@property (weak, nonatomic) IBOutlet UIButton *langSelectorBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FLTableViewManager *manager;
@property (strong, nonatomic) FLKeyboardHandler  *keyboardHandler;
@property (strong, nonatomic) FLCategoryBox      *categoryBox;
@property (strong, nonatomic) FLListingFormModel *adForm;
@property (strong, nonatomic) FLPlansManager     *plansManager;
@property (strong, nonatomic) UIButton *selectCategoryBtn;
@property (strong, nonatomic) UIButton *submitButton;

@property (strong, nonatomic) RETableViewSection *listingTypeSection;
@property (strong, nonatomic) RETableViewSection *categoriesSection;
@property (strong, nonatomic) RETableViewSection *formFieldsSection;

@property (assign, nonatomic) FLFormState formState;

/* media gallery */
@property (strong, nonatomic) FLImageMediaGallery *photoGallery;
@property (strong, nonatomic) FLYouTubeGallery    *ytVideoGallery;

@property (strong, nonatomic) FLYTAddingViewController *ytAddController;
@property (strong, nonatomic) FLAssetsPickerController *assetsPicker;

@property (strong, nonatomic) UIView *photoGallerySectionView;
@property (strong, nonatomic) UIView *ytVideoGallerySectionView;
/* media gallery end */
@end

@implementation FLAddListingController

- (void)viewDidLoad {
    [super viewDidLoad];

    _categoryBox = [[FLCategoryBox alloc] init];
    _categoryBox.delegate = self;

    self.manager = [FLTableViewManager withTableView:self.tableView];
    self.manager.delegate = self;

    _keyboardHandler = [[FLKeyboardHandler alloc] initWithScroll:self.tableView];
    _keyboardHandler.delegate = self;
    _keyboardHandler.autoHideEnable = NO;

    self.view.backgroundColor      = FLHexColor(kColorBackgroundColor);
    self.tableView.backgroundColor = self.view.backgroundColor;

    // clear `session` data
    _plansManager      = [FLPlansManager sharedManager];
    _adForm            = [FLListingFormModel sharedInstance];
    _headers           = [NSMutableArray array];
    _savedHeaders      = [NSMutableArray array];
    _savedSections     = [NSMutableArray array];
    _savedFormSections = [NSMutableArray array];

    [FLPlansManager restoreToDefaults];
    [_adForm resetForm];

    _sectionPictures = NSNotFound;
    _sectionVideos   = NSNotFound;

    if (self.isEditMode) {
        self.title = FLLocalizedString(@"loading");
        [self fetchListingFormData];
    }
    else {
        [self buildSelectCategoryStep];
    }

    /*// for future purpose
    UIImage *langImage = [UIImage imageNamed:F(@"flag_%@", [FLLang langCode])];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, langImage.size.width, langImage.size.height)];
    [button setBackgroundImage:langImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(langSelectorBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    */
}

- (void)dealloc {
    [_keyboardHandler unRegisterNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FLMediaGalleryDidStartEditionNotification object:nil];
}

/*
- (IBAction)langSelectorBtnTapped:(id)sender {
    NSLog(@"%s", __FUNCTION__);
}
*/

- (void)buildSelectCategoryStep {
    self.title = FLLocalizedString(@"select_category");

    _formState = FLFormStateSelectCategory;
    _tableView.tableHeaderView = nil;
    _tableView.tableFooterView = nil;
    [_manager removeAllSections];
    
    if (_savedSections.count) {
        for (RETableViewSection *section in _savedSections) {
            [_manager addSection:section];
        }
        _tableView.tableFooterView = [self tableFooterSelectCategoryBtn];
    }
    else {
        NSArray *accountAbilities = FLUserInfo(kUserInfoAbilitiesKey);
        NSMutableArray *listingTypes = [NSMutableArray array];
        __block FLListingTypeModel *selectedListingTypeModel;

        [accountAbilities enumerateObjectsUsingBlock:^(NSString *type, NSUInteger idx, BOOL *stop) {
            FLListingTypeModel *listingType = [FLListingTypes withKeyAsModel:type];
            if (listingType != nil) {
                [listingTypes addObject:listingType];
                
                // edit mode
                if (_adForm.listingType && [_adForm.listingType.key isEqualToString:listingType.key]) {
                    selectedListingTypeModel = listingType;
                }
            }
        }];

        // MULTIPLE LISTING TYPES MODE
        if (listingTypes.count > 1) {
            _listingTypeSection = [RETableViewSection sectionWithHeaderTitle:FLLocalizedString(@"listing_type")];
            _listingTypeSection.footerTitle = FLLocalizedString(@"add_listing_listing_type_hint");
            _listingTypeSection.headerHeight = 15;
            [self.manager addSection:_listingTypeSection];

            _categoriesSection = [RETableViewSection sectionWithHeaderTitle:FLLocalizedString(@"listing_category")];
            _categoriesSection.headerHeight = 25;

            FLFieldSelect *field = [FLFieldSelect withTitle:FLLocalizedString(@"listing_type") options:listingTypes];

            // edit mode
            if (selectedListingTypeModel) {
                field.value = selectedListingTypeModel;
            }

            [_listingTypeSection addItem:field];

            field.actionBarDoneButtonTapHandler = ^void(FLFieldSelect *item) {
                [self actionBarDoneButtonTapHandler:item];
            };
        }

        // SINGLE LISTING TYPE MODE
        else if (listingTypes.count == 1) {
            _adForm.listingType = [listingTypes firstObject];

            // get categories for the listing type
            NSArray *categories = [FLCache objectWithKey:kCacheCategoriesOneLevel][_adForm.listingType.key];

            _categoriesSection = [RETableViewSection sectionWithHeaderTitle:FLLocalizedString(@"listing_category")];
            _categoriesSection.headerHeight = 15;

            [self appendCategoryFieldWithCategories:categories completion:^{
                [_categoriesSection setFooterTitle:FLLocalizedString(@"select_category")];

                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.manager.sections indexOfObject:_categoriesSection] == NSNotFound) {
                        [self.manager addSection:_categoriesSection];
                        [self.tableView reloadData];
                    }
                });
            }];
        }
        else {
            //TODO: user-friendly ERROR
            [FLProgressHUD showErrorWithStatus:@"Eror Code: FL200\nPlease contact the Administrator."];
        }
    }
}

- (UIButton *)selectCategoryBtn {
    if (_selectCategoryBtn == nil) {
        _selectCategoryBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, self.tableView.width-30, 44)];
        [_selectCategoryBtn setTitle:FLLocalizedString(@"select_category") forState:UIControlStateNormal];
        [_selectCategoryBtn setBackgroundImage:[UIImage imageNamed:@"button1"] forState:UIControlStateNormal];
        [_selectCategoryBtn addTarget:self action:@selector(selectCategoryBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectCategoryBtn;
}

- (UIButton *)submitButton {
    if (_submitButton == nil) {
        _submitButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 5, self.tableView.width-30, 50)];
        [_submitButton setTitle:FLLocalizedString(@"button_submit") forState:UIControlStateNormal];
        [_submitButton setBackgroundImage:[UIImage imageNamed:@"button1"] forState:UIControlStateNormal];
        [_submitButton addTarget:self action:@selector(submitBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

- (UIView *)tableFooterSelectCategoryBtn {
    CGRect btnFrame = CGRectMake(0, 0, 0, self.selectCategoryBtn.height);
    UIView *view = [[UIView alloc] initWithFrame:btnFrame];
    [view addSubview:self.selectCategoryBtn];
    return view;
}

- (UIView *)tableFooterSubmitButton {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.height = 70;
    [view addSubview:self.submitButton];
    return view;
}

- (void)alertNoPlanSelected {
    [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"alert_no_plan_selected")];
    _categoryBox.planTitleColor = kColorFieldHasError;
}

- (void)updateCategoryBox {
    self.tableView.tableHeaderView = _categoryBox;

    [_categoryBox.breadcrumbs removeAllObjects];
    [_categoryBox.breadcrumbs addObject:_adForm.listingType.name];

    for (FLFieldSelect *field in _categoriesSection.items) {
        if ([field.value isKindOfClass:FLCategoryModel.class]) {
            NSString *name = ((FLCategoryModel *)field.value).name;
            [_categoryBox.breadcrumbs addObject:name];
        }
    }
    [_categoryBox buildBreadcrumbs];
    [_categoryBox setEditCategoryBtnActive:NO];
}

// processed to fillout form
- (void)selectCategoryBtnTapped {
    [self updateCategoryBox];

    // save sections for future purpose
    [_savedSections removeAllObjects];

    if (_listingTypeSection) {
        [_savedSections addObject:_listingTypeSection];
    }

    [_savedSections addObject:_categoriesSection];

    // clear table
    [self.manager removeAllSections];
    [self.tableView reloadData];
    [_selectCategoryBtn removeFromSuperview];

    [self clearFormSectionsIfNecessary];

    if (_plansManager.plans.count && _adForm.fields.count) {
        [self buildFormTable];
    }
    else {
        _categoryBox.planTitle = FLLocalizedString(@"loading");
        [self fetchListingFormData];
    }
}

- (void)fetchListingFormData {
    NSDictionary *_params;

    if (!self.editMode) {
        _params = @{@"cmd"  : kApiItemRequests_getAddListingData,
                    @"cid"  : @(_adForm.category.cId),
                    @"ltype": _adForm.listingType.key};
    }
    else {
        _params = @{@"cmd" : kApiItemRequests_getEditListingData,
                    @"lid" : @(self.listing.lId)};
    }

    [flynaxAPIClient getApiItem:kApiItemRequests
                     parameters:_params
                     completion:^(NSDictionary *response, NSError *error) {
                         if (error == nil && [response isKindOfClass:NSDictionary.class]) {

                             /* prepare plans */
                             static NSArray *_plans;
                             _plans = [self formValidResponse:response withKey:kResponseKeyPlans];
                             for (NSDictionary *planDict in _plans) {
                                 FLPlanModel *planModel = [FLPlanModel fromDictionary:planDict];
                                 [_plansManager.plans addObject:planModel];
                                 
                             }
                             /* prepare plans END */

                             _adForm.fields = [self formValidResponse:response withKey:kResponseKeyFields];

                             if (self.editMode) {
                                 _adForm.categoriesIDs = [self formValidResponse:response withKey:kResponseKeyCategoriesIDs];
                                 _adForm.listingType   = [FLListingTypes withKeyAsModel:response[kResponseKeyListingType]];
                                 _adForm.category      = [FLCategoryModel fromDictionary:response[kResponseKeyCategory]];
                                 _adForm.savedCategory = _adForm.category;
                                 _adForm.plan          = [FLPlanModel fromDictionary:response[kResponseKeyPlan]];

                                 _plansManager.selectedPlan = _adForm.plan;

                                 /* for first step */
                                 static NSDictionary *_categories;
                                 _categories = response[kResponseKeyCategories];
                                 //[self buildCategoriesForEditMode:_categories];
                                 [self updateCategoryBox];
                                 /* for first step END */

                                 /* append media data */
                                 if (_adForm.listingType.photo) {
                                     _adForm.photos = [self formValidResponse:response withKey:kResponseKeyPhotos];
                                 }

                                 if (_adForm.listingType.video) {
                                     _adForm.videos = [self formValidResponse:response withKey:kResponseKeyVideos];
                                 }
                                 /* append media data END */
                             }

                             if (_adForm.fields.count) {
                                 if (_plansManager.plans.count) {
                                     if ([FLPaymentHelper requiredToValidateListingPlans]) {
                                         self.categoryBox.planTitle = FLLocalizedString(@"plans_synchronization");

                                         [FLPaymentHelper validateListingPlans:_plansManager.plans
                                             completion:^(NSMutableArray *validPlans, NSError *error) {
                                                 _plansManager.plans = validPlans;
                                                 [self buildFormTable];
                                             }];
                                     }
                                     else {
                                         [self buildFormTable];
                                     }
                                 }
                                 else {
                                     [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"listing_no_upgrade_plans")];
                                     self.categoryBox.planTitle = FLLocalizedString(@"no_plans_available");
                                     self.categoryBox.editCategoryBtnActive = YES;
                                 }
                             }
                             else {
                                 [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"selected_category_no_fields")];
                                 self.categoryBox.editCategoryBtnActive = YES;
                             }
                         }
                         else {
                             // TODO: probably put here a more friendly message ;)
                             _categoryBox.planTitle = @"ERROR FL201";
                         }
                     }];
}

- (void)buildCategoriesForEditMode:(NSDictionary *)sections {
    if (sections.count) {
        [self buildSelectCategoryStep];
        [self setFormState:FLFormStateFillOut];

        NSArray *sortedKeys = [[sections allKeys] sortedArrayUsingSelector:@selector(compare:)];
        for (NSString *key in sortedKeys) {
            [self appendCategoryFieldWithCategories:sections[key] completion:nil];
        }

        // save sections for future purpose
        [_savedSections removeAllObjects];

        if (_listingTypeSection) {
            [_listingTypeSection setFooterTitle:nil];
            [_savedSections addObject:_listingTypeSection];
        }

        [_savedSections addObject:_categoriesSection];

        [self updateCategoryBox];

        //TMP
        if (_editMode) {
            [_savedSections removeAllObjects];
            [_categoriesSection removeAllItems];
        }
    }
}

- (NSArray *)formValidResponse:(id)response withKey:(NSString *)key {
    if (response != nil && response[key] != nil && [response[key] isKindOfClass:NSArray.class]) {
        return response[key];
    }
    return @[];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_adForm.plan != nil) {
        _categoryBox.planTitle = _adForm.plan.title;
    }
}

- (void)buildFormTable {
    self.title = self.editMode ? self.listing.title : FLLocalizedString(@"screen_al_fillout_form");
    _categoryBox.planTitle = _adForm.plan ? _adForm.plan.title : FLLocalizedString(@"select_plan");
    _categoryBox.editCategoryBtnActive = !self.editMode;
    _categoryBox.planBtnActive = YES;

    [self.manager removeAllSections];
    _formState = FLFormStateFillOut;
//    _langSelectorBtn.hidden = NO;

    if (_savedFormSections.count) {
        _headers = [NSMutableArray arrayWithArray:_savedHeaders];

        for (RETableViewSection *section in _savedFormSections) {
            [_manager addSection:section];
        }
    }
    else {
        for (NSDictionary *sectionDict in _adForm.fields) {
            RETableViewSection *section = [RETableViewSection section];
            [_headers addObject:FLCleanString(sectionDict[@"name"])];
            [self.manager addSection:section];

            if (sectionDict[@"fields"] != nil) {
                for (NSDictionary *fieldDict in sectionDict[@"fields"]) {
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
                    [section addItem:item];
                }
            }
        }
    }

    if (_plansManager.plans.count == 1) {
        FLPlanModel *planModel = [_plansManager.plans firstObject];

        if (!planModel.paymentIsRequired) {
            [_categoryBox removePlanBoxFromSuperview];
            [self updateMediaSectionsBasedOnPlan:planModel];
            [self.adForm setPlan:planModel];
        }
    }
    else if (self.editMode) {
        [self updateMediaSectionsBasedOnPlan:_adForm.plan];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView setTableFooterView:[self tableFooterSubmitButton]];
        [_tableView reloadData];
    });
}

- (void)actionBarDoneButtonTapHandler:(FLFieldSelect *)field {
    if ([field.value isKindOfClass:FLListingTypeModel.class]) {
        FLListingTypeModel *listingType = (FLListingTypeModel *)field.value;

        if (_adForm.listingType == nil || field.valueChanged) {
            _adForm.listingType = listingType;
            _adForm.category = nil;

            [_listingTypeSection setFooterTitle:FLLocalizedString(@"loading")];
            [self.tableView reloadData];

            [self loadWithParams:@{@"cmd": @"categories",
                                   @"ltype_key": listingType.key,
                                   @"all": @(YES)}
                      completion:^{
                          [_categoriesSection setFooterTitle:FLLocalizedString(@"select_category")];

                          dispatch_async(dispatch_get_main_queue(), ^{
                              [_listingTypeSection setFooterTitle:nil];

                              if ([self.manager.sections indexOfObject:_categoriesSection] == NSNotFound) {
                                  [self.manager addSection:_categoriesSection];
                                  [self.tableView reloadData];
                              }
                          });
                      }];
            [self removeAllItemsBelowItem:field];
        }
    }
    else if ([field.value isKindOfClass:FLCategoryModel.class]) {
        FLCategoryModel *category = (FLCategoryModel *)field.value;

        if (_adForm.category == nil || field.valueChanged) {
            _adForm.category = category;

            [self removeAllItemsBelowItem:field];

            if (category.children) {
                [_categoriesSection setFooterTitle:FLLocalizedString(@"loading")];
                _categoriesSection.footerHeight = 25;

                [self loadWithParams:@{@"cmd": @"categories",
                                       @"ltype_key": _adForm.listingType.key,
                                       @"category_id": [NSNumber numberWithInteger:category.cId],
                                       @"all": @(YES)}
                          completion:^{
                              [self removeTableFooterViewIfNecessary:category];
                          }];
            }
            else {
                [self removeTableFooterViewIfNecessary:category];
                [self.tableView reloadData];
            }
        }
    }
    else if (field.value == nil) {
        if (!_listingTypeSection) {
            _adForm.category = nil;
        }

        [self removeAllItemsBelowItem:field];

        if ([self sectionTypeOfField:field is:FLSectionTypeCategory]) {
            if (_categoriesSection.items.count > 1) {
                for (NSInteger i = _categoriesSection.items.count - 1; i >= 0; i--) {
                    FLFieldSelect *item = _categoriesSection.items[i];

                    if (item.value) {
                        _adForm.category = item.value;
                        break;
                    }
                }
            } else if (_categoriesSection.items.count == 1) {
                [_categoriesSection setFooterTitle:FLLocalizedString(@"select_category")];
                self.tableView.tableFooterView = nil;
                _adForm.category = nil;
            }
        }
    }
}

- (void)clearFormSectionsIfNecessary {
    if (_adForm.savedCategory && _adForm.savedCategory != _adForm.category && _savedFormSections.count) {
        _adForm.savedCategory = _adForm.category;

        [_savedFormSections removeAllObjects];
        [_savedHeaders removeAllObjects];

        _plansManager.plans  = [NSMutableArray array];
        _adForm.fields       = @[];
    }
}

#pragma mark - flynaxAPIClient

- (void)loadWithParams:(NSDictionary *)params {
    [self loadWithParams:params completion:nil];
}

- (void)loadWithParams:(NSDictionary *)params completion:(dispatch_block_t)completionBlock {
    [flynaxAPIClient getApiItem:kApiItemRequests
                     parameters:params
                     completion:^(NSArray *response, NSError *error) {
                         if (error == nil && [response isKindOfClass:NSArray.class]) {
                             if (response.count) {
                                 [self appendCategoryFieldWithCategories:response
                                                              completion:completionBlock];
                             }
                         }
                         else [FLDebug showAdaptedError:error apiItem:kApiItemRequests];

                         dispatch_async(dispatch_get_main_queue(), ^{
                             [_tableView reloadData];
                         });
                     }];
}

- (void)appendCategoryFieldWithCategories:(NSArray *)categories
                               completion:(dispatch_block_t)completionBlock
{
    NSMutableArray *values = [NSMutableArray array];
    FLCategoryModel *selectedCategoryModel = nil;

    if (_adForm.listingType) {
        NSString *sortingKey = _adForm.listingType.categoriesSortBy;
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:sortingKey ascending:YES];
        categories = [categories sortedArrayUsingDescriptors:@[descriptor]];
    }

    for (NSDictionary *category in categories) {
        FLCategoryModel *categoryModel = [FLCategoryModel fromDictionary:category];

        // for edit mode only
        if ([_adForm.categoriesIDs containsObject:@(categoryModel.cId)]) {
            selectedCategoryModel = categoryModel;
        }
        [values addObject:categoryModel];
    }

    NSString *fieldTitleKey = _categoriesSection.items.count > 0 ? @"listing_sub_category" : @"listing_category";
    FLFieldSelect *field = [FLFieldSelect withTitle:FLLocalizedString(fieldTitleKey) options:values];

    // for edit mode only
    if (selectedCategoryModel) {
        field.value = selectedCategoryModel;
    }

    [_categoriesSection addItem:field];

    if (completionBlock != nil) {
        completionBlock();
    }

    field.actionBarDoneButtonTapHandler = ^void(FLFieldSelect *item) {
        [self actionBarDoneButtonTapHandler:item];
    };
}

#pragma mark - Helpers

- (void)removeTableFooterViewIfNecessary:(FLCategoryModel *)category {
    [_categoriesSection setFooterTitle:nil];

    if (category.locked) {
        [self.tableView setTableFooterView:nil];
        [_categoriesSection setFooterTitle:FLLocalizedString(@"add_listing_locked_category_warning")];
    }
}

- (BOOL)sectionTypeOfField:(RETableViewItem *)field is:(FLSectionType)sectionType {
    return [self sectionTypeOfField:field] == sectionType;
}

- (FLSectionType)sectionTypeOfField:(RETableViewItem *)field {
    if (_listingTypeSection != nil && field.indexPath.section == 0) {
        return FLSectionTypeListingType;
    }
    return FLSectionTypeCategory;
}

- (void)removeAllItemsBelowItem:(FLFieldSelect *)item {
    if (_adForm.category && !_adForm.category.locked) {
        self.tableView.tableFooterView = [self tableFooterSelectCategoryBtn];
    }
    else {
        self.tableView.tableFooterView = nil;
        _categoriesSection.footerTitle = FLLocalizedString(@"select_category");
    }

    if ([self sectionTypeOfField:item is:FLSectionTypeListingType]) {
        [_categoriesSection removeAllItems];
        [self.manager removeSection:_categoriesSection];

        if (item.value == nil) {
            _adForm.listingType = nil;
            _listingTypeSection.footerTitle = FLLocalizedString(@"add_listing_listing_type_hint");
        }
        _adForm.category = nil;

        self.tableView.tableFooterView = nil;
        [self.tableView reloadData];
    }
    else {
        [self removeItemsAfterIndex:item.indexPath.row + 1 forSection:_categoriesSection withReload:YES];
    }
}

- (void)removeItemsAfterIndex:(NSUInteger)index forSection:(RETableViewSection *)section withReload:(BOOL)reload {
    NSMutableArray *items2remove = [NSMutableArray array];
    [section.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx >= index) {
            [items2remove addObject:obj];
        }
    }];
    [section removeItemsInArray:items2remove];

    if (reload) {
        [self.tableView reloadData];
    }
}

#pragma mark - RETableViewManagerDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    RETableViewSection *section = [self.manager.sections objectAtIndex:indexPath.section];
    RETableViewItem *item = [section.items objectAtIndex:indexPath.row];

    if ([item isKindOfClass:FLFieldCheckbox.class]) {
        cell.backgroundColor = [UIColor clearColor];
        UIImage *accessoryImage = [UIImage imageNamed:@"select_icon"];
        cell.accessoryView = [[UIImageView alloc] initWithImage:accessoryImage];
        ((FLFieldCheckbox *)item).rowCell = cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self sectionHeaderTitleForSection:section] ? kTableSectionHeight : 0;
}

- (NSString *)sectionHeaderTitleForSection:(NSInteger)section {
    if (!_headers.count) return nil;
    if (section > _headers.count - 1) return nil;

    NSString *expectedTitle = FLCleanString(_headers[section]);

    if (expectedTitle.length) {
        return expectedTitle;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self sectionHeaderTitleForSection:section];
    if (!title) return nil;

    NSString *cellIdentifier = F(@"%@_section", self.class);
    FLTableSection *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellIdentifier];

    if (header == nil) {
        header = [[FLTableSection alloc] initWithReuseIdentifier:cellIdentifier];
    }
    header.textLabel.text = title;

    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(FLTableSection *)view forSection:(NSInteger)section {
    NSString *sectionTitle = view.textLabel.text;

    if (_formState == FLFormStateFillOut) {
        view.textLabel.textColor = [UIColor whiteColor];

        if (_adForm.plan != nil) {
            if (section == _sectionPictures) {
                if (_adForm.plan.imagesUnlim) {
                    sectionTitle = F(@"%@ %@", localizedSectionAddPictures, FLLocalizedString(@"unlimited"));
                } else {
                    sectionTitle = F(FLLocalizedString(@"pictures_divider_left"), self.photoGallery.itemsLeft, _adForm.plan.imagesMax);
                }
            }
            else if (section == _sectionVideos) {
                if (_adForm.plan.videosUnlim) {
                    sectionTitle = F(@"%@ %@", localizedSectionAddYouTube, FLLocalizedString(@"unlimited"));
                } else {
                    sectionTitle = F(FLLocalizedString(@"videos_divider_left"), self.ytVideoGallery.itemsLeft, _adForm.plan.videosMax);
                }
            }
        }
    }
    view.textLabel.text = [sectionTitle capitalizedString];
    view.textLabel.font = [UIFont boldSystemFontOfSize:15];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (_adForm.category == nil || _adForm.category.locked) return nil;

    if (_sectionPictures && section == _sectionPictures) {
        return self.photoGallerySectionView;
    }
    else if (_sectionVideos && section == _sectionVideos) {
        return self.ytVideoGallerySectionView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (_sectionPictures && section == _sectionPictures) return self.photoGallerySectionView.height;
    else if (_sectionVideos && section == _sectionVideos) return self.ytVideoGallerySectionView.height;
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UITableViewHeaderFooterView *)view forSection:(NSInteger)section {
    if (_formState == FLFormStateSelectCategory && _adForm.category && _adForm.category.locked) {
        view.textLabel.textColor = [UIColor redColor];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - FLCategoryBoxDelegate

- (void)categoryBox:(FLCategoryBox *)box buttonTapped:(FLCategoryBoxBtn)button {
    if (button == FLCategoryBoxBtnEdit) {
        [self displayConfirmWithTitle:@"dialog_confirm_action" message:@"dialog_change_category_notice" confirmBlock:^{

            /* save fillout state */
            [_savedHeaders removeAllObjects];
            [_savedHeaders addObjectsFromArray:_headers];

            [_savedFormSections removeAllObjects];
            [_savedFormSections addObjectsFromArray:self.manager.sections];
            /* save fillout state end */

            [_headers removeAllObjects];
            [self.manager removeAllSections];
            [self buildSelectCategoryStep];
            [self.tableView reloadData];
        }];
    }
    else if (button == FLCategoryBoxBtnSelectPlan) {
        if (_adForm.category != nil) {
            FLNavigationController *selectPlanNC = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAASelectPlanView];
            selectPlanNC.modalPresentationStyle = UIModalPresentationCurrentContext;
            [self.navigationController presentViewController:selectPlanNC animated:YES completion:nil];

            ((FLListingSelectPlan *)selectPlanNC.topViewController).completionBlock = ^(FLPlanModel *listingPlan) {
                if (listingPlan) {
                    self.adForm.plan                = listingPlan;
                    self.categoryBox.planTitleColor = kPlanTitleColorNormal;
                    self.categoryBox.planTitle      = _adForm.plan.title;

                    [self updateMediaSectionsBasedOnPlan:listingPlan];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            };
        }
    }
}

- (void)updateMediaSectionsBasedOnPlan:(FLPlanModel *)adPlan {
    self.photoGallery.itemsLimit    = adPlan.imagesMax;
    self.ytVideoGallery.itemsLimit  = adPlan.videosMax;

    if (adPlan.imagesMax && _adForm.listingType.photo && _sectionPictures == NSNotFound) {
        RETableViewSection *section = [RETableViewSection section];
        [_headers addObject:localizedSectionAddPictures];
        [self.manager addSection:section];
        _sectionPictures = self.manager.sections.count - 1;
    }
    // Remove pictures section
    else if (adPlan.imagesMax == 0 && _sectionPictures != NSNotFound) {
        [self.manager removeSectionAtIndex:_sectionPictures];
        [_headers removeObject:localizedSectionAddPictures];
        _sectionPictures = NSNotFound;
    }
    
    if (adPlan.videosMax && _adForm.listingType.video && _sectionVideos == NSNotFound) {
        RETableViewSection *section = [RETableViewSection section];
        [_headers addObject:localizedSectionAddYouTube];
        [self.manager addSection:section];
        _sectionVideos = self.manager.sections.count - 1;
    }
    // remove YouTube section
    else if (adPlan.videosMax == 0 && _sectionVideos != NSNotFound) {
        [self.manager removeSectionAtIndex:_sectionVideos];
        [_headers removeObject:localizedSectionAddYouTube];
        _sectionVideos = NSNotFound;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.ytVideoGallery reload];
        [self.photoGallery reload];
    });
}

#pragma mark - Helpers

- (void)displayConfirmWithTitle:(NSString *)titleKey message:(NSString *)mesageKey confirmBlock:(dispatch_block_t)confirmBlock {
    CCAlertView *alert = [[CCAlertView alloc] initWithTitle:FLLocalizedString(titleKey)
                                                    message:FLLocalizedString(mesageKey)];
    [alert addButtonWithTitle:FLLocalizedString(@"button_yes") block:confirmBlock];
    [alert addButtonWithTitle:FLLocalizedString(@"button_no") block:nil];
    [alert show];
}

#pragma mark - Media Gallery Getters

- (FLImageMediaGallery *)photoGallery {
    if (_photoGallery == nil) {
        CGRect frame = CGRectMake(kGlobalPadding, kGlobalPadding, _tableView.width - kGlobalPadding * 2, 0);
        _photoGallery            = [[FLImageMediaGallery alloc] initWithFrame:frame];
        _photoGallery.delegate   = self;
        _photoGallery.itemsLimit = _adForm.plan ? _adForm.plan.imagesMax : 1;

        if (_adForm.photos.count) {
            [_photoGallery loadFromArray:_adForm.photos];
        }
    }
    return _photoGallery;
}

- (FLYouTubeGallery *)ytVideoGallery {
    if (_ytVideoGallery == nil) {
        CGRect frame = CGRectMake(kGlobalPadding, kGlobalPadding, _tableView.width - kGlobalPadding * 2, 0);
        _ytVideoGallery               = [[FLYouTubeGallery alloc] initWithFrame:frame];
        _ytVideoGallery.delegate      = self;
        _ytVideoGallery.itemsSpacing  = 1;
        _ytVideoGallery.itemsLimit    = _adForm.plan ? _adForm.plan.videosMax : 1;
        _ytVideoGallery.sectionInsets = UIEdgeInsetsMake(0, 0, kGlobalPadding, 0);

        if (_adForm.videos.count) {
            [_ytVideoGallery loadFromArray:_adForm.videos];
        }
    }
    return _ytVideoGallery;
}

#pragma mark - Media Gallery Section Views

- (UIView *)photoGallerySectionView {
    if (!_photoGallerySectionView) {
        _photoGallerySectionView = [[UIView alloc] initWithFrame:CGRectZero];
        [_photoGallerySectionView addSubview:self.photoGallery];
    }
    _photoGallerySectionView.height = self.photoGallery.height + kGlobalPadding * 2;

    return _photoGallerySectionView;
}

- (UIView *)ytVideoGallerySectionView {
    if (!_ytVideoGallerySectionView) {
        _ytVideoGallerySectionView = [[UIView alloc] initWithFrame:CGRectZero];
        [_ytVideoGallerySectionView addSubview:self.ytVideoGallery];
    }
    _ytVideoGallerySectionView.height = self.ytVideoGallery.height + kGlobalPadding * 2;

    return _ytVideoGallerySectionView;
}

#pragma mark - Media Gallery Delegate

- (void)mediaGalleryDidStartAdding:(FLMediaGallery *)mediaGallery {
    if (_adForm.plan != nil) {
        if (mediaGallery == _photoGallery) {
            [self pickAnImage];
        }
        else if (mediaGallery == _ytVideoGallery) {
            [self pickAYouYubeVideo];
        }
    }
    else [self alertNoPlanSelected];
}

- (void)mediaGallery:(FLMediaGallery *)mediaGallery didRemoveItemCell:(FLMediaGalleryItemCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (mediaGallery == _photoGallery) {
        FLImageMGItemModel *item = cell.data;

        if (!item.newModel) {
            [_adForm.removedPhotoIDs addObject:@(item.imageId)];
        }
    }
    [_tableView reloadData];
}

- (void)mediaGalleryDidAddItem:(FLMediaGallery *)mediaGallery {
    [_tableView reloadData];
}

- (void)mediaGallery:(FLMediaGallery *)mediaGallery didChangeContentSize:(CGSize)contentSize {
    if (mediaGallery == _photoGallery || mediaGallery == _ytVideoGallery) {
        mediaGallery.height = contentSize.height;
        [_tableView reloadData];
    }
}

- (void)pickAnImage {
    _assetsPicker = [[FLAssetsPickerController alloc] init];
    _assetsPicker.modalPresentationStyle        = UIModalPresentationCurrentContext;
    _assetsPicker.maximumNumberOfSelectionPhoto = self.photoGallery.itemsLeft;
    _assetsPicker.maximumNumberOfSelectionVideo = 0;
    _assetsPicker.delegate = self;
    [self presentViewController:_assetsPicker animated:YES completion:nil];
}

- (void)pickAYouYubeVideo {
    _ytAddController = [FLYTAddingViewController controllerWithClassNibName];
    _ytAddController.delegate = self;

    _ytAddController.flNavigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:_ytAddController.flNavigationController animated:YES completion:nil];
}

- (void)pickALocalVideo {
    // TODO: for future purpose
}

#pragma mark - YouTube Adding Delegate

- (void)ytAddingController:(FLYTAddingViewController *)controller didFinishWith:(FLYouTubeMGItemModel *)model {
    [_ytVideoGallery addItem:model];
}

#pragma mark - UzysAssetsPickerController delegate

- (void)uzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    [_photoGallery loadFromAssets:assets];
}

#pragma mark - Actions

- (void)phtotoMediaGalleryDidStartEdition:(NSNotification *)notification {
    [self presentViewController:self.assetsPicker animated:YES completion:nil];
}

- (void)submitBtnTapped {
    if (!_adForm.plan) {
        [self alertNoPlanSelected];
    }
    else if ([self.manager isValidForm] && self.manager.formAccepted) {
        [self prepareListingDataAndSendToAPI];
    }
    else if (!self.manager.formAccepted) {
        [FLProgressHUD showErrorWithStatus:[FLFieldAccept agreeFieldRequiredMessage:self.manager.fieldAcceptTitle]];
    }
    else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"fill_required_fields")];
}

- (NSDictionary *)listingDataToSend {
    NSString *_cmdRequest = _listing != nil ? kApiItemRequests_editListing : kApiItemRequests_addListing;

    NSMutableDictionary *data = [@{@"cmd"      : _cmdRequest,
                                   @"ltype"    : _adForm.listingType.key,
                                   @"category" : @(_adForm.category.cId),
                                   @"plan"     : @(_adForm.plan.pId),
                                   @"f"        : self.manager.formValues} mutableCopy];

    // remove photo id's
    if (_adForm.removedPhotoIDs.count) {
        data[@"removed_picture_ids"] = _adForm.removedPhotoIDs;
    }

    // edit mode: append listing id
    if (_listing) {
        data[@"lid"] = @(_listing.lId);
    }

    // append plan appearence
    data[@"plan_mode"] = _adForm.plan.planMode == FLPlanModeFeatured ? @"featured" : @"standart";

    // append YouTube video's if exists
    if (_adForm.listingType.video && _ytVideoGallery.items.count) {
        NSMutableArray *youtubeVideos = [NSMutableArray array];

        for (FLYouTubeMGItemModel *item in _ytVideoGallery.items) {
            [youtubeVideos addObject:@{@"ytid" : item.youTubeId,
                                       @"title": item.title}];
        }

        data[@"youtube_videos"] = youtubeVideos;
    }

    return data;
}

- (void)prepareListingDataAndSendToAPI {
    [FLProgressHUD showWithStatus:FLLocalizedString(@"processing")];

    [flynaxAPIClient postApiItem:kApiItemRequests
                      parameters:[self listingDataToSend]
                      completion:^(NSDictionary *response, NSError *error) {

                          if (!error && [response isKindOfClass:NSDictionary.class]) {
                              if (FLTrueBool(response[@"success"])) {
                                  _adForm.listingId = _listing ? _listing.lId : FLTrueInteger(response[@"listing_id"]);

                                  [self uploadMediaContentForListingById:_adForm.listingId];
                              }
                              else [FLProgressHUD showErrorWithStatus:FLLocalizedString(response[@"error_message_key"])];
                          }
                          else [FLDebug showAdaptedError:error apiItem:kApiItemRequests_addListing];
                      }];
}

- (void)uploadMediaContentForListingById:(NSInteger)listingId {
    if (_adForm.listingType.photo && _photoGallery.items.count) {
        [FLMediaUploader uploadItems:_photoGallery.items forListingId:listingId withCompletion:^{
            [self moveToMyListingsControllerWithSuccessMessage];
        }];
    }
    else [self moveToMyListingsControllerWithSuccessMessage];
}

- (void)moveToMyListingsControllerWithSuccessMessage {
    NSString *myListingsSID = ([FLListingTypes typesCount] == 1)
    ? kStoryBoardMyListingsView
    : kStoryBoardMyListingsRootView;

    id myListingsVC = [self.storyboard instantiateViewControllerWithIdentifier:myListingsSID];

    FLRootView *rootController = (FLRootView *)[[UIApplication sharedApplication] keyWindow].rootViewController;
    FLMainNavigation *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardContentController];
    navigationController.viewControllers = @[myListingsVC];

    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        rootController.contentViewController = navigationController;
        BOOL editMode = (_listing != nil);

        if (!editMode && [_adForm.plan paymentIsRequired]) {
            // Prepare alert message
            NSString *alertMessage = FLLocalizedStringReplace(@"listing_added_payment_required", @"{price}", _adForm.plan.localizedPrice);
            CCAlertView *alertPaymentRequired = [[CCAlertView alloc] initWithTitle:nil message:alertMessage];
            [alertPaymentRequired addButtonWithTitle:FLLocalizedString(@"button_pay_now") block:^{
                // Prepare order details
                FLOrderModel *order = [FLOrderModel withItem:(_adForm.plan.advancedMode ? FLOrderItemPackage : FLOrderItemListing)];
                order.itemId = _adForm.listingId;
                order.plan   = _adForm.plan;

                // post order to subscribed controller (myAds)
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMakePayment
                                                                    object:nil
                                                                  userInfo:@{kOrderFromNotification: order}];
            }];
            [alertPaymentRequired addButtonWithTitle:FLLocalizedString(@"button_pay_later") block:nil];
            [alertPaymentRequired show];
        }
        else [[FLLang sharedInstance] showSuccessUpdatedListing:editMode];
    }];
}

#pragma mark - UIViewController Property

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Navigation

- (FLNavigationController *)flNavigationController {
    if (!_flNavigationController) {
        _flNavigationController = [[FLNavigationController alloc] initWithRootViewController:self];
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:FLLocalizedString(@"button_cancel")
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(cancelButtonDidTap:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    return _flNavigationController;
}

- (void)cancelButtonDidTap:(UIButton *)button {
    if (_adForm.listingType != nil && _adForm.category != nil && _adForm.fields.count) {
        [self displayConfirmWithTitle:@"dialog_title_warning" message:@"dialog_discard_listing" confirmBlock:^{
            [FLPlansManager restoreToDefaults];
            [_adForm resetForm];
            [self dismissVC];
        }];
    }
    else [self dismissVC];
}

- (void)dismissVC {
    [flynaxAPIClient cancelAllTasks];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
