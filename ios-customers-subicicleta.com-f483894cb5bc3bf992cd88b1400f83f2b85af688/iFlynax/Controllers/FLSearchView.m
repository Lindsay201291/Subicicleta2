//
//  FLSearchView.m
//  iFlynax
//
//  Created by Alex on 4/24/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLSearchView.h"
#import "REFrostedViewController.h"
#import "FLTableViewManager.h"
#import "FLKeyboardHandler.h"
#import "FLSearchResultsVC.h"
#import "FLTableSection.h"

@interface FLSearchView () <FLKeyboardHandlerDelegate, RETableViewManagerDelegate> {
    RETableViewSection *_formSection;
}

@property (strong, nonatomic) FLKeyboardHandler  *keyboardHandler;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FLTableViewManager *manager;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIButton *resetBtn;
@end

@implementation FLSearchView

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor      = FLHexColor(kColorBackgroundColor);
    self.tableView.backgroundColor = self.view.backgroundColor;

    _manager = [FLTableViewManager withTableView:self.tableView];
    _manager.delegate = self;

    _keyboardHandler = [[FLKeyboardHandler alloc] initWithScroll:self.tableView];
    _keyboardHandler.delegate = self;

    //TODO: probably best way to use events
    [FLAppSession addItem:@(YES) forKey:kSessionSearchControllerIsActive];
    [self buildForm];

    /* trick for clearView */
    self.tableView.tableHeaderView = ({
        UIView *clearView = [[UIView alloc] init];
        clearView.backgroundColor = [UIColor clearColor];
        clearView.height = 7;
        clearView;
    });
    /* trick for clearView END */

    [_searchBtn setTitle:FLLocalizedString(@"button_search") forState:UIControlStateNormal];
    [_resetBtn setTitle:FLLocalizedString(@"button_search_reset") forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
	self.screenName = F(@"Search (type: %@)", _listingType.key);
	[super viewDidAppear:animated];
}

- (void)dealloc {
    [_keyboardHandler unRegisterNotifications];
}

#pragma mark -

- (void)buildForm {
    _formSection = [RETableViewSection section];
    [self.manager addSection:_formSection];

    for (NSDictionary *fieldDict in self.fields) {
        FLFieldModel *field = [FLFieldModel fromDictionary:fieldDict searchMode:YES];
        RETableViewItem *item = nil;
        
        if (field.type == FLFieldTypeText) {
            item = [FLFieldText fromModel:field];
        }
        else if (field.type == FLFieldTypeSelect) {
            NSDictionary *ltypeKey = @{kFieldListingTypeKey: _listingType.key};
            item = [FLFieldSelect fromModel:field tableView:_tableView userData:ltypeKey];
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
        else if (field.type == FLFieldTypeCheckbox) {
            item = [FLFieldCheckbox fromModel:field parentVC:self];
        }
        else {
            // skip another field types. (like: image, file, accept)
            continue;
        }
        [_formSection addItem:item];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

#pragma mark - RETableViewManagerDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    RETableViewSection *section = self.manager.sections[indexPath.section];
    RETableViewItem *item = section.items[indexPath.row];
    
    if ([item isKindOfClass:FLFieldCheckbox.class]) {
        cell.backgroundColor = [UIColor clearColor];
        UIImage *accessoryImage = [UIImage imageNamed:@"select_icon"];
        cell.accessoryView = [[UIImageView alloc] initWithImage:accessoryImage];
    }
}

#pragma mark - Navigation

- (IBAction)submitBtnDidTap:(UIButton *)sender {
    FLSearchResultsVC *searchResultsVC = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardSearchResultsVC];
    searchResultsVC.formValues = self.manager.formValues;
    searchResultsVC.lType = _listingType;

    [self.navigationController pushViewController:searchResultsVC animated:YES];
}

- (IBAction)resetBtnDidTap:(UIButton *)sender {
    [self.manager resetForm];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (IBAction)showSideMenu:(UIBarButtonItem *)sender {
    [self.frostedViewController presentMenuViewController];
}

@end
