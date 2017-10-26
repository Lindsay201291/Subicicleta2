//
//  FLMyMessagesView.h
//  iFlynax
//
//  Created by Alex on 3/19/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLViewController.h"
#import "FLNavigationController.h"

@interface FLMyMessagesView : FLViewController
@property (weak, readonly, nonatomic) FLNavigationController *flNavigationController;

- (void)refreshConversations;
@end
