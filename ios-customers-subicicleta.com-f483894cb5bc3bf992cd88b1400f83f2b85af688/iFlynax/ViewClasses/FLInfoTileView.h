//
//  FLInfoTileView.h
//  Profile
//
//  Created by Evgeniy Novikov on 11/20/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLInfoTileView : UIView
@property (strong, nonatomic) IBOutlet UIView  *view;
@property (weak, nonatomic)   IBOutlet UILabel *titleLabel;
@property (weak, nonatomic)   IBOutlet UILabel *infoLabel;

/**
 *	Description
 *	@param title title description
 *	@param info  info description
 *	@return return value description
 */
- (instancetype)initWithTitle:(NSString *)title andInfo:(NSString *)info;

@end
