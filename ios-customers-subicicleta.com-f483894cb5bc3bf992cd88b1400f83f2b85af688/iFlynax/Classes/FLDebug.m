//
//  FLDebug.m
//  iFlynax
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLDebug.h"

@implementation FLDebug

+ (instancetype)sharedInstance {
	static FLDebug *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[self alloc] init];
	});
	return _sharedInstance;
}

+ (void)logger:(NSString *)message {
	NSLog(@"FLDebug::logger: %@", message);
}

+ (void)showAdaptedError:(NSError *)error apiItem:(NSString *)item {
	if (error.code == kCFURLErrorUnknown
        || error.code == kCFURLErrorCancelled
        || error.code == kCFURLErrorNetworkConnectionLost
        || error.code == kCFURLErrorDNSLookupFailed)
    {
		[FLProgressHUD dismiss];
		return;
	}

	NSString *localizedErrorMessage = nil;

    if (kDebugAPIResponse) {
        NSData *responseData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSString *responseDataString = [[NSString alloc] initWithBytes:[responseData bytes]
                                                                length:[responseData length]
                                                              encoding:NSUTF8StringEncoding];

        NSLog(@"item: %@ \n\n error:\n %@ \n\n responseString:\n%@", item, error, responseDataString);
    }

    if (error.code) {
        switch (error.code) {
            case -1009:
                localizedErrorMessage = FLLocalizedString(@"error_code_1009");
                break;
                
            case 3840:
            case -1011:
            case -1016:
                localizedErrorMessage = FLLocalizedString(@"error_code_3840");
                break;
                
            default:
                localizedErrorMessage = error.localizedRecoverySuggestion ?: error.localizedDescription;
                break;
        }
    }
    else localizedErrorMessage = FLLocalizedString(@"error_code_unknown");

	// display the message to user
	[FLProgressHUD showErrorWithStatus:localizedErrorMessage];

	// send the notification to all subscribers
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDebugErrors object:error];
}

@end
