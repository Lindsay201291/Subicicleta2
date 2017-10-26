//
//  FLYTVideoIdValider.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/9/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLRegexValider.h"

@interface FLYTVideoIdValider : FLRegexValider

@property (copy, nonatomic) NSString *extractedVideoId;

@end
