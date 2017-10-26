//
//  FLFieldModel.m
//  iFlynax
//
//  Created by Alex on 9/15/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLFieldModel.h"

@interface FLFieldModel ()
@property (copy, nonatomic) NSString *typeString;
@end

@implementation FLFieldModel

+ (instancetype)fromDictionary:(NSDictionary *)field {
    return [[FLFieldModel alloc] initFromDictionary:field searchMode:NO];
}

+ (instancetype)fromDictionary:(NSDictionary *)field searchMode:(BOOL)isSearch {
    return [[FLFieldModel alloc] initFromDictionary:field searchMode:isSearch];
}

- (instancetype)initFromDictionary:(NSDictionary *)field searchMode:(BOOL)isSearch {
    self = [super init];
    if (self) {
        _key          = [field objectForKey:@"key"];
        _name         = [field objectForKey:@"name"];
        _required     = FLTrueBool(field[@"required"]);
        _multilingual = FLTrueBool(field[@"multilingual"]);
        _typeString   = [field objectForKey:@"type"];
        _type         = [self stringTypeToInt:_typeString];
        _current      = [field objectForKey:@"current"];
        _data         = [field objectForKey:@"data"];
        _values       = [field objectForKey:@"values"];
        _searchMode   = isSearch;

        if (field[@"default"] != nil) {
            _defaultValue = field[@"default"];
        }

        if (_type != FLFieldTypeAccept && [_data isKindOfClass:NSString.class]) {
            if ([_data isEqualToString:@"isDomain"]) {
                _isDomain = YES;
            }
            else if ([_data isEqualToString:@"isEmail"]) {
                _isEmail = YES;
            }
            else if ([_data isEqualToString:@"isUrl"]) {
                _isUrl = YES;
            }
            else if ([_data isEqualToString:@"multiField"]) {
                _multiField = YES;
            }
        }
    }
    return self;
}

- (FLFieldType)stringTypeToInt:(NSString *)type {
    if      ([type isEqualToString:@"text"])     return FLFieldTypeText;
    else if ([type isEqualToString:@"textarea"]) return FLFieldTypeTextarea;
    else if ([type isEqualToString:@"number"])   return FLFieldTypeNumber;
    else if ([type isEqualToString:@"phone"])    return FLFieldTypePhone;
    else if ([type isEqualToString:@"date"])     return FLFieldTypeDate;
    else if ([type isEqualToString:@"mixed"])    return FLFieldTypeMixed;
    else if ([type isEqualToString:@"price"])    return FLFieldTypePrice;
    else if ([type isEqualToString:@"bool"])     return FLFieldTypeBool;
    else if ([type isEqualToString:@"select"])   return FLFieldTypeSelect;
    else if ([type isEqualToString:@"radio"])    return FLFieldTypeRadio;
    else if ([type isEqualToString:@"checkbox"]) return FLFieldTypeCheckbox;
    else if ([type isEqualToString:@"image"])    return FLFieldTypeImage;
    else if ([type isEqualToString:@"file"])     return FLFieldTypeFile;
    else if ([type isEqualToString:@"accept"])   return FLFieldTypeAccept;
    return FLFieldTypeUnSupported;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:@"\n\n"];
    
    [string appendFormat:@"key: %@\n", self.key];
    [string appendFormat:@"type: %@\n", self.typeString];
    [string appendFormat:@"name: %@\n", self.name];
    [string appendFormat:@"required: %@\n", self.required ? @"YES" : @"NO"];

    return string;
}

@end
