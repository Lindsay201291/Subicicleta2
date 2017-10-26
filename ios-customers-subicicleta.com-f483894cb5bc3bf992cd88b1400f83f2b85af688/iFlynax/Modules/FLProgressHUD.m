//
//  FLProgressHUD.m
//  iFlynax
//
//  Created by Alex on 3/15/17.
//  Copyright © 2017 Flynax. All rights reserved.
//

#import "FLProgressHUD.h"

@implementation FLProgressHUD

+ (void)customize {
    [SVProgressHUD setBackgroundColor:[UIColor hexColor:@"0f1c1e" alpha:.6f]];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
}

+ (void)showSuccessWithStatus:(NSString *)status {
    [SVProgressHUD showSuccessWithStatus:status maskType:SVProgressHUDMaskTypeNone];
}

+ (void)showErrorWithStatus:(NSString *)status {
    [SVProgressHUD showErrorWithStatus:status maskType:SVProgressHUDMaskTypeNone];
}

+ (void)showProgress:(float)progress status:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showProgress:progress status:status];
    });
}

@end
