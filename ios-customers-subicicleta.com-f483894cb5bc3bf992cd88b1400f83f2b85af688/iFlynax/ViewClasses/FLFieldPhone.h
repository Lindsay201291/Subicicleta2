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

@property (nonatomic, copy) NSString *valueCode;//Maikoll (nonatomic, assign)
@property (nonatomic, copy) NSString *valueArea;//Maikoll (nonatomic, assign)
@property (nonatomic, copy) NSString *valueNumber;//Maikoll (nonatomic, assign)
@property (nonatomic, copy) NSString *valueExt;//Maikoll (nonatomic, assign)

@property (nonatomic, copy)   NSString  *phoneString;

+ (instancetype)fromModel:(FLFieldModel *)model;
@end
