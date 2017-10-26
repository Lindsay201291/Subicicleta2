//
//  FLStaticMap.h
//  iFlynax
//
//  Created by Alex on 4/30/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLStaticMap : UIView
@property (copy, nonatomic) void (^onTap)(void);

/**
 *	Description
 */
- (void)updateUserLocationOnMap;
@end
