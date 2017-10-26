//
//  NSString+Crypto.h
//  iFlynax
//
//  Created by Alex on 12/26/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Crypto)

/**
 *	Description
 */
- (NSString *)md5Hash;

/**
 *	Description
 */
- (NSString *)sha1Hash;

/**
 *	Description
 */
- (NSString *)encodedString;

- (BOOL)isEmpty;
@end
