//
//  FLCommentsView.h
//  iFlynax
//
//  Created by Alex on 9/1/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLExtendedTableViewController.h"

@interface FLCommentsView : FLExtendedTableViewController

@property (nonatomic) NSInteger addID;
@property (nonatomic, copy) NSArray *comments;
@property (nonatomic) int commentsTotal;

@end
