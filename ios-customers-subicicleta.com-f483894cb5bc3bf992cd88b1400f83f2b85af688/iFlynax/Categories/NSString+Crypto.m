//
//  NSString+Crypto.m
//  iFlynax
//
//  Created by Alex on 12/26/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "NSString+Crypto.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Crypto)

- (NSString *)md5Hash {
	// Create pointer to the string as UTF8
	const char *ptr = [self UTF8String];

	// Create byte array of unsigned chars
	unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

	// Create 16 byte MD5 hash value, store in buffer
	CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);

	// Convert MD5 value in the buffer to NSString of hex values
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x", md5Buffer[i]];

	return output;
}

- (NSString *)sha1Hash {
	const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
	NSData *data = [NSData dataWithBytes:cstr length:self.length];

	uint8_t digest[CC_SHA1_DIGEST_LENGTH];

	CC_SHA1(data.bytes, (CC_LONG)data.length, digest);

	NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

	for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x", digest[i]];

	return output;
}

- (NSString *)encodedString {
    return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                               kCFStringEncodingUTF8);
}

- (BOOL)isEmpty {
    NSInteger length = [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
    
    return length == 0;
}

@end
