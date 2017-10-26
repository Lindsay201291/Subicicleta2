//
//  FLYouTubeMGItemCell.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/19/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLYouTubeMGItemCell.h"

@implementation FLYouTubeMGItemCell

@dynamic data;

- (void)customizeFromData {
    
    _titleLabel.text = self.data.title;
    
    NSURL *thumbURL = [NSURL URLWithString:self.data.thumbnailUrl];
    NSMutableURLRequest *thumbnailRequest = [NSMutableURLRequest requestWithURL:thumbURL];
    [_thumbImageView setImageWithURLRequest:thumbnailRequest
                           placeholderImage:nil
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                        if (image) {
                                            _thumbImageView.image = image;
                                            _thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
                                        }
                                    }
                                    failure:nil];
    _dataCustomized = YES;
}

@end
