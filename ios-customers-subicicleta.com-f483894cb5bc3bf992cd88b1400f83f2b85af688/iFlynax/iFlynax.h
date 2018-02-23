//
//  iFlynax.h
//  iFlynax
//
//  Created by Alex on 4/8/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

	
static NSString * const kFlynaxAPISynchCode  = @"7e576f277d633b2d5a28232540";
static NSString * const kFlynaxAPIUserAgent  = @"subicicleta.com iOS App v3";
static NSString * const kFirstReleaseAppDate = @"Aug 30, 2017";
static NSString * const kMinAPIVersion       = @"3.0.0";

// Change the ID also in iFlynax-info.plist
static NSString * const kFacebookAppID = @"211114288978700";

static BOOL const kForceLoadCache   = NO;
static BOOL const kDebugAPIResponse = NO;

// The Solution is offered as a free Application carrying Flynax label.
static BOOL const kLabeledSolution = NO;

// Paid features or not userfull for all
static BOOL const kFeatureDefaultLanguageBasedOnDeviceLanguage = YES;
static BOOL const kFeatureExtendedRegistration = NO;


#import "FLUtilities.h"

/* import libs */
#import "FLProgressHUD.h"

/* import categories */
#import "UIImageView+AFNetworking.h"
#import "UIImage+ProportionalFill.h"
#import "UIView+MGEasyFrame.h"
#import "NSString+Crypto.h"
#import "UIColor+HEX.h"

/* import classes */
#import "FLUserDefaults.h"
#import "FLAppSession.h"
#import "FLValid.h"
#import "FLConfig.h"
#import "FLDebug.h"
#import "FLCache.h"
#import "FLLang.h"
#import "FLListingTypes.h"
#import "FLAccountTypes.h"
#import "FLAccount.h"
#import "flynaxAPIClient.h"
#import "FLFavorites.h"
#import "FLBlankSlate.h"

/* import models */
#import "FLAdShortDetailsModel.h"

/* import root's */
#import "FLAdDetailsRootView.h"

/* macros defines */
#define NAVIFY(controller) [[UINavigationController alloc] initWithRootViewController:controller]
#define URLIFY(urlString) [NSURL URLWithString:(urlString)]
#define F(string, args...) [NSString stringWithFormat:string, args]
#define FLLocalizedString(key) [FLLang langWithKey:(key)]

#define FLLocalizedStringReplace(key, searchString, replaceString) [FLLang langWithKey:key search:searchString replace:replaceString]

#define FLHexColor(hex) [UIColor hexColor:(hex)]
#define FLCleanString(input) [FLValid cleanString:(input)]
#define FLConfigWithKey(key) [FLConfig withKey:(key)]
#define FLAppSessionWithKey(key) [FLAppSession itemWithKey:(key)]
#define FLUserInfo(key) [FLAccount userInfo:(key)]

// UI
#define FLMainScreen [UIScreen mainScreen]
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE_5 (!IS_IPAD && [FLMainScreen bounds].size.height == 568)
#define IS_IPHONE_6 (!IS_IPAD && [FLMainScreen bounds].size.width == 375)
#define IS_IPHONE_6_PLUS (!IS_IPAD && [FLMainScreen respondsToSelector:@selector(nativeScale)] == YES && [FLMainScreen nativeScale] == 3.0f)
#define IS_LOGIN [FLAccount isLogin]
#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale >= 2.0))
#define IS_NOT_RETINA (!IS_RETINA)
#define IS_RTL ([FLLang direction] == FLLanguageDirectionRTL)

/* UI */
static CGFloat    const kStatusBarHeight           = 20.0f;
static NSString * const kColorThemeGlobal          = @"f2cf15";
static NSString * const kColorThemePrice           = @"eaae0d"; // @"f2cf15";
static NSString * const kColorThemeHomePrice       = @"f2cf15";
static NSString * const kColorThemeLinks           = @"006ec2";

static CGFloat    const kSideMenuWidth             = 270.0f;
static CGFloat    const kSideMenuSwipeLocationMinX = 50.0f;
static NSString * const kColorGlobalTintColor      = @"ffffff";
static NSString * const kColorBackgroundColor      = @"d4d4d4";
static NSString * const kColorBarTintColor         = @"0f1c1e";
static NSString * const kColorPlaceholderFont      = @"808080";
static NSString * const kColorFieldHasError        = @"a13449";
static NSString * const kColorFLTextFieldBorder    = @"919191";
// menu
static NSString * const kColorMenuBadgeFill        = @"f2cf15";
static NSString * const kColorMenuSeparator        = @"425052";
static NSString * const kColorMenuBackground       = @"212c2e";
static NSString * const kColorMenuSectionTitle     = @"898989";
static NSString * const kColorMenuSeparatorStroke  = @"0f1c1e";
// tabs
static NSString * const kColorTabsBackground         = @"474747";
static NSString * const kColorTabsText               = @"d3d3d3";
static NSString * const kColorTabsSelectionIndicator = @"f2cf15";
static NSString * const kColorTabsSelectedText       = @"ffffff";
static CGFloat    const kTabsTextFontSize            = 12.0f;
// index bar
static NSString * const kColorIndexBarBackground         = @"fbfbfb";
static NSString * const kColorIndexBarText               = @"474747";
static NSString * const kColorIndexBarSelectedBackground = @"f2cf15";
// FLView
static NSString * const kColorFLViewBackground = @"e5e5e5";
static NSString * const kColorFLViewDefaultCenterLine = @"f2cf15";
static NSString * const kColorFLViewDefaultBottomLine = @"aaaaaa";

static NSString * const kColorFLPhotosCountText         = @"1b1b1b";
static NSString * const kColorInputAccessoryToolbarTint = @"474747";
static NSString * const kColorRadioButtonIndicatorColor = @"f2cf15";

static CGFloat    const kTableSectionHeight   = 31.0f;
static CGFloat    const kStaticMenuHeight     = 100.0f; //deprecated
static CGFloat    const kGlobalPadding        = 15.0f;

// Google Admob
static NSString * const kGoogleAdTestDeviceID = @"7455f4710ae6e4456f6cc7ed9743f923";
static CGFloat    const kGoogleAdHeight       = 50;

/* Hint validation */
static CGFloat const kValidationTooltipDelay = 0.75f; // Set 0 to display immediately

/* Maps */
static NSString * const kMapDefaultLocationZoomKey = @"map_default_location_zoom";
static NSString * const kGoogleMapAPIKey           = @"google_map_api_key";

/* storyboard identifiers */
static NSString * const kStoryBoardMenuItemCell                    = @"menuItemCell";
static NSString * const kStoryBoardContentController               = @"contentController";
static NSString * const kStoryBoardMenuController                  = @"menuController";
static NSString * const kStoryBoardHomeCollectionItemCell          = @"collectionItemCell";
static NSString * const kStoryBoardCollectionItemCellComments      = @"collectionItemCellComments";
static NSString * const kStoryBoardDetailsCollectionItemCustomCell = @"detailsCollectionItemCustomCell";
static NSString * const kStoryBoardHomeCollectionLoading           = @"homeLoadingIdentifier";
static NSString * const kStoryBoardSellerInfoCellIdentifier        = @"sellerCellIdentifier";
static NSString * const kStoryBoardSellerInfoCellIdentifierImage   = @"sellerCellIdentifierImage";
static NSString * const kStoryBoardAdsCellIdentifier               = @"flAdsCellIdentifier";
static NSString * const kStoryBoardMyListingsCellIdentifier        = @"myListingsCellIdentifier";
static NSString * const kStoryBoardPlansCellIdentifier             = @"FLCollectionPlansCell";
static NSString * const kStoryBoardAccountCellIdentifier           = @"flAccountCellIdentifier";
static NSString * const kStoryBoardCommentCellIdentifier           = @"commentCell";

// custom Nib's
static NSString * const kNibNameLShortFormViewCell = @"FLAdsViewCell";
static NSString * const kNibNameMyListingsViewCell = @"FLMyListingsCell";
static NSString * const kNibNameAccountViewCell    = @"FLAccountCell";
static NSString * const kNibNameCommentCell        = @"FLCommentCell";
static NSString * const kNibNameKeywordSearchCell  = @"FLKeywordSearchCell";

// controllers
static NSString * const kStoryBoardHomeView               = @"homeController";
static NSString * const kStoryBoardSearchView             = @"searchController";
static NSString * const kStoryBoardNearbyAdsView          = @"nearbyAdsController";
static NSString * const kStoryBoardRecentlyAdsView        = @"recentlyAdsController";
static NSString * const kStoryBoardPhotosGalleryView      = @"photosGalleryView";
static NSString * const kStoryBoardFavoriteAdsView        = @"favoriteAdsView";
static NSString * const kStoryBoardLoginFormView          = @"loginFormController";
static NSString * const kStoryBoardBrowseView             = @"browseViewController";
static NSString * const kStoryBoardMyMessagesView         = @"myMessagesViewController";
static NSString * const kStoryBoardMyListingsView         = @"myListingsViewController";
static NSString * const kStoryBoardAccountTypeView        = @"accountTypeViewController";
static NSString * const kStoryBoardSettingsView           = @"settingsController";
static NSString * const kStoryBoardAboutUsView            = @"aboutUsController";
static NSString * const kStoryBoardLegalView              = @"legalsController";
static NSString * const kStoryBoardEditListingView        = @"editListingController";
static NSString * const kStoryBoardMessagingView          = @"messagingController";
static NSString * const kStoryBoardRemindPasswordVC       = @"remindPasswordVC";
static NSString * const kStoryBoardCommentsView           = @"commentsViewController";
static NSString * const kStoryBoardAddCommentView         = @"addCommentController";
static NSString * const kStoryBoardRegistrationNC         = @"registrationNC";
static NSString * const kStoryBoardRegistrationExtendedNC = @"registrationExtendedNC";
static NSString * const kStoryBoardListingStatisticsNC    = @"listingStatisticsNC";
static NSString * const kStoryBoardPaymentNC              = @"sid_paymentNC";
static NSString * const kStoryBoardSearchResultsVC        = @"sid_searchResultsVC";
static NSString * const kStoryBoardWebStaticPageVC        = @"sid_webStaticPageVC";
static NSString * const kStoryBoardPolicyVC               = @"sid_policyVC";

// - Add Listing controllers -
static NSString * const kStoryBoardAAFillOutFormView    = @"addListingFillOutForm";
static NSString * const kStoryBoardAASelectPlanView     = @"addListingSelectPlan";

// tab host's
static NSString * const kStoryBoardadDetailsRootView      = @"adDetailsRootView";
static NSString * const kStoryBoardRecentlyAdsRootView    = @"recentlyAdsRootView";
static NSString * const kStoryBoardMyProfileRootView      = @"myProfileRootView";
static NSString * const kStoryBoardMyListingsRootView     = @"myListingsRootView";
static NSString * const kStoryBoardAccountTypeRootView    = @"accountTypeRootView";
static NSString * const kStoryBoardAccountDetailsRootView = @"accountDetailsRootView";
static NSString * const kStoryBoardSearchRootView         = @"searchRootView";

// tabs on details
static NSString * const kStoryBoardAdDetailsView       = @"adDetailsView";
static NSString * const kStoryBoardAdSellerInfoView    = @"adSellerInfoView";
static NSString * const kStoryBoardAdOnMapView         = @"adOnMapView";
static NSString * const kStoryBoardAdVideosView        = @"adVideosView";

// tabs on my profile
static NSString * const kStoryBoardMyProfileView           = @"myProfileController";
static NSString * const kStoryBoardMyProfileChangePassword = @"myProfileChangePassword";

// tabs on account by type
static NSString * const kStoryBoardAccountTypeListViewController = @"accountTypeListViewController";
static NSString * const kStoryBoardAccountTypeSearchViewController = @"accountTypeSearchViewController";

// account details
static NSString * const kStoryBoardSellerAdsViewController = @"sellerAdsViewController";

/* storyboard segue identifiers */
static NSString * const kSegueHomeToDetails     = @"goToDetailsFromHome";
static NSString * const kSegueHomeToNearbyAds   = @"goToNearbyAdsFromHome";
static NSString * const kSegueDetailsToComments = @"goToCommensFromDetails";

/* API items */
static NSString * const kApiItemCache         = @"caching";
static NSString * const kApiItemHome          = @"home";
static NSString * const kApiItemAdDetails     = @"listing_details";
static NSString * const kApiItemSellerDetails = @"seller_details";
static NSString * const kApiItemRecentlyAds   = @"new_listings";
static NSString * const kApiItemFavorites     = @"favorites";
static NSString * const kApiItemLogin         = @"login";
static NSString * const kApiItemLogin_default = @"login";
static NSString * const kApiItemLogin_fb      = @"fb_login";
static NSString * const kApiItemMyProfile     = @"my_profile";
static NSString * const kApiItemRequests      = @"requests";
static NSString * const kApiItemMyListings    = @"my_listings";
static NSString * const kApiItemStaticPages   = @"static_pages";

/* API item Requests sub-items */
static NSString * const kApiItemRequests_multifield          = @"multifield";
static NSString * const kApiItemRequests_categories          = @"categories";
static NSString * const kApiItemRequests_listingsByCategory  = @"listingsByCategory";
static NSString * const kApiItemRequests_getAccounts         = @"getAccounts";
static NSString * const kApiItemRequests_searchAccounts      = @"searchAccounts";
static NSString * const kApiItemRequests_fetchSellerInfo     = @"fetchSellerInfo";
static NSString * const kApiItemRequests_getListingsByLatLng = @"getListingsByLatLng";
static NSString * const kApiItemRequests_listingsByAccount   = @"getListingsByAccount";
static NSString * const kApiItemRequests_conversations       = @"conversations";
static NSString * const kApiItemRequests_remove_conversation = @"removeConversation";
static NSString * const kApiItemRequests_sendMessageTo       = @"sendMessageTo";
static NSString * const kApiItemRequests_fetchMessages       = @"fetchMessages";
static NSString * const kApiItemRequests_resetPassword       = @"resetPassword";
static NSString * const kApiItemRequests_addComment          = @"addComment";
static NSString * const kApiItemRequests_getComments         = @"getComments";
static NSString * const kApiItemRequests_registration        = @"registration";
static NSString * const kApiItemRequests_getAddListingData   = @"getAddListingData";
static NSString * const kApiItemRequests_getEditListingData  = @"getEditListingData";
static NSString * const kApiItemRequests_getPlans            = @"getPlans";
static NSString * const kApiItemRequests_addListing          = @"addListing";
static NSString * const kApiItemRequests_editListing         = @"editListing";
static NSString * const kApiItemRequests_removeListing       = @"removeListing";
static NSString * const kApiItemRequests_searchListings      = @"searchListings";
static NSString * const kApiItemRequests_keywordSearch       = @"keywordSearch";
static NSString * const kApiItemRequests_savePicture         = @"savePicture";
static NSString * const kApiItemRequests_validateTransaction = @"validateTransaction";
static NSString * const kApiItemRequests_upgradePlan         = @"upgradePlan";
static NSString * const kApiItemRequests_staticPageContent   = @"staticPageContent";
static NSString * const kApiItemRequests_reportAbuse         = @"reportBrokenListing";

static NSString * const kApiItemRequests_registerForRemoteNotification = @"registerForRemoteNotification";

/* API item My Profile sub-items */
static NSString * const kApiItemMyProfile_profileForm        = @"profileForm";
static NSString * const kApiItemMyProfile_uploadImage        = @"upload_image";
static NSString * const kApiItemMyProfile_profileInfo        = @"profile_info";
static NSString * const kApiItemMyProfile_updateProfile      = @"updateProfile";
static NSString * const kApiItemMyProfile_changePassword     = @"change_password";
static NSString * const kApiItemMyProfile_updateProfileEmail = @"updateProfileEmail";

/* config keys */
static NSString * const kConfigCommentPluginKey        = @"comment_plugin";
static NSString * const kConfigCommentsLoginPost       = @"comments_login_post";
static NSString * const kConfigCommentsLoginAccess     = @"comments_login_access";
static NSString * const kConfigCommentsPerPage         = @"comments_per_page";
static NSString * const kConfigCommentAutoApprovalKey  = @"comments_auto_approval";
static NSString * const kConfigCommentsRatingModuleKey = @"comments_rating_module";
static NSString * const kConfigCommentsStarsNumberKey  = @"comments_stars_number";
static NSString * const kConfigCommentSymbolsNumberKey = @"comments_message_symbols_number";

/* cache */
static CGFloat    const kDefaultRefreshCacheInterval = 1 * 60 * 60; // 1 hour
static NSString * const kLastCacheUpdateKey          = @"cacheUpdateTime";
static NSString * const kDefaultKeyCurrentLanguage   = @"current_lang";
static NSString * const kDefaultKeyAccountToken      = @"accountToken";
static NSString * const kLangKeysKeyPrefix           = @"lang_keys_";

/* cache items */
static NSString * const kCacheCategoriesOneLevel    = @"categories";
static NSString * const kCacheHomeScreenAdsKey      = @"home_screen_ads";
static NSString * const kCacheAccountTypesKey       = @"account_types";
static NSString * const kCacheListingTypesKey       = @"listing_types";
static NSString * const kCacheLanguagesKey          = @"languages";
static NSString * const kCacheLangKeysKey           = @"lang_keys";
static NSString * const kCacheGoogleAdmobKey        = @"google_admob";
static NSString * const kCacheConfigsKey            = @"configs";

static NSString * const kCacheListingFieldsKey      = @"lfields";
static NSString * const kCacheAccountFieldsKey      = @"afields";
static NSString * const kCacheSearchFormsKey        = @"search_forms";
static NSString * const kCacheAccountSearchFormsKey = @"account_search_forms";
static NSString * const kCacheNearbyAdsSFormsKey    = @"nearby_ads_sform";

/* Variables name */
static NSString * const kSessionStaticMapDidTapped       = @"com.flynax.staticMapDidTapped";
static NSString * const kSessionSearchControllerIsActive = @"com.flynax.searchVCisActive";
static NSString * const kSessionPostAdScreenAfterLogin   = @"com.flynax.postAdAfterLogin";
static NSString * const kPreloadTypeConfigsKey           = @"preload_method";

static NSString * const kConditionisPhone = @"isPhone";
static NSString * const kConditionIsEmail = @"isEmail";
static NSString * const kConditionIsUrl   = @"isUrl";
static NSString * const kConditionIsImage = @"isImage";
static NSString * const kPhoneNumberKey   = @"phoneNumber";

/* Local Notification keys */
static NSString * const kNotificationFavoriteBtnDidTap = @"com.flynax.favoriteBtnDidTap";
static NSString * const kNotificationDebugErrors       = @"com.flynax.debugErrors";
static NSString * const kNotificationNewCommentAdded   = @"com.flynax.newCommentAdded";
static NSString * const kNotificationSimulateLogin     = @"com.flynax.SimulateLogin";
static NSString * const kNotificationMakePayment       = @"com.flynax.makePaymentAfterCreateListing";
