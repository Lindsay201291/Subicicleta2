//
//  flynaxAPIClient.m
//  iFlynax
//
//  Created by Alex on 18/9/14.
//  Copyright (c) 2014 Ltd. All rights reserved.
//

#import "flynaxAPIClient.h"

// key's for obtaining the data source item's
static NSString * const kDefaultKeyController = @"controller";
static NSString * const kDefaultKeyLanguage   = @"language";
static NSString * const kDefaultKeyTablet     = @"tablet";
static NSString * const kDefaultKeyToken      = @"accountToken";
static NSString * const kDefaultKeySynchCode  = @"synch_code";

static NSString * const kApiErrorKeySessionExpired = @"error_session_expired";

// helper function: get the string form of any object
static NSString *_toString(id object) {
    return [NSString stringWithFormat: @"%@", object];
}

// helper function: get the url encoded string form of any object
static NSString *_urlEncode(id object) {
    NSString *string = _toString(object);
    return [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@implementation flynaxAPIClient

+ (instancetype)sharedInstance {
	static flynaxAPIClient *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		// prepare session configuration
		NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];

		// prepare shared URLCache
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                          diskCapacity:50 * 1024 * 1024
                                                              diskPath:nil];
        [config setURLCache:cache];

		// initialize session instance
		_sharedInstance = [[flynaxAPIClient alloc] initWithSessionConfiguration:config];
        _sharedInstance.securityPolicy     = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _sharedInstance.requestSerializer  = [AFJSONRequestSerializer serializer];
        _sharedInstance.responseSerializer = [AFJSONResponseSerializer serializer];

        // set user-agent data for all requests
        [_sharedInstance.requestSerializer setValue:kFlynaxAPIUserAgent forHTTPHeaderField:@"User-Agent"];

        // HTTP Manager Reachability
        NSOperationQueue *operationQueue = _sharedInstance.operationQueue;
        [_sharedInstance.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    [operationQueue setSuspended:NO];
                    break;

                case AFNetworkReachabilityStatusNotReachable:
                default:
                    [operationQueue setSuspended:YES];
                    break;
            }
        }];
        [_sharedInstance.reachabilityManager startMonitoring];
	});
	return _sharedInstance;
}

- (NSString *)apiDestination {
    if (!_apiDestination) {
        if (kLabeledSolution) {
            NSString *domain = [FLUserDefaults pointedDomain];
            _apiDestination = F(@"%@/plugins/iFlynaxConnect/%@", domain, kApiItemUrl);
        }
        else {
            _apiDestination = F(@"%@/%@", kFlynaxAPIBaseURLString, kApiItemUrl);
        }
    }
    return _apiDestination;
}

+ (NSURLSessionDataTask *)getApiItem:(NSString *)item parameters:(NSDictionary *)parameters
						  completion:(FLApiCompletionHandler)completion
{
	return [[flynaxAPIClient sharedInstance] getApiItem:item parameters:parameters completion:completion];
}

+ (NSURLSessionDataTask *)postApiItem:(NSString *)item parameters:(NSDictionary *)parameters
						   completion:(FLApiCompletionHandler)completion
{
	return [[flynaxAPIClient sharedInstance] postApiItem:item parameters:parameters completion:completion];
}

+ (NSURLSessionUploadTask *)uploadWithBlock:(FLMultipartFormDataBlock)formDataBlock
                                  toApiItem:(NSString *)item
                                 parameters:(NSDictionary *)parameters
                                   progress:(void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                 completion:(FLApiCompletionHandler)completionBlock
{
    return [[flynaxAPIClient sharedInstance] uploadWithBlock:formDataBlock
                                                   toApiItem:item
                                                  parameters:parameters
                                                    progress:uploadProgressBlock
                                                  completion:completionBlock];
}

+ (NSURLSessionUploadTask *)uploadWithBlock:(FLMultipartFormDataBlock)dataBlock
                                  toApiItem:(NSString *)item
                                 parameters:(NSDictionary *)parameters
                                 completion:(FLApiCompletionHandler)completionBlock
{
    return [[flynaxAPIClient sharedInstance] uploadWithBlock:dataBlock
                                                   toApiItem:item
                                                  parameters:parameters
                                                    progress:nil
                                                  completion:completionBlock];
}

+ (NSString *)httpBuildUrlForItem:(NSString *)item {
    return [[flynaxAPIClient sharedInstance] httpBuildUrlForItem:item withParameters:nil];
}

+ (NSString *)httpBuildUrlForItem:(NSString *)item withParameters:(NSDictionary *)parameters {
    return [[flynaxAPIClient sharedInstance] httpBuildUrlForItem:item withParameters:parameters];
}

- (NSDictionary *)requestParametersForItem:(NSString *)item withParameters:(NSDictionary *)parameters {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSMutableDictionary *requestParameters = [NSMutableDictionary dictionary];
	[requestParameters setValue:@(IS_IPAD) forKey:kDefaultKeyTablet];
	[requestParameters setValue:kFlynaxAPISynchCode forKey:kDefaultKeySynchCode];
	[requestParameters setValue:[FLLang langCode] forKey:kDefaultKeyLanguage];
    [requestParameters setValue:appVersion forKey:kAppVersionKey];
	[requestParameters setValue:item forKey:kDefaultKeyController];

    if (parameters != nil) {
		[requestParameters addEntriesFromDictionary:parameters];
    }

    // append account token to the request if exists
	NSString *accountToken = [defaults valueForKey:kDefaultKeyAccountToken];
    if (accountToken != nil) {
        if (IS_LOGIN) {
            [requestParameters setValue:accountToken forKey:kDefaultKeyToken];
        }
        else {
            [defaults setValue:nil forKey:kDefaultKeyAccountToken];
            [defaults synchronize];
        }
    }

	return requestParameters;
}

#pragma mark - api types

- (NSURLSessionDataTask *)getApiItem:(NSString *)item parameters:(NSDictionary *)parameters
						  completion:(FLApiCompletionHandler)completion
{
    return [self postApiItem:item parameters:parameters completion:completion];
}

- (NSURLSessionDataTask *)postApiItem:(NSString *)item parameters:(NSDictionary *)parameters
						   completion:(FLApiCompletionHandler)completion
{
    NSURLSessionDataTask *task = [self POST:self.apiDestination
                                 parameters:[self requestParametersForItem:item withParameters:parameters]
                                    success:^(NSURLSessionDataTask *task, id response) {
										[self flSuccessBlockWithTask:task response:response completion:completion];
									}
									failure:^(NSURLSessionDataTask *task, NSError *error) {
										[self flFailureBlockWithTask:task error:error completion:completion];
									}];
	return task;
}

- (NSURLSessionUploadTask *)uploadWithBlock:(FLMultipartFormDataBlock)formDataBlock
                                  toApiItem:(NSString *)item
                                 parameters:(NSDictionary *)parameters
                                   progress:(void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                 completion:(FLApiCompletionHandler)completionBlock
{
    NSMutableURLRequest *request;
    request = [self.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                           URLString:self.apiDestination
                                                          parameters:[self requestParametersForItem:item withParameters:parameters]
                                           constructingBodyWithBlock:formDataBlock
                                                               error:nil];

    NSURLSessionConfiguration *session = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:session];

    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:uploadProgressBlock
                  completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                      if (completionBlock != nil) {
                          if (error == nil) {
                              completionBlock(responseObject, nil);
                          } else {
                              completionBlock(nil, error);
                          }
                      }
                  }];
    [uploadTask resume];

    return uploadTask;
}

#pragma mark - custom blocks

- (void)flSuccessBlockWithTask:(NSURLSessionDataTask *)task response:(id)response
					completion:(FLApiCompletionHandler)completion
{
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
	if (httpResponse.statusCode == 200) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([response isKindOfClass:NSDictionary.class] && response[kApiErrorKey] != nil) {
                [FLProgressHUD showErrorWithStatus:FLLocalizedString(F(@"api_%@", response[kApiErrorKey]))];

                // force logout
                if ([response[kApiErrorKey] isEqualToString:kApiErrorKeySessionExpired]) {
                    [[FLAccount loggedUser] resetSessionData];
                }
			}
            else {
                if (completion) {
                    completion(response, nil);
                }
            }
		});
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(nil, nil);
            }
		});
	}
}

- (void)flFailureBlockWithTask:(NSURLSessionDataTask *)task error:(NSError *)error
					completion:(FLApiCompletionHandler)completion
{
	dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) {
            completion(nil, error);
        }
	});
}

- (NSString *)httpBuildUrlForItem:(NSString *)item withParameters:(NSDictionary *)parameters {
    NSDictionary *args = [[flynaxAPIClient sharedInstance] requestParametersForItem:item withParameters:parameters];
    NSMutableArray *parts = [NSMutableArray array];

    for (id key in args) {
        [parts addObject:[NSString stringWithFormat:@"%@=%@", key, _urlEncode(args[key])]];
    }
    return [parts componentsJoinedByString: @"&"];
}

#pragma mark - helpers

+ (void)cancelAllTasks {
    for (id task in [flynaxAPIClient sharedInstance].tasks) {
		[task cancel];
    }

    for (id uTask in [flynaxAPIClient sharedInstance].uploadTasks) {
        [uTask cancel];
    }
}

@end
