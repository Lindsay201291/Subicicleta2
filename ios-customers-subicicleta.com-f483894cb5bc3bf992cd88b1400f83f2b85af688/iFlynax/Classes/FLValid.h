//
//  FLValid.h
//  iFlynax
//
//  Created by Alex on 9/8/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLValid : NSObject

/**
 *	Description
 */
+ (instancetype)sharedInstance;

/**
 *	Description
 *	@param input input description
 *	@return return value description
 */
+ (NSString *)cleanString:(id)input;
@end
