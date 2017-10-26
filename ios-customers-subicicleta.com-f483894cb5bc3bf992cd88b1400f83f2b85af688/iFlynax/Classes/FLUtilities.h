//
//  FLUtilities.h
//  iFlynax
//
//  Created by Alex on 9/30/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FLUtilities;

#define FLTrueInt(obj)     [FLUtilities FLTrueInt:(obj)]
#define FLTrueBool(obj)    [FLUtilities FLTrueBool:(obj)]
#define FLTrueFloat(obj)   [FLUtilities FLTrueFloat:(obj)]
#define FLTrueDouble(obj)  [FLUtilities FLTrueDouble:(obj)]
#define FLTrueInteger(obj) [FLUtilities FLTrueInteger:(obj)]
#define FLTrueString(obj)  [FLUtilities FLTrueString:(obj)]

@interface FLUtilities : NSObject

+ (int)FLTrueInt:(id)obj;
+ (BOOL)FLTrueBool:(id)obj;
+ (double)FLTrueDouble:(id)obj;
+ (CGFloat)FLTrueFloat:(id)obj;
+ (NSInteger)FLTrueInteger:(id)obj;
+ (NSString *)FLTrueString:(id)obj;

+ (NSLocale *)localeByCurrencyCode:(NSString *)currency;

+ (BOOL)isValidUrl:(NSString *)urlString;
+ (BOOL)isValidEmail:(NSString *)emailString;
@end
