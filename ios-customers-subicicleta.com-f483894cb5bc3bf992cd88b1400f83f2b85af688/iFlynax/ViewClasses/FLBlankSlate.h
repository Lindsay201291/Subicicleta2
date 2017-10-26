//
//  FLEmptyDataSet.h
//  iFlynax
//
//  Created by Alex on 7/10/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLBlankSlate : NSObject

@property (nonatomic, copy  ) NSString *title;
@property (nonatomic, copy  ) NSString *message;
@property (nonatomic, assign) BOOL     displayImage;

+ (instancetype)sharedInstance;

+ (void)attachTo:(UIScrollView *)scrollView withTitle:(NSString *)title;
+ (void)attachTo:(UIScrollView *)scrollView withTitle:(NSString *)title message:(NSString *)message;
@end
