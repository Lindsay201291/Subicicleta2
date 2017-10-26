//
//  FLLang.h
//  iFlynax
//
//  Created by Alex on 4/23/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FLLanguageDirection) {
    FLLanguageDirectionLTR,
    FLLanguageDirectionRTL
};

@interface FLLang : NSObject

@property (strong, nonatomic) NSDictionary *languages;
@property (strong, nonatomic) NSDictionary *langKeys;

+ (instancetype)sharedInstance;

+ (void)refreshWithBlock:(dispatch_block_t)block;
+ (void)refresh;

+ (NSString *)langCode;
+ (NSDictionary *)languages;
+ (FLLanguageDirection)direction;

+ (NSString *)langWithKey:(NSString *)key;
+ (NSString *)langWithKey:(NSString *)key search:(NSString *)search replace:(NSString *)replace;

- (void)showSuccessUpdatedListing:(BOOL)editMode;
@end
