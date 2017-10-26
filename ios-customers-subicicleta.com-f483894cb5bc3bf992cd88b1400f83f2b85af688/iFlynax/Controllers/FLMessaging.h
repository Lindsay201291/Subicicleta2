//
//  FLMessaging.h
//  iFlynax
//
//  Created by Alex on 6/22/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "SOMessagingViewController.h"
#import "FLNavigationController.h"

@interface FLMessaging : SOMessagingViewController
@property (weak, readonly, nonatomic) FLNavigationController *flNavigationController;
@property (copy, nonatomic) NSString *visitorMail;
@property (strong, nonatomic) UIImage  *partnerImage;
@property (strong, nonatomic) NSNumber *recipient;

- (void)appendRemoteMessage:(NSString *)message;
@end
