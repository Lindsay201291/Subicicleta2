//
//  FLAccountTypeListViewController.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 5/20/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLExtendedTableViewController.h"

@interface FLAccountTypeListViewController : FLExtendedTableViewController

@property (nonatomic, strong) FLAccountTypeModel *typeModel;
@property (nonatomic, strong) NSDictionary *filterFormData;
@property (nonatomic, strong) NSString *filterChar;

@end
