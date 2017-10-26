//
//  FLTableViewItem.h
//  iFlynax
//
//  Created by Alex on 10/9/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "RETableViewItem.h"
#import "FLFieldModel.h"

static NSString * const kItemKey   = @"key";
static NSString * const kItemValue = @"value";
static NSString * const kItemFrom  = @"from";
static NSString * const kItemTo    = @"to";

@interface FLTableViewItem : RETableViewItem
@property (strong, nonatomic) FLFieldModel *model;
@property (copy, nonatomic)   NSString     *placeholder;
@property (copy, nonatomic)   NSString     *errorMessage;

@property (copy, nonatomic)   NSString     *placeholderFrom;
@property (copy, nonatomic)   NSString     *placeholderTo;

- (NSDictionary *)itemData;
- (BOOL)isValid;
- (void)resetValues;
@end
