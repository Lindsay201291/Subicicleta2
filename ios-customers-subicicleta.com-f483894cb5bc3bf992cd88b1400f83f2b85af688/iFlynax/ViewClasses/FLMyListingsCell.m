//
//  FLMyListingsCell.m
//  iFlynax
//
//  Created by Alex on 10/31/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLMyListingsCell.h"
#import "FLMyAdShortDetailsModel.h"

@implementation FLMyListingsCell

- (void)fillWithInfoDictionary:(NSDictionary *)info {
    [super fillWithInfoDictionary:info];

    FLMyAdShortDetailsModel *listing = [FLMyAdShortDetailsModel fromDictionary:info];

    if (listing.status == FLListingStatusActive) {
        NSString *activeTill = [listing.planExpireString isEqualToString:listing.payDateString]
        ? FLLocalizedString(@"unlimited")
        : listing.planExpireString;

        self.adSubTitle = FLLocalizedStringReplace(@"active_till", @"{date}", activeTill);
    }
    else {
        self.adSubTitle = FLLocalizedStringReplace(@"status_is", @"{status}", listing.statusStringName);
    }

    /* label color */
    NSString *labelColorHEX;

    switch (listing.status) {
        case FLListingStatusActive:
            labelColorHEX = @"007103";
            break;
        case FLListingStatusInActive:
            labelColorHEX = @"6a6a6a";
            break;
        case FLListingStatusPending:
            labelColorHEX = @"030303";
            break;
        case FLListingStatusIncomplete:
            labelColorHEX = @"2b54a4";
            break;
        case FLListingStatusExpired:
            labelColorHEX = @"fe0009";
            break;
        default:
            labelColorHEX = @"282828";
            break;
    }
    self.adSubTitleColor = FLHexColor(labelColorHEX);
    /* label color END */
}

- (IBAction)accessoryButtonTaped:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMyListingShowAccessoryNotification object:self];
}

@end
