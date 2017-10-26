//
//  FLYTPreviewer.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/9/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLYTPreviewer.h"
#import "FLGraphics.h"

@implementation FLYTPreviewerCoverView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self uiPrepare];
    }
    return self;
}

- (void)uiPrepare {
    self.layer.borderWidth   = 1;
    self.layer.borderColor   = FLHexColor(@"919191").CGColor;
    self.layer.shadowColor   = [UIColor whiteColor].CGColor;
    self.layer.shadowOffset  = CGSizeMake(0, 1);
    self.layer.shadowOpacity = .5f;
    self.layer.shadowRadius  = .0f;
    self.layer.masksToBounds = YES;
}

- (void)drawRect:(CGRect)rect {
    FLContextPainter *painter = [[FLContextPainter alloc] initWithCurrentContext];
    [painter linearGraientWithRect:self.bounds fromColor:FLHexColor(@"DEDEDE")
                           toColor:[UIColor whiteColor]];
}

@end

@interface FLYTPreviewer ()

@end

@implementation FLYTPreviewer {
    NSString *_previewVideoId;
}

- (NSString *)previewVideoId {
    return _previewVideoId;
}

- (void)previewFromVideoId:(NSString *)videoId {    
    if (videoId && !_previewVideoId) {
        [self loadWithVideoId:videoId];
    }
    else if (videoId && ![videoId isEqualToString:_previewVideoId]) {
        [self cueVideoById:videoId startSeconds:0 suggestedQuality:kYTPlaybackQualityAuto];
    }
    _previewVideoId = videoId;
}


@end

