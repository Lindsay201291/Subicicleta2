//
//  flynaxAPIClient.h
//  iFlynax
//
//  Created by Alex on 4/8/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "AFNetworking.h"

static NSString * const kApiItemUrl    = @"api.json";
static NSString * const kApiErrorKey   = @"api_error";
static NSString * const kAppVersionKey = @"app_version";

typedef void (^FLApiCompletionHandler)(id results, NSError *error);
typedef void (^FLMultipartFormDataBlock)(id<AFMultipartFormData> formData);
typedef void (^FLMultipartFormDataBlock)(id<AFMultipartFormData> formData);

@interface flynaxAPIClient : AFHTTPSessionManager
@property (strong, nonatomic) NSString *apiDestination;

+ (instancetype)sharedInstance;
+ (void)cancelAllTasks;

+ (NSURLSessionDataTask *)postApiItem:(NSString *)item
                           parameters:(NSDictionary *)parameters
                           completion:(FLApiCompletionHandler)completion;


+ (NSURLSessionUploadTask *)uploadWithBlock:(FLMultipartFormDataBlock)formDataBlock
                                  toApiItem:(NSString *)item
                                 parameters:(NSDictionary *)parameters
                                   progress:(void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                 completion:(FLApiCompletionHandler)completionBlock;

+ (NSString *)httpBuildUrlForItem:(NSString *)item;
+ (NSString *)httpBuildUrlForItem:(NSString *)item withParameters:(NSDictionary *)parameters;

- (NSDictionary *)requestParametersForItem:(NSString *)item withParameters:(NSDictionary *)parameters;


#pragma mark - Deprecated

/**
 * @deprecated This method has been deprecated. Use -postApiItem:parameters:completion: instead.
 */
+ (NSURLSessionDataTask *)getApiItem:(NSString *)item
                          parameters:(NSDictionary *)parameters
                          completion:(FLApiCompletionHandler)completion;

/**
 * @deprecated This method has been deprecated. Use -uploadWithBlock:toApiItem:parameters:progress:completion instead.
 */
+ (NSURLSessionUploadTask *)uploadWithBlock:(FLMultipartFormDataBlock)dataBlock
                                  toApiItem:(NSString *)item
                                 parameters:(NSDictionary *)parameters
                                 completion:(FLApiCompletionHandler)completionBlock;
@end
