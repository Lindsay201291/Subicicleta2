//
//  FLAppSession.h
//  iFlynax
//
//  Created by Alex on 10/29/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kAppSessionAdShortInfoKey  = @"adShortInfo";
static NSString * const kAppSessionAdSellerInfoKey = @"adSellerInfo";

@interface FLAppSession : NSObject

/**
 *	Description
 */
+ (instancetype)sharedInstance;

/**
 *	Description
 */
+ (void)clearAll;

/**
 *	Description
 *	@param key key description
 */
+ (void)removeItemWithKey:(NSString *)key;

/**
 *	Description
 *	@param value value description
 *	@param key   key description
 */
+ (void)addItem:(id)value forKey:(NSString *)key;

/**
 *	Description
 *	@param key key description
 *	@return return value description
 */
+ (id)itemWithKey:(NSString *)key;
@end
