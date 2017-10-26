//
//  FLAboutUsView.m
//  iFlynax
//
//  Created by Alex on 3/30/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLAboutUsView.h"
#import "REFrostedViewController.h"

@interface FLAboutUsView () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@end

@implementation FLAboutUsView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.screenName = FLLocalizedString(@"screen_aboutUs");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.screenName;
    self.view.backgroundColor = _webView.backgroundColor = FLHexColor(@"474747");

    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = F(FLLocalizedString(@"aboutApp_version"), version);
    self.dateLabel.text = kFirstReleaseAppDate;

    NSString *direction = IS_RTL ? @"rtl" : @"ltr";
    NSString *htmlText = F(@"<html><body dir=\"%@\" style=\"font-size:15px;color:#fff;background-color:#474747;margin:0;padding:0;\">%@</body></html>",
                           direction,
                           FLTrueString([FLLang sharedInstance].langKeys[@"aboutApp_description"]));
    [_webView loadHTMLString:htmlText baseURL:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [request.URL.scheme isEqualToString:@"about"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIView animateWithDuration:.3f animations:^{
        _webView.alpha = 1;
    }];
}

#pragma mark - Navigation

- (IBAction)showSideMenu:(UIBarButtonItem *)sender {
    [self.frostedViewController presentMenuViewController];
}

@end
