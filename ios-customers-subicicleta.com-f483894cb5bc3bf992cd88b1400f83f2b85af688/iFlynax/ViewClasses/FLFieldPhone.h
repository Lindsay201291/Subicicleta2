//
//  FLFieldPhone.h
//  iFlynax
//
//  Created by Alex on 9/17/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLTableViewItem.h"

@interface FLFieldPhone : FLTableViewItem
@property (nonatomic, assign) BOOL codeField;
@property (nonatomic, assign) BOOL extField;
@property (nonatomic, assign) NSInteger areaLength;
@property (nonatomic, assign) NSInteger numberLength;

@property (nonatomic, assign) NSString *valueCode;
@property (nonatomic, assign) NSString *valueArea;
@property (nonatomic, assign) NSString *valueNumber;
@property (nonatomic, assign) NSString *valueExt;

@property (nonatomic, copy)   NSString  *phoneString;

+ (instancetype)fromModel:(FLFieldModel *)model;
@end
