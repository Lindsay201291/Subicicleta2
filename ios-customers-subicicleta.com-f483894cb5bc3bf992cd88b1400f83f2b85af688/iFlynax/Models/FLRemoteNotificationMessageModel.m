//
//  FLRemoteNotificationMessageModel.m
//  iFlynax
//
//  Created by Alex on 4/12/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import "FLRemoteNotificationMessageModel.h"

@implementation FLRemoteNotificationMessageModel

- (instancetype)initFromDictionary:(NSDictionary *)data {
    self = [super initFromDictionary:data];
    if (self) {
        _from    = @(FLTrueInteger(self.info[@"from"]));
        _admin   = @(FLTrueInteger(self.info[@"admin"]));
        _sender  = FLCleanString(self.info[@"sender"]);
        _message = FLCleanString(self.info[@"message"]);

        if (self.info[@"thumb"] != nil) {
            NSURL *imageUrl = [NSURL URLWithString:self.info[@"thumb"]];
            if (imageUrl.scheme) {
                NSMutableURLRequest *thumbnailRequest = [NSMutableURLRequest requestWithURL:imageUrl];
                [thumbnailRequest setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
                UIImageView *blank = [[UIImageView alloc] init];

                [blank setImageWithURLRequest:thumbnailRequest
                             placeholderImage:[UIImage imageNamed:@"blank_avatar"]
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                          if (image) {
                                              _thumbnail = image;
                                          }
                                      } failure:nil];
            }
        }
        else {
            _thumbnail = [UIImage imageNamed:@"blank_avatar"];
        }
    }
    return self;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithString:[super description]];

    [string appendFormat:@"from: %@\n", _from];
    [string appendFormat:@"admin: %@\n", _admin];
    [string appendFormat:@"sender: %@\n", _sender];
    [string appendFormat:@"message: %@\n", _message];

    return string;
}

@end
