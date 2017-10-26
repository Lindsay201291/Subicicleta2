//
//  FLSellerInfoView.m
//  iFlynax
//
//  Created by Alex on 8/21/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLSellerInfoView.h"
#import "FLSellerInfoCell.h"
#import "FLSellerInfoCellImage.h"
#import "FLTabsViewController.h"
#import "FLNavigationController.h"
#import "CCAlertView.h"
#import "FLMessaging.h"

#import "FLAccountDetailsRootViewController.h"

static NSString * const kSellerFullnameKey = @"fullname";
static NSString * const kSellerPhotoKey    = @"photo";
static NSString * const kSellerFieldsKey   = @"fields";

static NSString * const kItemTitleKey      = @"title";
static NSString * const kItemValueKey      = @"value";
static NSString * const kItemConditionKey  = @"condition";

static NSInteger  const kTabSellerAds      = 1;

// helper function: make adaptive title
static NSString *_cellTitle(NSDictionary *entry) {
    return [NSString stringWithFormat:@"%@:", FLCleanString(entry[kItemTitleKey])];
}

@interface FLSellerInfoView () <TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *sellerThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UIButton *otherListingsButton;
@property (nonatomic, strong) NSArray *sellerFields;
@property (weak, nonatomic) IBOutlet UIButton *contactOwnerBtn;
@end

@implementation FLSellerInfoView

- (void)awakeFromNib {
    [super awakeFromNib];

	self.title = FLLocalizedString(@"screen_seller_info");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // modify UI colors
	self.view.backgroundColor = FLHexColor(kColorBackgroundColor);
	_tableView.backgroundColor = self.view.backgroundColor;
    _sellerThumbnail.backgroundColor = FLHexColor(@"eeeeee");

    // modify thumbnail layer
	_sellerThumbnail.layer.borderWidth = 2;
	_sellerThumbnail.layer.borderColor = [UIColor whiteColor].CGColor;
	_sellerThumbnail.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
	_sellerThumbnail.layer.shadowOpacity = 0.75f;

    [self fillViews];

    // prevent to send messages to myself.
    if (IS_LOGIN && [FLAccount loggedUser].userId == FLTrueInteger(_sellerInfo[@"id"])) {
        _contactOwnerBtn.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    self.screenName = F(@"Seller Info (%@)", FLCleanString(_sellerInfo[kSellerFullnameKey]));
	[super viewDidAppear:animated];
}

- (void)fillViews {
   	// set seller fields
    if (_sellerInfo[kSellerFieldsKey] != nil) {
        _sellerFields = _sellerInfo[kSellerFieldsKey];
    }

    // set full name
    _fullName.text = FLCleanString(_sellerInfo[kSellerFullnameKey]);

    /* seller ads count */
    int sellerAdsCount = FLTrueInt(_sellerInfo[@"lcount"]);

    if (sellerAdsCount) {
        NSString *otherListingsTitle = F(FLLocalizedString(@"button_seller_ads_count"), sellerAdsCount);
        [_otherListingsButton setTitle:otherListingsTitle forState:UIControlStateNormal];
    }
    else {
        _otherListingsButton.hidden = YES;
    }
    /* seller ads count END */

    NSURL *sellerThumbnailURL = [NSURL URLWithString:_sellerInfo[kSellerPhotoKey]];

    if (sellerThumbnailURL.scheme.length) {
        NSURLRequest *request = [NSURLRequest requestWithURL:sellerThumbnailURL];
        [_sellerThumbnail setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"loading30x30"]
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                             if (image) {
                                                 _sellerThumbnail.contentMode = UIViewContentModeScaleAspectFit;
                                                 _sellerThumbnail.image = image;
                                             }
                                         } failure:nil];
    }
}

#pragma mark - Navigation

- (FLMessaging *)prepareContactOwnerMessaging {
    FLMessaging *messaging;

    messaging = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardMessagingView];
    messaging.recipient = [NSNumber numberWithInt:[_sellerInfo[@"id"] intValue]];
    messaging.title = FLCleanString(_sellerInfo[@"fullname"]);

    return messaging;
}

- (IBAction)contactOwner:(UIButton *)sender {
    if (IS_LOGIN) {
        FLMessaging *messaging = [self prepareContactOwnerMessaging];
        [self.navigationController pushViewController:messaging animated:YES];
    }
    else [FLProgressHUD showErrorWithStatus:FLLocalizedString(@"messaging_must_logged_in")];
}

- (IBAction)displayAnotherOwnerAds:(UIButton *)sender {
    id visibleController = self.navigationController.visibleViewController;

    if ([visibleController isKindOfClass:NSClassFromString(@"FLAdDetailsRootView")]) {
        FLAccountDetailsRootViewController *accountDetails = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAccountDetailsRootView];
        accountDetails.sellerId = [_sellerInfo[@"id"] integerValue];
        accountDetails.selectedTab = FLAccountDetailsSelectedTabSellerAds;

        FLNavigationController *navigator = [[FLNavigationController alloc] initWithRootViewController:accountDetails];
        [self.navigationController presentViewController:navigator animated:YES completion:nil];
    }
    else if ([visibleController isKindOfClass:NSClassFromString(@"FLAccountDetailsRootViewController")]) {
        FLTabsViewController *tabsController = (FLTabsViewController *)self.navigationController.visibleViewController;
        [tabsController.tabsControl setSelectedSegmentIndex:kTabSellerAds animated:YES];
        [tabsController.tabsControl sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark - UITableViewDataSouce

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sellerFields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *itemInfo = _sellerFields[indexPath.row];

    if (itemInfo[kItemConditionKey] != nil && [itemInfo[kItemConditionKey] isEqualToString:kConditionIsImage]) {
        FLSellerInfoCellImage *cell =
        [tableView dequeueReusableCellWithIdentifier:kStoryBoardSellerInfoCellIdentifierImage];

        cell.fieldTitle.text = _cellTitle(itemInfo);
        cell.imageStringUrl = itemInfo[@"value"];

        return cell;
    }

    FLSellerInfoCell *cell  = [tableView dequeueReusableCellWithIdentifier:kStoryBoardSellerInfoCellIdentifier];
    [self prepareSellerCell:(FLSellerInfoCell *)cell atIndexPath:indexPath];
    
    return cell;
}

- (void)prepareSellerCell:(FLSellerInfoCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *itemInfo = _sellerFields[indexPath.row];

    cell.title = _cellTitle(itemInfo);
    cell.valueLabel.text = FLCleanString(itemInfo[kItemValueKey]);
    cell.valueLabel.delegate = self;
    [cell.valueLabel sizeToFit];
    
    if (itemInfo[kItemConditionKey] != nil) {
        cell.valueLabel.userInfo = itemInfo;
        cell.condition = itemInfo[kItemConditionKey];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *itemInfo = _sellerFields[indexPath.row];

    if (itemInfo[kItemConditionKey] != nil && [itemInfo[kItemConditionKey] isEqualToString:kConditionIsImage]) {
        return 110;
    }

    static FLSellerInfoCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [tableView dequeueReusableCellWithIdentifier:kStoryBoardSellerInfoCellIdentifier];
    });
    
    [self prepareSellerCell:cell atIndexPath:indexPath];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f;
    
}

#pragma mark - TTT

- (void)attributedLabel:(FLAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    BOOL isEmailLink = [url.scheme isEqualToString:@"mailto"];
    NSString *alertTitleKey = isEmailLink ? @"confirm_send_email" : @"confirm_open_in_safary";
    
    CCAlertView *alertView = [[CCAlertView alloc] initWithTitle:FLLocalizedString(alertTitleKey) message:url.relativeString];
    [alertView addButtonWithTitle:FLLocalizedString(@"button_yes") block:^{
        [[UIApplication sharedApplication] openURL:url];
    }];
    [alertView addButtonWithTitle:FLLocalizedString(@"button_no") block:nil];
    [alertView show];
}

- (void)attributedLabel:(FLAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
	CCAlertView *alertView = [[CCAlertView alloc] initWithTitle:FLLocalizedString(@"confirm_call_number") message:label.userInfo[kItemValueKey]];
	[alertView addButtonWithTitle:FLLocalizedString(@"button_yes") block:^{
		[[UIApplication sharedApplication] openURL:URLIFY(F(@"tel://%@", phoneNumber))];
	}];
	[alertView addButtonWithTitle:FLLocalizedString(@"button_no") block:nil];
	[alertView show];
}

@end
