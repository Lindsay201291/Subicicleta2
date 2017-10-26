//
//  FLEditProfileHeader.h
//  iFlynax
//
//  Created by Alex on 9/16/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

@interface FLEditProfileHeader : UIView
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (copy, nonatomic) void (^onTapEditMail)(UIButton *button);
@end
