//
//  FLSearchResultsVC.m
//  iFlynax
//
//  Created by Alex on 11/6/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLSearchResultsVC.h"

@interface FLSearchResultsVC ()

@end

@implementation FLSearchResultsVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = FLLocalizedString(@"cargando");

    self.apiCmd = kApiItemRequests_searchListings;
    self.apiParameters[@"f"] = self.formValues;

    self.blankSlate.title = FLLocalizedString(@"blankSlate_searchResults_titulo");
    self.blankSlate.message = FLLocalizedString(@"blankSlate_searchResults_mensaje");

    [self loadDataWithRefresh:YES];
}

- (void)handleSucceedRequest:(id)results {
    self.itemsTotal = [results[@"calc"] intValue];
    [self.entries addObjectsFromArray:results[@"listings"]];

    self.title = FLLocalizedStringReplace(@"screen_search_anuncios_encontrados",
                                          @"{number}",
                                          FLTrueString(results[@"calc"]));
}

@end
