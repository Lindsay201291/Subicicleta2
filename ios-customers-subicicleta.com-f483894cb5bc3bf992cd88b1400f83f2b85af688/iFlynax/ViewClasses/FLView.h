//
//  FLView.h
//  iFlynax
//
//  Created by Alex on 9/16/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLView : UIView
@property (assign, nonatomic) BOOL centerLine;

@property (copy, nonatomic) NSString *centerLineColorHex;
@property (copy, nonatomic) NSString *bottomLineColorHex;
@end
