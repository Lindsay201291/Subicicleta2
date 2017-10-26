//
//  FLDebug.h
//  iFlynax
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

@interface FLDebug : NSObject

/**
 *	Description
 */
+ (instancetype)sharedInstance;

/**
 *	Description
 *	@param error - error description
 *	@param item  - item description
 */
+ (void)showAdaptedError:(NSError *)error apiItem:(NSString *)item;
@end