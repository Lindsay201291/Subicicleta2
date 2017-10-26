//
//  FLCommentsCell.h
//  iFlynax
//
//  Created by Alex on 10/09/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLCommentsCell : UICollectionViewCell
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *postDate;

/**
 *	Description
 */
- (void)messageSizeToFit;
@end
