//
//  FLUtilities.m
//  iFlynax
//
//  Created by Alex on 9/30/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLUtilities.h"

static BOOL stringOrValue(id obj) {
    return ([obj isKindOfClass:NSString.class] ||
            [obj isKindOfClass:NSValue.class]);
}

@implementation FLUtilities

+ (int)FLTrueInt:(id)obj {
    if (stringOrValue(obj)) {
        return [obj intValue];
    }
    return 0;
}

+ (double)FLTrueDouble:(id)obj {
    if (stringOrValue(obj)) {
        return [obj doubleValue];
    }
    return 0.0;
}

+ (CGFloat)FLTrueFloat:(id)obj {
    if (stringOrValue(obj)) {
        return [obj floatValue];
    }
    return 0;
}

+ (BOOL)FLTrueBool:(id)obj {
    if (stringOrValue(obj)) {
        return [obj boolValue];
    }
    else if ([obj isKindOfClass:NSNumber.class] && [obj isEqual:@1]) {
        return YES;
    }
    return NO;
}

+ (NSInteger)FLTrueInteger:(id)obj {
    if (stringOrValue(obj)) {
        return [obj integerValue];
    }
    return 0;
}

+ (NSString *)FLTrueString:(id)obj {
    if (obj != nil && obj != [NSNull null]) {
        if ([obj isKindOfClass:NSString.class]) {
            return obj;
        }
        else if ([obj isKindOfClass:NSNumber.class]) {
            return [NSString stringWithFormat:@"%@", obj];
        }
    }
    return @"";
}

#pragma mark -

+ (NSLocale *)localeByCurrencyCode:(NSString *)currency {
    NSArray *locales = [NSLocale availableLocaleIdentifiers];
    NSLocale *locale = nil;
    NSString *localeId;

    for (localeId in locales) {
        locale = [[NSLocale alloc] initWithLocaleIdentifier:localeId];
        NSString *code = [locale objectForKey:NSLocaleCurrencyCode];

        if ([code isEqualToString:currency]) {
            break;
        }
        else {
            locale = nil;
        }
    }

    // For some codes that locale cannot be found, init it different way.
    if (locale == nil) {
        NSDictionary *components = [NSDictionary dictionaryWithObject:currency forKey:NSLocaleCurrencyCode];
        localeId = [NSLocale localeIdentifierFromComponents:components];
        locale = [[NSLocale alloc] initWithLocaleIdentifier:localeId];
    }
    return locale;
}

+ (NSString *)priceFormat:(NSString *)price { // dev
    NSArray *lines = [price componentsSeparatedByString: @" "];
    if (lines.count > 1) {
        NSString *lineOne = lines[1];
        NSArray *frag = [lineOne componentsSeparatedByString: @"."];
        if ([frag count] > 1) {
            NSString *fragOne = [frag lastObject];
            if ([fragOne length] == 0) {
                NSRange lastDot = [price rangeOfString:@"." options:NSBackwardsSearch];
                if (lastDot.location != NSNotFound)
                    return [price stringByReplacingCharactersInRange:lastDot
                                                       withString: @""];
            }
            else if ([fragOne length] < 3) {
                NSRange lastDot = [price rangeOfString:@"." options:NSBackwardsSearch];
                if (lastDot.location != NSNotFound)
                    return [price stringByReplacingCharactersInRange:lastDot
                                                          withString: @","];
            }
        }
    }
    return price;
}

+ (NSString *)dateFormat:(NSString *)date withOrigin:(NSString *) origin andDest:(NSString *) dest { // dev

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:origin];
    NSDate *tempDate = [dateFormatter dateFromString:date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dest];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    return [formatter stringFromDate:tempDate];
}

+ (NSString *)statusFormat:(NSString *)status { // dev
     if ([status isEqualToString:@"Visible(default)"]) {
        return @"visible";
     }
     else if ([status isEqualToString:@"Invisible"]) {
        return @"invisible";
     }
     else if ([status isEqualToString:@"Vendido"]) {
        return @"sold";
     }
    
    return @"";
}

+ (BOOL)isValidUrl:(NSString *)urlString {
    NSString *format = @"SELF MATCHES '((?:http|https)://)?([\\w\\d\\-_]+\\.)?[\\w\\d\\-_]+\\.\\w{2,5}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?'";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
    return [[@[urlString] filteredArrayUsingPredicate:predicate] count];
}

+ (BOOL)isValidEmail:(NSString *)emailString {
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,8}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    return [emailTest evaluateWithObject:emailString];
}

@end
