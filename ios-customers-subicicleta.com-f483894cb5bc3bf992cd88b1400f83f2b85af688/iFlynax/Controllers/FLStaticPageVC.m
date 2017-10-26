//
//  FLStaticPageVC.m
//  iFlynax
//
//  Created by Alex on 12/9/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLStaticPageVC.h"

@interface FLStaticPageVC ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation FLStaticPageVC

- (void)viewDidLoad {
    [super viewDidLoad];

    _webView.backgroundColor = FLHexColor(kColorBackgroundColor);

    [FLProgressHUD showWithStatus:FLLocalizedString(@"loading")];
    [flynaxAPIClient getApiItem:kApiItemRequests
                     parameters:@{@"cmd": kApiItemRequests_staticPageContent,
                                  @"page": _pageKey}
                     completion:^(NSDictionary *response, NSError *error) {
                         if (!error && [response isKindOfClass:NSDictionary.class]) {
                             [_webView loadHTMLString:FLTrueString(response[@"html"]) baseURL:nil];
                             [FLProgressHUD dismiss];
                         }
                         else [FLDebug showAdaptedError:error apiItem:kApiItemRequests_staticPageContent];
                     }];
}

- (void)viewDidAppear:(BOOL)animated {
    self.screenName = F(@"Static page (key: %@)", _pageKey);
    [super viewDidAppear:animated];
}

@end
