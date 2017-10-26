//
//  FLSubCategoriesVC.m
//  iFlynax
//
//  Created by Alex on 2/9/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import "FLSubCategoriesVC.h"

@implementation FLSubCategoriesVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.backgroundColor = FLHexColor(kColorBackgroundColor);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 64)];
        view;
    });
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    static NSString * kCategoriesCellIdentifier = @"subCategoriesCellIdentifier";

    cell = [tableView dequeueReusableCellWithIdentifier:kCategoriesCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCategoriesCellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    [_parentVC fillUpSubCategoryCell:cell atIndexPath:indexPath withData:_entries[indexPath.row]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _entries.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (_entries[indexPath.row].count) {
        [_parentVC goToSubCategoryWithData:_entries[indexPath.row]];
    }
}

@end
