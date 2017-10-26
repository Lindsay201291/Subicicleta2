//
//  FLProfileTableViewCell.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 12/19/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLProfileTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) NSArray *tiles;

@end
