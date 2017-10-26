//
//  FLLegalView.m
//  iFlynax
//
//  Created by Alex on 4/6/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "FLLegalView.h"

@interface FLLegalView ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation FLLegalView

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = FLLocalizedString(@"screen_legal_information");

    [_webView setAlpha:.5f];
    NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"legal_information" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];

    NSMutableString *content = [NSMutableString stringWithString:htmlString];
    [content appendFormat:@"<p>%@</p>", [GMSServices openSourceLicenseInfo]];

    [_webView loadHTMLString:content baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Web View Delegate Methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_webView setAlpha:1];
}

@end
