//
//  FLSellerInfoCell.h
//  iFlynax
//
//  Created by Alex on 10/27/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAttributedLabel.h"

@interface FLSellerInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet FLAttributedLabel *valueLabel;
@property (nonatomic, assign) NSString *condition;
@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) NSString *value;
@end
