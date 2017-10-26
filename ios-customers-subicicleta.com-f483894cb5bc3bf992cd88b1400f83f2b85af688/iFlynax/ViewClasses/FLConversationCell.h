//
//  FLConversationCell.h
//  iFlynax
//
//  Created by Alex on 6/20/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLConversationCell : UITableViewCell
@property (strong, nonatomic) NSString *authorName;
@property (strong, nonatomic) NSString *dateOfMessage;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *photoUrl;
@property (assign, nonatomic) NSInteger newMessagesCount;

- (UIImage *)thumbnail;
@end
