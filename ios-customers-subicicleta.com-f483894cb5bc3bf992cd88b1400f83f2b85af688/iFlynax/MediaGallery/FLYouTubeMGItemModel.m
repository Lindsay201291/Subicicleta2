//
//  FLYouTubeMGItemModel.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 10/19/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLYouTubeMGItemModel.h"

static NSString * const kFLYouTubeOembedUrl = @"https://www.youtube.com/oembed?format=json&url=http://www.youtube.com/watch?v=%@";

static NSString * const kFLYTDataKeyId       = @"id";
static NSString * const kFLYTDataKeyVideoId  = @"youtube_id";
static NSString * const kFLYTDataKeyTitle    = @"title";
static NSString * const kFLYTDataKeyThumbUrl = @"thumbnail_url";

@implementation FLYouTubeMGItemModel

+ (instancetype)fromDictionary:(NSDictionary *)data {
    return [[self alloc] initFromDictionary:data];
}

+ (void)loadWithYouTubeId:(NSString *)youTubeId success:(FLYouTubeLoadIdSucces)successBlock
                  failure:(FLYouTubeLoadIdFailure)failureBlock
{
    NSParameterAssert(successBlock);

    flynaxAPIClient *apiClient = [[flynaxAPIClient sharedInstance] copy];
    apiClient.requestSerializer = [AFHTTPRequestSerializer serializer];

    NSString *requestUrl = F(kFLYouTubeOembedUrl, youTubeId);

    [apiClient POST:requestUrl
         parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
             NSMutableDictionary *modelData = [NSMutableDictionary dictionary];
             [modelData setObject:youTubeId forKey:kFLYTDataKeyVideoId];
             [modelData addEntriesFromDictionary:response];

             FLYouTubeMGItemModel *model = [FLYouTubeMGItemModel fromDictionary:modelData];
             model.status = FLYouTubeVideoAvailable;

             successBlock(model);
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             if (failureBlock != nil) {
                 FLYouTubeMGItemModel *model = [FLYouTubeMGItemModel new];
                 model.status = FLYouTubeVideoNotAvailable;

                 switch (((NSHTTPURLResponse *)task.response).statusCode) {
                     case 404:
                         model.status = FLYouTubeVideoNotFound;
                         break;

                     case 401:
                         model.status = FLYouTubeVideoNotEmbedded;
                         break;
                 }
                 failureBlock(model, [self availablilityDescription:model.status]);
             }
         }];
}

- (instancetype)initFromDictionary:(NSDictionary *)data {
    self = [self init];
    if (self) {
        _videoId      = [data[kFLYTDataKeyId] integerValue];
        _youTubeId    = data[kFLYTDataKeyVideoId];
        _title        = data[kFLYTDataKeyTitle];
        _thumbnailUrl = data[kFLYTDataKeyThumbUrl];
    }
    return self;
}

+ (NSString *)availablilityDescription:(FLYouTubeVideoAvailability)status {
    NSString *description;
    switch (status) {
        case FLYouTubeVideoAvailable:
            description = FLLocalizedString(@"yt_video_is_available");
            break;
        case FLYouTubeVideoNotAvailable:
            description = FLLocalizedString(@"yt_video_is_not_avilable");
            break;
        case FLYouTubeVideoNotFound:
            description = FLLocalizedString(@"yt_video_is_not_found");
            break;
        case FLYouTubeVideoNotEmbedded:
            description = FLLocalizedString(@"yt_video_is_not_embedded");
            break;
    }
    return description;
}

@end
