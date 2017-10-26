//
//  FLKeyboardHandler.h
//  iFlynax
//
//  Created by Alex on 3/12/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FLKeyboardHandlerDelegate;

@interface FLKeyboardHandler : NSObject
@property (nonatomic, assign) id<FLKeyboardHandlerDelegate> delegate;

@property (nonatomic) BOOL autoHideEnable;

@property (nonatomic) BOOL isKeyboardOn;
/**
 *	Description
 *	@param scroll scroll description
 */
- (instancetype)initWithScroll:(UIScrollView *)scroll;

/**
 *	Description
 */
- (void)unRegisterNotifications;
@end

@protocol FLKeyboardHandlerDelegate <NSObject>

@optional

- (void)keyboardHandlerDidShowKeyboard;
- (void)keyboardHandlerWillHideKeyboard;
- (void)keyboardHandlerDidHideKeyboard;

@end
