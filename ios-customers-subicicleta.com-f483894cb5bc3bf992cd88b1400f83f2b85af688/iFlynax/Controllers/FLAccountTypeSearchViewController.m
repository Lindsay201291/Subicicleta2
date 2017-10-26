//
//  FLAccoutTypeSearchViewController.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 5/20/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "REFrostedViewController.h"
#import "FLAccountTypeSearchViewController.h"
#import "FLAccountTypeListViewController.h"
#import "FLTableViewManager.h"
#import "FLKeyboardHandler.h"
#import "FLTableSection.h"

@interface FLAccountTypeSearchViewController () <FLKeyboardHandlerDelegate, RETableViewManagerDelegate>
{
    RETableViewSection *_formSection;
}
@property (strong, nonatomic) FLKeyboardHandler  *keyboardHandler;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FLTableViewManager *manager;
@property (strong, nonatomic) UIButton *submitButton;
@end

@implementation FLAccountTypeSearchViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    self.title = FLLocalizedString(@"screen_accounts_advanced_search");
    self.view.backgroundColor      = FLHexColor(kColorBackgroundColor);
    self.tableView.backgroundColor = self.view.backgroundColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _manager = [FLTableViewManager withTableView:self.tableView];
    _manager.delegate = self;

    _keyboardHandler = [[FLKeyboardHandler alloc] initWithScroll:self.tableView];
    _keyboardHandler.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView setTableFooterView:[self tableFooterSubmitButton]];
        [_tableView reloadData];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    self.screenName = F(@"Account Type (%@) - Search Form", _typeModel.key);
    [super viewDidAppear:animated];
}

- (void)dealloc {
    [_keyboardHandler unRegisterNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)setTypeModel:(FLAccountTypeModel *)typeModel {
    _typeModel = typeModel;

    [self buildForm];
}

- (void)buildForm {
    _formSection = [RETableViewSection section];
    [self.manager addSection:_formSection];

    for (NSDictionary *fieldDict in self.typeModel.searchFormFields) {
        FLFieldModel *field = [FLFieldModel fromDictionary:fieldDict searchMode:YES];
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
        [_formSection addItem:item];
    }
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

- (UIButton *)submitButton {
    if (_submitButton == nil) {
        _submitButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 5, self.tableView.width-30, 50)];
        [_submitButton setTitle:FLLocalizedString(@"button_submit") forState:UIControlStateNormal];
        [_submitButton setBackgroundImage:[UIImage imageNamed:@"button1"] forState:UIControlStateNormal];
        [_submitButton addTarget:self action:@selector(submitBtnDidTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

- (UIView *)tableFooterSubmitButton {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.height = 70;
    [view addSubview:self.submitButton];
    return view;
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

- (void)submitBtnDidTap:(UIButton *)sender {
    FLAccountTypeListViewController *searchAgentsVC =
    [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAccountTypeListViewController];
    searchAgentsVC.filterFormData = self.manager.formValues;
    searchAgentsVC.typeModel      = self.typeModel;
    searchAgentsVC.title          = FLLocalizedString(@"screen_search_sellers");
    searchAgentsVC.navigationItem.leftBarButtonItem = nil;

    [self.navigationController pushViewController:searchAgentsVC animated:YES];
}

@end
