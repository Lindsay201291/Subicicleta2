//
//  FLConfig.h
//  iFlynax
//
//  Created by Alex on 5/12/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLConfig : NSObject

+ (instancetype)sharedInstance;

+ (BOOL)boolWithKey:(NSString *)key;
+ (NSInteger)integerWithKey:(NSString *)key;
+ (NSString *)stringWithKey:(NSString *)key;

+ (id)withKey:(NSString *)key;

+ (NSInteger)displayListingsNumberPerPage;
@end
