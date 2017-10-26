//
//  FLTopNotificationView.h
//  iFlynax
//
//  Created by Alex on 4/11/16.
//  Copyright © 2016 Flynax. All rights reserved.
//

#import "HDNotificationView.h"

@interface FLTopNotificationView : HDNotificationView

+ (void)showNewMessageNotificationFrom:(NSString *)author
                               message:(NSString *)message
                               onTouch:(dispatch_block_t)onTouch;
@end
