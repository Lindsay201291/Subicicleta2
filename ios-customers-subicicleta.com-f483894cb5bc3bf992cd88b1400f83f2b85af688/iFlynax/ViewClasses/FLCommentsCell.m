//
//  FLCommentsCell.m
//  iFlynax
//
//  Created by Alex on 10/09/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLCommentsCell.h"

@interface FLCommentsCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@end

@implementation FLCommentsCell

- (void)setAuthor:(NSString *)author {
    _author = author;
    _subTitleLabel.text = F(@"%@ %@", author, _postDate);
}

- (void)setPostDate:(NSString *)postDate {
	_postDate = postDate;
	_subTitleLabel.text = F(@"%@ %@", _author, postDate);
}

- (void)setTitle:(NSString *)title {
	_title = title;
	_titleLabel.text = title;
}

- (void)setMessage:(NSString *)message {
    _message = message;
    _messageLabel.text = message;
}

- (void)messageSizeToFit {
	[_messageLabel sizeToFit];
}

@end
