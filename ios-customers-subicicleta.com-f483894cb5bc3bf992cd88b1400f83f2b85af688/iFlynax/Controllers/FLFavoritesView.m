//
//  FLFavoritesView.m
//  iFlynax
//
//  Created by Alex on 11/13/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLFavoritesView.h"

@implementation FLFavoritesView

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = FLLocalizedString(@"screen_favorite_ads_view");
    
    self.apiItem = kApiItemFavorites;
    
    self.initStack    = 1;
    self.currentStack = 1;
    
    self.blankSlate.title = FLLocalizedString(@"blankSlate_favorites_title");
    self.blankSlate.message = FLLocalizedString(@"blankSlate_favorites_message");
    
    [self loadDataWithRefresh:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteBtnDidTap:)
                                                 name:kNotificationFavoriteBtnDidTap object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationFavoriteBtnDidTap object:nil];
}

- (void)favoriteBtnDidTap:(NSNotification *)notification {
    FLAdFavoriteButton *button = [notification object];

    // list view
    if (button.indexPath && !button.isFavorite) {
        [self.entries removeObjectAtIndex:button.indexPath.row];
    }
    // ad details
    else if (!button.indexPath && button.adId) {
        [self.entries enumerateObjectsUsingBlock:^(NSDictionary *listing, NSUInteger idx, BOOL * _Nonnull stop) {
            if (button.adId == [listing[@"id"] integerValue]) {
                [self.entries removeObject:listing];
                *stop = YES;
            }
        }];
    }
    [self clearBrokenFavoritesIfNecessary];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)apiRequestWithCompletion:(FLApiCompletionHandler)completion {
    NSString *_favs = [[[FLFavorites allItems] allValues] componentsJoinedByString:@","];
    if (_favs.length) {
        [self addApiParameter:_favs forKey:@"ids"];
    }
    else [self removeApiParameterForKey:@"ids"];

    [super apiRequestWithCompletion:completion];
}

- (void)handleSucceedRequest:(id)results {
    [super handleSucceedRequest:results];
    [self clearBrokenFavoritesIfNecessary];

    self.itemsTotal = FLTrueInt(results[@"calc"]);

    if ([FLFavorites itemsCount] != self.itemsTotal) {
        [[FLFavorites sharedInstance] updateItemsCount:self.itemsTotal];
    }
}

- (void)clearBrokenFavoritesIfNecessary {
    if (!self.entries.count && [FLFavorites allItems].count) {
        [[FLFavorites sharedInstance] clearFavorites];
    }
}

@end
