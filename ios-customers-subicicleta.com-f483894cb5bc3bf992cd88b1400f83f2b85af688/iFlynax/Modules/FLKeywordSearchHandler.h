//
//  FLKeywordSearchHandler.h
//  iFlynax
//
//  Created by Alex on 5/2/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^FLListingDidTap)(NSDictionary *details);

@interface FLKeywordSearchHandler : NSObject
@property (strong, nonatomic) UISearchDisplayController *searchDC;
@property (strong, nonatomic) UITableView *searchResultsTableView;
@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) NSArray *entries;
@property (copy, nonatomic) FLListingDidTap searchResultsCellDidTapBlock;

- (instancetype)initWithSearchDC:(UISearchDisplayController *)searchDC;
@end
