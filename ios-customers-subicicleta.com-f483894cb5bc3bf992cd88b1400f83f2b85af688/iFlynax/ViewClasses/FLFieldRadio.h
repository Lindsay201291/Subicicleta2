//
//  FLFieldRadio.h
//  iFlynax
//
//  Created by Alex on 9/1/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLTableViewItem.h"

@interface FLFieldRadio : FLTableViewItem
@property (copy, nonatomic) NSArray *options;
@property (copy, nonatomic) NSString *caption;
@property (strong, nonatomic) id value;
@property (copy, nonatomic) dispatch_block_t valueWasChanged;
@property (nonatomic, getter=isCheckBoxMode, readonly) BOOL checkBoxMode;

+ (instancetype)fromModel:(FLFieldModel *)model tableView:(UITableView *)tableView;
@end
