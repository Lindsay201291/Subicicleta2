//
//  FLUserDefaults.h
//  iFlynax
//
//  Created by Alex on 6/17/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FLPreloadType) {
    FLPreloadTypeScroll = 0,
    FLPreloadTypeButton = 1
};

@interface FLUserDefaults : NSObject

+ (instancetype)sharedInstance;

+ (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;
+ (NSInteger)integerForKey:(NSString *)forKey;

+ (BOOL)isPreloadType:(FLPreloadType)type;
+ (void)pointToDomain:(NSString *)domain;
+ (NSString *)pointedDomain;
+ (BOOL)appPointedToDomain;
@end
