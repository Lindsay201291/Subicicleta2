//
//  FLYTPreviewer.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/9/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "YTPlayerView.h"

@interface FLYTPreviewerCoverView : UIView

@end

@interface FLYTPreviewer : YTPlayerView

@property (copy, readonly, nonatomic) NSString *previewVideoId;

- (void)previewFromVideoId:(NSString *)videoId;

@end
