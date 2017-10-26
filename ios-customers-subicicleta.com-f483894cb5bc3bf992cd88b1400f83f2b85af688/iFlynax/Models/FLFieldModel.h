//
//  FLFieldModel.h
//  iFlynax
//
//  Created by Alex on 9/15/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FLFieldType) {
    FLFieldTypeText,
    FLFieldTypeTextarea,
    FLFieldTypeNumber,
    FLFieldTypePhone,
    FLFieldTypeDate,
    FLFieldTypeMixed,
    FLFieldTypePrice,
    FLFieldTypeBool,
    FLFieldTypeSelect,
    FLFieldTypeRadio,
    FLFieldTypeCheckbox,
    FLFieldTypeImage,
    FLFieldTypeFile,
    FLFieldTypeAccept,
    FLFieldTypeUnSupported
};

@interface FLFieldModel : NSObject
@property (copy, nonatomic, readonly) NSString *key;
@property (copy, nonatomic, readonly) NSString *name;

@property (assign, nonatomic, readonly) BOOL required;
@property (assign, nonatomic, readonly) BOOL multilingual;
@property (assign, nonatomic, readonly) BOOL multiField;
@property (assign, nonatomic)           BOOL searchMode;

@property (assign, nonatomic, readonly) FLFieldType type;

@property (strong, nonatomic, readonly) id current;
@property (strong, nonatomic, readonly) id data;
@property (strong, nonatomic, readonly) id values;
@property (strong, nonatomic, readonly) id defaultValue;

@property (assign, nonatomic, readonly) BOOL isDomain;
@property (assign, nonatomic, readonly) BOOL isEmail;
@property (assign, nonatomic, readonly) BOOL isUrl;

+ (instancetype)fromDictionary:(NSDictionary *)field;
+ (instancetype)fromDictionary:(NSDictionary *)field searchMode:(BOOL)isSearch;

- (FLFieldType)stringTypeToInt:(NSString *)type;
@end
