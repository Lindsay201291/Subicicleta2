//
//  FLCollectionLoadingView.m
//  iFlynax
//
//  Created by Alex on 10/20/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLCollectionLoadingView.h"

@interface FLCollectionLoadingView ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpiner;
@property (weak, nonatomic) IBOutlet UIButton *loadMoreButton;
@end

@implementation FLCollectionLoadingView

- (void)prepareForReuse {
	[super prepareForReuse];

	if ([FLConfigWithKey(@"preload_method") isEqualToString:@"scroll"]) {
		[_loadMoreButton removeFromSuperview];
	}
	else {
		[_loadingSpiner removeFromSuperview];
	}
}

@end
