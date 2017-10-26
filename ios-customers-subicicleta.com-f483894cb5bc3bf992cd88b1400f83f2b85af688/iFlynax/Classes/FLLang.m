//
//  FLLang.m
//  iFlynax
//
//  Created by Alex on 4/23/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLLang.h"

@interface FLLang ()
@property (strong, nonatomic) NSString *langCode;
@end

@implementation FLLang

+ (instancetype)sharedInstance {
	static FLLang *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[self alloc] init];
        [_sharedInstance refreshWithBlock:nil];
	});
	return _sharedInstance;
}

+ (void)refresh {
    [[FLLang sharedInstance] refreshWithBlock:nil];
}

+ (void)refreshWithBlock:(dispatch_block_t)block {
    [[FLLang sharedInstance] refreshWithBlock:block];
}

+ (NSString *)langWithKey:(NSString *)key {
	return [[FLLang sharedInstance] langWithKey:key];
}

+ (NSString *)langWithKey:(NSString *)key search:(NSString *)search replace:(NSString *)replace {
    NSString *string = [[FLLang sharedInstance] langWithKey:key];
    return [string stringByReplacingOccurrencesOfString:search withString:replace];
}

+ (NSString *)langCode {
	return [FLLang sharedInstance].langCode;
}

+ (NSDictionary *)languages {
    return [FLLang sharedInstance].languages;
}

+ (FLLanguageDirection)direction {
    return [[FLLang sharedInstance] direction];
}

#pragma mark - Private methods

// TODO: The RTL version not stable! - required to update directions for some of UI elements.
- (FLLanguageDirection)direction {
    if ([self.languages[self.langCode][@"Direction"] isEqualToString:@"rtl"]) {
        return FLLanguageDirectionRTL;
    }
    return FLLanguageDirectionLTR;
}

- (BOOL)isRTL {
    return [self direction] == FLLanguageDirectionRTL;
}

- (void)refreshWithBlock:(dispatch_block_t)block {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // set current language code
    self.langCode = [defaults valueForKey:kDefaultKeyCurrentLanguage];
    // set languages list
    self.languages = [defaults objectForKey:kCacheLanguagesKey];
    // set lang_keys for current language
    NSString *langKeysKey = F(@"%@%@", kLangKeysKeyPrefix, self.langCode);
    self.langKeys  = [defaults objectForKey:langKeysKey];

    // manage UI direction
    if ([[[UIView alloc] init] respondsToSelector:@selector(setSemanticContentAttribute:)]) {
        // switch to RTL
        if ([self isRTL]) {
            [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
        }
        // switch to LTR
        else {
            [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
        }
    }

    if (block != nil) {
        block();
    }
}

- (NSString *)langWithKey:(NSString *)key {
	if (key != nil && _langKeys != nil) {
		if (_langKeys[key] != nil) {
			return FLCleanString(_langKeys[key]);
		}
	}
	return NSLocalizedString(key, nil);
}

#pragma mark - Custom actions with localization

- (void)showSuccessUpdatedListing:(BOOL)editMode {
    [FLProgressHUD dismiss];
    NSString *messageKey;
    
    if (editMode) {
        messageKey = [FLConfig boolWithKey:@"edit_listing_auto_approval"]
        ? @"listing_edit_auto_approved"
        : @"listing_edit_pending";
    }
    else {
        messageKey = [FLConfig boolWithKey:@"listing_auto_approval"]
        ? @"listing_added_auto_approved"
        : @"listing_added_pending";
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:FLLocalizedString(messageKey)
                                                       delegate:self cancelButtonTitle:nil
                                              otherButtonTitles:FLLocalizedString(@"button_ok"), nil];
        [alert show];
    });
}

@end
