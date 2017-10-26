//
//  FLSettingsView.m
//  iFlynax
//
//  Created by Alex on 3/30/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "CCAlertView.h"
#import "FLSettingsView.h"
#import "FLTableViewManager.h"
#import "REFrostedViewController.h"
#import "FLStaticPageVC.h"
#import "FLDemoVC.h"

static NSString * const cellIdentifier = @"settingsCellIdentifier";

typedef NS_ENUM(NSInteger, FLSettingsRow) {
    FLSettingsRowChangeLanguage,
    FLSettingsRowContentPreload,
    FLSettingsRowPrivacyPolicy,
    FLSettingsRowTermsOfUse,
    FLSettingsRowLegalInformation,
    FLSettingsRowClearCache,
    FLSettingsRowConnectToAnotherWebsite
};

@interface FLSettingsView () <RETableViewManagerDelegate> {
    NSArray *_entries;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FLTableViewManager *manager;
@end

@implementation FLSettingsView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.screenName = @"Settings";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = FLHexColor(kColorBackgroundColor);
    _manager = [FLTableViewManager withTableView:_tableView];
    _manager.delegate = self;

    [self buildSettingsTableView];
}

- (void)buildSettingsTableView {
    self.title = FLLocalizedString(@"screen_settings");

    // custom datastore
    _entries = @[
                 // section 1
                 FLLocalizedString(@"settings_language"),
                 FLLocalizedString(@"settings_content_preload_type"),
                 // section 2
                 FLLocalizedString(@"settings_privacy_policy"),
                 FLLocalizedString(@"settings_terms_of_use"),
                 FLLocalizedString(@"settings_legal_information"),
                 // section 3
                 FLLocalizedString(@"settings_clear_cache"),
                 // demo section
                 FLLocalizedString(@"settings_connect_to_another_website_title"),];

    RETableViewSection *section1 = [RETableViewSection section];
    [_manager addSection:section1];

    NSString *langCode = [FLLang langCode];
    NSDictionary *selectedLanguage = [FLLang languages][langCode];
    NSTextAlignment _trueAligment = IS_RTL ? NSTextAlignmentRight : NSTextAlignmentLeft;

    /* languages row */
    if ([FLLang languages].count > 1) {
        NSMutableArray *langsMass = [@[] mutableCopy];
        [[FLLang languages] enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *language, BOOL *stop) {
            [langsMass addObject:language[@"name"]];
        }];
        REPickerItem *languageRow = [REPickerItem itemWithTitle:_entries[FLSettingsRowChangeLanguage]
                                                          value:@[selectedLanguage[@"name"]]
                                                    placeholder:nil options:@[langsMass]];
        languageRow.textAlignment = _trueAligment;
        [section1 addItem:languageRow];

        languageRow.actionBarDoneButtonTapHandler = ^void(REPickerItem *item) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *_language = item.value[0];

            [[FLLang languages] enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *language, BOOL *stop) {
                if ([language[@"name"] isEqualToString:_language]) {
                    NSString *currentLang = [defaults valueForKey:kDefaultKeyCurrentLanguage];

                    if (![currentLang isEqualToString:language[@"Code"]]) {
                        [defaults setObject:language[@"Code"] forKey:kDefaultKeyCurrentLanguage];
                        [defaults synchronize];
                        
                        *stop = YES;
                        
                        [FLLang refreshWithBlock:^{
                            self.frostedViewController.direction = IS_RTL
                            ? REFrostedViewControllerDirectionRight
                            : REFrostedViewControllerDirectionLeft;
                            [self.frostedViewController setContentViewController:self.navigationController];
                        }];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.manager removeAllSections];
                            [self buildSettingsTableView];
                            [_tableView reloadData];
                        });

                        NSTimeInterval delay = .5f;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            [self reloadSystemAppCache];
                        });
                    }
                }
            }];
        };
    }
    /* languages row END */

    /* preload content */
    RESegmentedItem *preload = [RESegmentedItem itemWithTitle:_entries[FLSettingsRowContentPreload]
                                       segmentedControlTitles:@[FLLocalizedString(@"settings_content_preload_type_scroll"),
                                                                FLLocalizedString(@"settings_content_preload_type_button")]
                                                        value:[FLUserDefaults integerForKey:kPreloadTypeConfigsKey]
                                     switchValueChangeHandler:^(RESegmentedItem *item) {
                                         [FLUserDefaults setInteger:item.value forKey:kPreloadTypeConfigsKey];
                                     }];
    preload.textAlignment = _trueAligment;
    [section1 addItem:preload];
    /* preload content END */
    
    RETableViewSection *section2 = [RETableViewSection section];
    [_manager addSection:section2];
    
    RETableViewItem *row3 = [[RETableViewItem alloc] initWithTitle:_entries[FLSettingsRowPrivacyPolicy]];
    row3.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    row3.textAlignment = _trueAligment;
    [section2 addItem:row3];
    
    RETableViewItem *row33 = [[RETableViewItem alloc] initWithTitle:_entries[FLSettingsRowTermsOfUse]];
    row33.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    row33.textAlignment = _trueAligment;
    [section2 addItem:row33];
    
    RETableViewItem *row4 = [[RETableViewItem alloc] initWithTitle:_entries[FLSettingsRowLegalInformation]];
    row4.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    row4.textAlignment = _trueAligment;
    [section2 addItem:row4];
    
    RETableViewSection *section3 = [RETableViewSection section];
    [_manager addSection:section3];
    
    RETableViewItem *row5 = [[RETableViewItem alloc] initWithTitle:_entries[FLSettingsRowClearCache]];
    row5.style = UITableViewCellStyleSubtitle;
    row5.detailLabelText = FLLocalizedString(@"settings_clear_cache_subtitle");
    row5.cellHeight = 50;
    [section3 addItem:row5];

    /* welcome page */
    if (kLabeledSolution) {
        RETableViewSection *welcomeSection = [RETableViewSection section];
        welcomeSection.footerTitle  = F(FLLocalizedString(@"pointed_to"), [FLUserDefaults pointedDomain]);
        welcomeSection.footerHeight = 50;
        [_manager addSection:welcomeSection];
        
        RETableViewItem *welcomeRow = [[RETableViewItem alloc] initWithTitle:_entries[FLSettingsRowConnectToAnotherWebsite]];
        welcomeRow.style = UITableViewCellStyleSubtitle;
        welcomeRow.detailLabelText = FLLocalizedString(@"settings_connect_to_another_website_subtitle");
        welcomeRow.cellHeight = 50;
        [welcomeSection addItem:welcomeRow];
    }
    /* welcome page END */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didLoadCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([@[@(2), @(3)] indexOfObject:@(indexPath.section)] != NSNotFound) {
        cell.textLabel.textColor = [UIColor hexColor:@"006ec2"];
    }
}

- (void)tableView:(UITableView *)tableView willLayoutCellSubviews:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_RTL) {
        if ([@[@(0)] indexOfObject:@(indexPath.section)] != NSNotFound) {
            CGRect titleFrame = cell.textLabel.frame;
            titleFrame.origin.x = 0;
            titleFrame.size.width = cell.contentView.width - 14;
            cell.textLabel.frame = titleFrame;
        }
    }

    // move value label for language cell
    if ([cell isKindOfClass:RETableViewPickerCell.class]) {
        RETableViewPickerCell *pickerCell = (RETableViewPickerCell *)cell;
        pickerCell.valueLabel.textAlignment = IS_RTL ? NSTextAlignmentLeft : NSTextAlignmentRight;
        
        CGRect valueLabelFrame = pickerCell.valueLabel.frame;
        valueLabelFrame.origin.x = 16;
        valueLabelFrame.size.width += 16;
        pickerCell.valueLabel.frame = valueLabelFrame;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0 && indexPath.row == 0) {
        RETableViewPickerCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIBarButtonItem *doneItem = [cell.actionBar.items lastObject];

        NSMutableArray *items = [cell.actionBar.items mutableCopy];
        [items removeLastObject];

        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]
                                    initWithTitle:FLLocalizedString(@"button_done")
                                    style:UIBarButtonItemStylePlain
                                    target:doneItem.target
                                    action:doneItem.action];

        [items addObject:doneBtn];
        [cell.actionBar setItems:items];
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            FLStaticPageVC *privacyPolicyVC = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardWebStaticPageVC];
            privacyPolicyVC.title = _entries[FLSettingsRowPrivacyPolicy];
            privacyPolicyVC.pageKey = FLTrueString(FLConfigWithKey(@"static_page:privacy_police"));
            [self.navigationController pushViewController:privacyPolicyVC animated:YES];
        }
        else if (indexPath.row == 1) {
            FLStaticPageVC *termsOfUseVC = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardWebStaticPageVC];
            termsOfUseVC.title = _entries[FLSettingsRowTermsOfUse];
            termsOfUseVC.pageKey = FLTrueString(FLConfigWithKey(@"static_page:terms_of_use"));
            [self.navigationController pushViewController:termsOfUseVC animated:YES];
        }
        else if (indexPath.row == 2) {
            UIViewController *legalView;
            legalView = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardLegalView];
            [self.navigationController pushViewController:legalView animated:YES];
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 0) {
        CCAlertView *alert = [[CCAlertView alloc] initWithTitle:FLLocalizedString(@"settings_clear_cache")
                                                        message:FLLocalizedString(@"settings_clear_cache_subtitle")];
        [alert addButtonWithTitle:FLLocalizedString(@"button_yes") block:^{
            [self reloadSystemAppCache];
        }];
        [alert addButtonWithTitle:FLLocalizedString(@"button_no") block:nil];
        [alert show];
    }

    /* Welcome page */
    else if (indexPath.section == 3 && indexPath.row == 0) {
        CCAlertView *alert = [[CCAlertView alloc] initWithTitle:FLLocalizedString(@"settings_connect_to_another_website_title")
                                                        message:FLLocalizedString(@"settings_connect_to_another_website_subtitle")];
        [alert addButtonWithTitle:FLLocalizedString(@"button_yes") block:^{
            FLDemoVC *demoVC = [[FLDemoVC alloc] initWithNibName:@"FLDemoVC" bundle:nil];
            self.frostedViewController.contentViewController = demoVC;
        }];
        [alert addButtonWithTitle:FLLocalizedString(@"button_no") block:nil];
        [alert show];
    }
    /* Welcome page END */
}

- (void)reloadSystemAppCache {
    [SVProgressHUD showWithStatus:FLLocalizedString(@"processing")];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [FLCache refreshAppCache];
        [FLProgressHUD showSuccessWithStatus:FLLocalizedString(@"settings_clear_cache_updated")];
        [_tableView reloadData];
    });
}

#pragma mark - Navigation

- (IBAction)showSideMenu:(UIBarButtonItem *)sender {
    [self.frostedViewController presentMenuViewController];
}

@end
