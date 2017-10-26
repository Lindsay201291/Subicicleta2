//
//  FLPolicyVC.h
//  iFlynax
//
//  Created by Alex on 1/14/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import "FLViewController.h"

@interface FLPolicyVC : FLViewController
@property (copy, nonatomic) void (^buttonsTrigger)(BOOL accepted);
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@end
