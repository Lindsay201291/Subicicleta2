//
//  FLYTWebView.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/12/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLYTWebView.h"

@implementation FLYTWebView {
    NSString *_link, *_htmlFormat, *_linkFormat;
    NSURL *_url;
}

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame andVideoId:(NSString *)videoId {
    self = [self initWithFrame:frame];
    self.videoId = videoId;
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self predefineDefaults];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self predefineDefaults];
    }
    return self;
}

- (void)predefineDefaults {
    _linkFormat = @"https://www.youtube.com/embed/%@";
    _htmlFormat = @"<body style=\"padding:0;margin:0\"><div style=\"height:100%%\"><iframe id=\"ytframe\" width=\"100%%\" height=\"100%%\" src=\"%@\" frameborder=\"0\"></iframe></div></body>";
    self.scrollView.scrollEnabled = NO;
    self.backgroundColor = FLHexColor(kColorBackgroundColor);
}

#pragma mark - Accessors

- (void)setVideoId:(NSString *)videoId {
    _videoId = videoId;
    _link = [self videoLink];
    _url = [NSURL URLWithString:_link];
    [self loadHTMLString:[self htmlString] baseURL:_url];
}

- (NSString *)content {
    return [self stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
}

- (NSString *)htmlString {
    return [NSString stringWithFormat:_htmlFormat, _link];
}

- (NSString *)link {
    return _link;
}

- (NSURL *)url {
    return _url;
}

#pragma mark - Data

- (NSString *)videoLink {
    return [NSString stringWithFormat:_linkFormat, _videoId];
}


@end
