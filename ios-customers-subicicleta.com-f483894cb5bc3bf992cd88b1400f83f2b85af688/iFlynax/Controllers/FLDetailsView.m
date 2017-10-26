//
//  FLDetailsView.m
//  iFlynax
//
//  Created by Alex on 4/29/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLDetailsView.h"
#import "FLListingPhotos.h"
#import "FLTableSection.h"
#import "FLAdFavoriteButton.h"
#import "FSBasicImage.h"
#import "FLImageTitleView.h"
#import "FSBasicImageSource.h"
#import "FLAdShortDetailsModel.h"
#import "FLCommentCell.h"
#import "FLAddCommentViewController.h"
#import "FLNavigationController.h"
#import "FLCommentModel.h"
#import "FLCommentsView.h"
#import "CCAlertView.h"

static NSString * const kSectionTitleKey  = @"title";
static NSString * const kSectionsKey      = @"sections";
static NSString * const kSellerInfoKey    = @"sellerId";
static NSString * const kPhotosKey        = @"photos";
static NSString * const kRowsKey          = @"rows";

static NSString * const kItemTitleKey     = @"title";
static NSString * const kItemValueKey     = @"value";
static NSString * const kItemTypeKey      = @"type";
static NSString * const kItemConditionKey = @"condition";

static NSString * const kPhotoUrlKey  = @"photo";
static NSString * const kPhotoNameKey = @"desc";

static NSString * const kDetailsHeaderIdentifier         = @"detailsHeaderIdentifier";
static NSString * const kDetailsAdCellInlineIdentifier   = @"detailsAdCellInline";
static NSString * const kDetailsAdCellInblockIdentifier  = @"detailsAdCellInblock";

static NSString * const kBlockFieldTypes = @"textarea,checkbox";

@interface FLDetailsView () <FLListingPhotosDelegate, UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate> {
    NSArray *_blockTypes;
    BOOL _animateInsertedCell;
    CGFloat _footerHeight;
    NSMutableArray *_commentModels;
}

@property (weak, nonatomic) IBOutlet UIView *noCommentsView;
@property (weak, nonatomic) IBOutlet UILabel *noCommentsLabel;
@property (weak, nonatomic) IBOutlet UIButton *addCommentButton;
@property (weak, nonatomic) IBOutlet UIButton *moreCommentsButton;

@property (nonatomic) int commentsOnPage;

@property (nonatomic) BOOL showComments;
@property (nonatomic) BOOL showMoreComments;
@property (nonatomic) BOOL showAddCommentButton;

@end

@implementation FLDetailsView

#pragma mark - Life Circle

- (void)awakeFromNib {
    [super awakeFromNib];

	self.title = FLLocalizedString(@"screen_listing_details");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _showAddCommentButton = YES;
    _showComments         = NO;
    _showMoreComments     = NO;
    _commentModels  = [NSMutableArray new];
    
    _commentsOnPage = 5;
    
    _footerHeight = _detailsTableView.tableFooterView.height;
    
    BOOL loginAccess = [FLConfig boolWithKey:kConfigCommentsLoginAccess];
    if ([FLConfig boolWithKey:kConfigCommentPluginKey] &&
        (!loginAccess || (loginAccess && [FLAccount isLogin]))) {
        
        for (NSDictionary *commentData in _comments)
            [_commentModels addObject:[FLCommentModel fromDictionary:commentData]];
        
        NSDictionary *commentsSection = @{kSectionTitleKey: FLLocalizedString(@"ad_section_comments"),
                                          kRowsKey: [NSMutableArray new]};
        [_entries addObject:commentsSection];
        
        [self resignCommentsSection];
        
        UINib *cellNib = [UINib nibWithNibName:kNibNameCommentCell bundle:nil];
        [self.detailsTableView registerNib:cellNib forCellReuseIdentifier:kStoryBoardCommentCellIdentifier];
        
        [_moreCommentsButton setTitle:FLLocalizedString(@"button_see_more") forState:UIControlStateNormal];
        [_addCommentButton setTitle:FLLocalizedString(@"button_add_comment") forState:UIControlStateNormal];
        
        self.showComments     = _comments.count > 0;
        self.showMoreComments = _comments.count > _commentsOnPage;

        if (![FLAccount isLogin])
            self.showAddCommentButton = [FLConfig boolWithKey:kConfigCommentsLoginPost];
        
        _animateInsertedCell = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newCommentDidSend:)
                                                     name:kNotificationNewCommentAdded
                                                   object:nil];
    }
    else {        
        _detailsTableView.tableFooterView.hidden = YES;
        _detailsTableView.headerView.adCommentsButton.hidden = YES;
        _footerHeight = 0;
        self.showComments = NO;
    }
    
    // apply UI colors
    self.view.backgroundColor = FLHexColor(kColorBackgroundColor);
	self.detailsTableView.backgroundView = nil;
    self.detailsTableView.backgroundColor = [UIColor clearColor];
    self.detailsTableView.headerView.backgroundColor = FLHexColor(kColorBackgroundColor);

    // modify header view
    self.detailsTableView.headerView.titleLabel.text = _shortInfo.title;
    self.detailsTableView.headerView.priceLabel.text = _shortInfo.price;

    // update favorite button
	self.detailsTableView.headerView.favoriteAdsButton.adId = _shortInfo.lId;
	[self.detailsTableView.headerView.favoriteAdsButton updateCurrentState];

    // display listing photos if necessary
    BOOL _showPhotosCollectionView = (_photos != nil && _photos.count);
    self.detailsTableView.headerView.showPhotosCollectionView = _showPhotosCollectionView;

    if (_showPhotosCollectionView) {
        self.detailsTableView.headerView.photosCollection.targetDelegate = self;
        self.detailsTableView.headerView.photosCollection.photosList     = _photos;
    }

    _noCommentsLabel.text = FLLocalizedString(@"blankSlate_no_comments");

    // init block types
    _blockTypes = [kBlockFieldTypes componentsSeparatedByString:@","];
}

- (void)viewDidAppear:(BOOL)animated {
    self.screenName = FLCleanString(F(@"%@ [#id: %@]: %@", self.title, @(_shortInfo.lId), _shortInfo.title));
    [super viewDidAppear:animated];
    
    UIView *footerView = _detailsTableView.tableFooterView;
    footerView.height = _footerHeight;
    self.detailsTableView.tableFooterView = footerView;
}

- (void)resignCommentsSection {
    NSMutableArray *models = _entries.lastObject[kRowsKey];
    [models removeAllObjects];
    
    for (int i = 0; i < _commentModels.count; i++) {
        [models addObject:_commentModels[i]];
        if (i + 1 == _commentsOnPage) break;
    }
}

#pragma mark - Accessors

- (void)setShowComments:(BOOL)show {
    if (_showComments != show)
        _footerHeight += show ? -_noCommentsView.height : _noCommentsView.height;
    _noCommentsView.hidden = show;
    _showComments = show;
}

- (void)setShowMoreComments:(BOOL)show {
    if (_showMoreComments != show)
        _footerHeight += show ? _moreCommentsButton.height : -_moreCommentsButton.height;
    _moreCommentsButton.hidden = !show;
    _showMoreComments = show;
}

- (void)setShowAddCommentButton:(BOOL)show {
    if (_showAddCommentButton != show)
        _footerHeight += show ? _addCommentButton.height : -_addCommentButton.height;
    _addCommentButton.hidden = !show;
    _showAddCommentButton = show;
}

#pragma mark - UITableViewDataSouce

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _entries.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_entries[section][kRowsKey] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([self isIndexPathForCommentCell:indexPath]) {
        FLCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoryBoardCommentCellIdentifier];
        [self prepareCommentCell:cell atIndexPath:indexPath];
        return cell;
    }

    FLDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self properReusableIdForIndexPath:indexPath]];
    [self prepareDetailCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)isIndexPathForCommentCell:(NSIndexPath *)indexPath {
    return _showComments && [_detailsTableView numberOfSections] - 1 == indexPath.section;
}

- (void)prepareDetailCell:(FLDetailsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *itemInfo = _entries[indexPath.section][kRowsKey][indexPath.row];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@:", FLCleanString(itemInfo[kItemTitleKey])];
    cell.detailLabel.text = FLCleanString(itemInfo[kItemValueKey]);

    if (itemInfo[kItemConditionKey] != nil && [cell.detailLabel isKindOfClass:FLAttributedLabel.class]) {
        cell.condition = itemInfo[kItemConditionKey];
        cell.detailLabel.userInfo = itemInfo;
        cell.detailLabel.delegate = self;
    }
    cell.backgroundColor = [UIColor clearColor];
}

- (void)prepareCommentCell:(FLCommentCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FLCommentModel * commentModel = _entries[indexPath.section][kRowsKey][indexPath.row];
    [cell fillWithCommentModel:commentModel];
}

- (NSString *)properReusableIdForIndexPath:(NSIndexPath *)indexPath {
    
    NSString *type = _entries[indexPath.section][kRowsKey][indexPath.row][kItemTypeKey];
    if ([_blockTypes containsObject:type]) {
        return kDetailsAdCellInblockIdentifier;
    }
    return kDetailsAdCellInlineIdentifier;
}

- (NSString *)titleForSection:(NSInteger)section {
    NSString *sectionTitle = FLCleanString(_entries[section][kSectionTitleKey]);

    if (![[sectionTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        return nil;
    }
    return sectionTitle;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FLTableSection *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kDetailsHeaderIdentifier];

    if (header == nil) {
        header = [[FLTableSection alloc] initWithReuseIdentifier:kDetailsHeaderIdentifier];
    }
    NSString *sectionTitle = [self titleForSection:section];

    if (sectionTitle != nil) {
        header.textLabel.text = [sectionTitle uppercaseString];
        return header;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self titleForSection:section] == nil) {
        return 0;
    }
    return kTableSectionHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(FLTableSection *)view forSection:(NSInteger)section {
	view.textLabel.font = [UIFont boldSystemFontOfSize:14];
	view.textLabel.textColor = [UIColor whiteColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isIndexPathForCommentCell:indexPath]) {
        FLCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoryBoardCommentCellIdentifier];
        [self prepareCommentCell:cell atIndexPath:indexPath];
        
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return size.height + 1.0f;
    }
    
    static FLDetailsTableViewCell *inlineCell = nil;
    static FLDetailsTableViewCell *blockCell = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        inlineCell  = [self.detailsTableView dequeueReusableCellWithIdentifier:kDetailsAdCellInlineIdentifier];
        blockCell   = [self.detailsTableView dequeueReusableCellWithIdentifier:kDetailsAdCellInblockIdentifier];
    });
    
    FLDetailsTableViewCell *cell = [self properReusableIdForIndexPath:indexPath] == kDetailsAdCellInlineIdentifier ? inlineCell : blockCell;
    
    [self prepareDetailCell:cell atIndexPath:indexPath];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(FLCommentCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_animateInsertedCell && indexPath.section == _detailsTableView.numberOfSections - 1 && indexPath.row == 0) {
        [cell blink];
        _animateInsertedCell = NO;
   }
}

#pragma mark - FLListingPhotosDelegate

- (void)listingPhotoWasTappedWithIndex:(NSInteger)photoIndex {
    NSMutableArray *galleryPhotos = [NSMutableArray array];

    for (NSInteger i = 0; i < self.detailsTableView.headerView.photosCollection.photosList.count; i++) {
        NSDictionary *photoInfo = self.detailsTableView.headerView.photosCollection.photosList[i];
        NSURL *photoUrl = [NSURL URLWithString:photoInfo[kPhotoUrlKey]];

        FSBasicImage *photo;
        photo = [[FSBasicImage alloc] initWithImageURL:photoUrl name:FLCleanString(photoInfo[kPhotoNameKey])];
        [galleryPhotos addObject:photo];
    }

    FSBasicImageSource *source = [[FSBasicImageSource alloc] initWithImages:galleryPhotos];

    FSImageViewerViewController *controller;
    controller = [[FSImageViewerViewController alloc] initWithImageSource:source imageIndex:photoIndex];
    controller.backgroundColorVisible = [UIColor blackColor];

    FLImageTitleView *titleView = [[FLImageTitleView alloc] initWithFrame:CGRectMake(0,
                                                                                     self.view.frame.size.height,
                                                                                     self.view.frame.size.width,
                                                                                     1)];
    titleView.backgroundColor = [UIColor clearColor];
    [controller setTitleView:titleView];

    [self.navigationController pushViewController:controller animated:YES];
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

#pragma mark - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueDetailsToComments]) {
        FLCommentsView *commentsView = segue.destinationViewController;
        NSInteger commensPerPage = [FLConfigWithKey(kConfigCommentsPerPage) integerValue];
        
        commentsView.addID    = _shortInfo.lId;
        commentsView.comments = _commentModels.count > commensPerPage ? [_commentModels subarrayWithRange:NSMakeRange(0, commensPerPage - 1)] : _commentModels;
        commentsView.commentsTotal = _allCommentsCount;
    }
}

- (IBAction)commentsButtonTapped:(UIButton *)sender {
    [self scrollToCommentsSection];
}

- (void)scrollToCommentsSection {
    
    CGFloat topOffset = [_detailsTableView rectForHeaderInSection:_detailsTableView.numberOfSections - 1].origin.y;
    
    if (topOffset + self.detailsTableView.height > self.detailsTableView.contentSize.height) {
        topOffset = self.detailsTableView.contentSize.height - self.detailsTableView.height;
    }
    
    if (topOffset > 0) {
        CGPoint bottomOffset = CGPointMake(0, topOffset);
        [self.detailsTableView setContentOffset:bottomOffset animated:YES];
    }
}

- (void)sheetActionsShareAdDidTap:(id)sender {
    [self shareAdsButtonTapped:sender];
}

- (IBAction)shareAdsButtonTapped:(id)sender {
	NSMutableArray *itemsToShare = [NSMutableArray array];

	[itemsToShare addObject:_shortInfo.title];

    if (![_seoListingUrl isEmpty] && URLIFY(_seoListingUrl).scheme.length) {
        [itemsToShare addObject:URLIFY(_seoListingUrl)];
    }

    UIActivityViewController *controller;
    controller = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
	NSArray *excludedActivities = @[UIActivityTypePrint,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAddToReadingList];
	controller.excludedActivityTypes = excludedActivities;

    // iOS 8+
	if ([controller respondsToSelector:@selector(popoverPresentationController)]) {
		if (!controller.popoverPresentationController.barButtonItem) {
            if ([sender isKindOfClass:UIButton.class]) {
                sender = [[UIBarButtonItem alloc] initWithCustomView:sender];
            }
			controller.popoverPresentationController.barButtonItem = sender;
		}
	}
	[self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)addCommentButtonTaped:(UIButton *)sender {
    FLAddCommentViewController *addCommentViewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAddCommentView];
    addCommentViewController.adId = _shortInfo.lId;
    FLNavigationController *navigator = [[FLNavigationController alloc] initWithRootViewController:addCommentViewController];
    [self.navigationController presentViewController:navigator animated:YES completion:nil];
}

- (void)newCommentDidSend:(NSNotification *)notification {
    
    self.showComments = YES;
    
    if (_commentModels.count >= _commentsOnPage)
        self.showMoreComments = YES;
    
    [_commentModels insertObject:notification.object atIndex:0];
    
    [self resignCommentsSection];

    _animateInsertedCell = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.detailsTableView reloadSections:[NSIndexSet indexSetWithIndex:_detailsTableView.numberOfSections - 1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self scrollToCommentsSection];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationNewCommentAdded
                                                  object:nil];
}

@end
