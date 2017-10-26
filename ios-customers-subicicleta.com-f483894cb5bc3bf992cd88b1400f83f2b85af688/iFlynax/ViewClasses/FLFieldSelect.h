//
//  FLFieldSelect.h
//  iFlynax
//
//  Created by Alex on 3/3/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLTableViewItem.h"

static NSString * const kFieldCategoryIDKey  = @"Category_ID";
static NSString * const kFieldListingTypeKey = @"ltype_key";

@interface FLFieldSelect : FLTableViewItem
@property (strong, nonatomic) NSArray *options;
@property (assign, nonatomic) BOOL valueChanged;
@property (assign, nonatomic) BOOL twoFields;
@property (strong, nonatomic) id valueFrom;
@property (strong, nonatomic) id valueTo;
@property (strong, nonatomic) id value;
@property (nonatomic, getter=isLoadingOptions) BOOL loadingOptions;

+ (instancetype)fromModel:(FLFieldModel *)model tableView:(UITableView *)tableView userData:(NSDictionary *)data;
+ (instancetype)fromModel:(FLFieldModel *)model tableView:(UITableView *)tableView;
+ (instancetype)withTitle:(NSString *)title options:(NSArray *)options;

- (BOOL)isChildOfParent:(FLFieldSelect *)field;
- (void)loadNextMultiFieldLevelIfNecessary;
@end
