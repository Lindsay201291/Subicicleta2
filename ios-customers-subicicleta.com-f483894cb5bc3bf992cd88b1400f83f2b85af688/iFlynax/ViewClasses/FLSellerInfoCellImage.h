//
//  FLSellerInfoCellImage.h
//  iFlynax
//
//  Created by Alex on 3/22/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLSellerInfoCellImage : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *fieldImageView;
@property (weak, nonatomic) IBOutlet UILabel *fieldTitle;

@property (copy, nonatomic) NSString *imageStringUrl;
@property (assign, nonatomic) CGSize imageSize;
@end
