//
//  FLConversationCell.m
//  iFlynax
//
//  Created by Alex on 6/20/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLListingCellBackgroundView.h"
#import "FLConversationCell.h"
#import "FLPhotosCount.h"
#import "FLGraphics.h"

@interface FLConversationCell ()
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateOfMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet FLPhotosCount *messagesCountView;
@end

@implementation FLConversationCell

- (void)awakeFromNib {
    [super awakeFromNib];

    _photoImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _photoImageView.layer.borderWidth = 2.0f;
    _photoImageView.clipsToBounds     = YES;
    _photoImageView.backgroundColor   = FLHexColor(@"eeeeee");

    _dateOfMessageLabel.textColor     = [UIColor darkGrayColor];
    _messageLabel.textColor           = [UIColor darkGrayColor];

    self.backgroundColor = [UIColor clearColor];
    self.backgroundView  = [[FLListingCellBackgroundView alloc] init];
    self.backgroundView.backgroundColor = FLHexColor(kColorBackgroundColor);
}

- (void)setAuthorName:(NSString *)authorName {
    _authorName = authorName;
    _authorNameLabel.text = FLCleanString(authorName);
}

- (void)setDateOfMessage:(NSString *)dateOfMessage {
    _dateOfMessage = dateOfMessage;
    _dateOfMessageLabel.text = FLCleanString(dateOfMessage);
}

- (void)setMessage:(NSString *)message {
    _message = message;
    _messageLabel.text = FLCleanString(message);
}

- (void)setPhotoUrl:(NSString *)photoUrl {
    _photoUrl = photoUrl;

    NSURL *thumbnailUrl = [NSURL URLWithString:photoUrl];

    if (thumbnailUrl.scheme.length) {
        [_photoImageView setContentMode:UIViewContentModeCenter];

        NSMutableURLRequest *thumbnailRequest = [NSMutableURLRequest requestWithURL:thumbnailUrl];
        [thumbnailRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];

        [_photoImageView setImageWithURLRequest:thumbnailRequest
                               placeholderImage:[UIImage imageNamed:@"loading30x30"]
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            if (image) {
                                                _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
                                                _photoImageView.image = image;
                                            }
                                        } failure:nil];
    }
    else {
        _photoImageView.image = [UIImage imageNamed:@"blank_avatar"];
    }
}

- (void)setNewMessagesCount:(NSInteger)newMessagesCount {
    _newMessagesCount = newMessagesCount;
    _messagesCountView.count  = newMessagesCount;
    _messagesCountView.hideWhenZero = YES;
}

- (UIImage *)thumbnail {
    return _photoImageView.image;
}

@end
