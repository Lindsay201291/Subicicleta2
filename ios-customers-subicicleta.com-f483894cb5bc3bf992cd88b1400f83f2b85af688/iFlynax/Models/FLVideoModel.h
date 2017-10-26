//
//  FLVideoModel.h
//  iFlynax
//
//  Created by Alex on 7/22/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FLVideoType) {
    FLVideoTypeLocal   = 1,
    FLVideoTypeYouTube = 2
};

@interface FLVideoModel : NSObject
@property (readonly) NSInteger   vId;
@property (readonly) FLVideoType type;

@property (readonly) NSString *preview;
@property (readonly) NSString *urlString;

/**
 *	Convert video from dictionary to model
 *	@param category - dictionary of video
 *	@return model of video
 */
+ (instancetype)fromDictionary:(NSDictionary *)video;
@end
