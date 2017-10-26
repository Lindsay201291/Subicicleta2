//
//  FListingVideoCell.m
//  iFlynax
//
//  Created by Alex on 7/22/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLListingVideoCell.h"
#import "YTPlayerView.h"

@interface FLListingVideoCell ()
@property (weak, nonatomic) IBOutlet YTPlayerView *youtubeView;

@end

@implementation FLListingVideoCell

- (void)loadVideo:(NSString *)videoId {
    [_youtubeView loadWithVideoId:videoId];
    _youtubeView.webView.opaque = NO;
    _youtubeView.webView.backgroundColor = [UIColor clearColor];
}

@end
