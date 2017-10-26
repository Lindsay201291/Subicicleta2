//
//  FLSellerInfoCellImage.m
//  iFlynax
//
//  Created by Alex on 3/22/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import "FLSellerInfoCellImage.h"

@implementation FLSellerInfoCellImage

- (void)awakeFromNib {
    [super awakeFromNib];

    _fieldTitle.textColor = FLHexColor(@"646464");

    _fieldImageView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
}

- (void)setImageStringUrl:(NSString *)imageStringUrl {
    _imageStringUrl = imageStringUrl;

    NSURL *imageUrl = URLIFY(imageStringUrl);

    if (imageUrl) {
        NSMutableURLRequest *thumbnailRequest = [NSMutableURLRequest requestWithURL:imageUrl];
        [thumbnailRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];

        [_fieldImageView setImageWithURLRequest:thumbnailRequest
                               placeholderImage:nil
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            if (image) {
                                                _fieldImageView.image = [image imageScaledToFitSize:_fieldImageView.frame.size];
                                                _fieldImageView.contentMode = UIViewContentModeLeft;
                                            }
                                        } failure:nil];
        [_fieldImageView sizeToFit];
    }
}

@end
