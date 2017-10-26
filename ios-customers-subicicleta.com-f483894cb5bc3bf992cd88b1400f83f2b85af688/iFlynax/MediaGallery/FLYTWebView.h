//
//  FLYTWebView.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/12/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "YTPlayerView.h"

@interface FLYTWebView : UIWebView

@property (copy, nonatomic) NSString *videoId;
@property (copy, readonly, nonatomic) NSString *link;
@property (copy, readonly, nonatomic) NSString *content;
@property (copy, readonly, nonatomic) NSURL *url;

- (instancetype)initWithFrame:(CGRect)frame andVideoId:(NSString *)videoId;

@end
