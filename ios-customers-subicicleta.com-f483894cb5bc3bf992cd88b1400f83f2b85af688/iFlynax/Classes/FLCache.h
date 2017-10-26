//
//  FLCache.h
//  iFlynax
//
//  Created by Alex on 5/12/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLCache : NSObject

/**
 *	Description
 */
+ (instancetype)sharedInstance;

/**
 *	Description
 */
+ (void)prepareGlobalAppCache;

/**
 *	Description
 */
+ (void)refreshAppCache;

+ (id)objectWithKey:(NSString *)key;
@end
