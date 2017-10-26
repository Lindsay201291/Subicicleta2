//
//  FLYouTubeMGItemModel.h
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/19/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

typedef NS_ENUM(NSInteger, FLYouTubeVideoAvailability) {
    FLYouTubeVideoAvailable,
    FLYouTubeVideoNotFound,
    FLYouTubeVideoNotEmbedded,
    FLYouTubeVideoNotAvailable
};

@class FLYouTubeMGItemModel;

typedef void (^FLYouTubeLoadIdSucces)(FLYouTubeMGItemModel *model);
typedef void (^FLYouTubeLoadIdFailure)(FLYouTubeMGItemModel *model, NSString *errorMessage);

@interface FLYouTubeMGItemModel : NSObject
@property (readonly, nonatomic) NSInteger videoId;
@property (copy, nonatomic) NSString *youTubeId;

@property (copy, readonly, nonatomic) NSString *title;
@property (copy, readonly, nonatomic) NSString *thumbnailUrl;

@property (readonly, getter=isNew, nonatomic) BOOL newModel;
@property (readonly, getter=isAvailableOnYouTube, nonatomic) BOOL availableOnYouTube;
@property (nonatomic) FLYouTubeVideoAvailability status;

+ (instancetype)fromDictionary:(NSDictionary *)data;

+ (void)loadWithYouTubeId:(NSString *)youTubeId success:(FLYouTubeLoadIdSucces)successBlock
                  failure:(FLYouTubeLoadIdFailure)failureBlock;

@end
