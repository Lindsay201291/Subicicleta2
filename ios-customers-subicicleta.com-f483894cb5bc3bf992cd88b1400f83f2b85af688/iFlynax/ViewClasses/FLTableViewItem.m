//
//  FLTableViewItem.m
//  iFlynax
//
//  Created by Alex on 10/9/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLTableViewItem.h"

@implementation FLTableViewItem

- (NSDictionary *)itemData {
    return nil;
}

- (BOOL)isValid {
    return YES;
}

- (void)resetValues {
    //
}

- (NSString *)placeholderFrom {
    return F(@"%@ (%@)",
             self.placeholder,
             FLLocalizedString(@"placeholder_from"));
}

- (NSString *)placeholderTo {
    return F(@"%@ (%@)",
             self.placeholder,
             FLLocalizedString(@"placeholder_to"));
}

@end
