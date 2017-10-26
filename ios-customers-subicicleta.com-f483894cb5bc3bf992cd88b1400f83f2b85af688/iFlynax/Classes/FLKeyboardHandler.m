//
//  FLKeyboardHandler.m
//  iFlynax
//
//  Created by Alex on 3/12/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLKeyboardHandler.h"

@interface FLKeyboardHandler ()
@property (nonatomic, assign) UIEdgeInsets origContentInset;
@property (nonatomic, assign) UIScrollView *scroll;
@end

@implementation FLKeyboardHandler

- (instancetype)initWithScroll:(UIScrollView *)scroll {
    self = [super init];
    if (self) {
        _autoHideEnable = YES;
        [self setScroll:scroll];
        [self registerNotifications];
    }
    return self;
}

- (void)setScroll:(UIScrollView *)scroll {
    _scroll = scroll;
    [self recognizeScrollTap];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)recognizeScrollTap {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(scrollViewTapHandler:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.enabled              = YES;
    singleTap.cancelsTouchesInView = NO;
    [_scroll addGestureRecognizer:singleTap];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    
    if (_isKeyboardOn) {
        return;
    }

    CGRect kbFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    kbFrame = [_scroll convertRect:kbFrame fromView:_scroll.window];
    _origContentInset = _scroll.contentInset;
    
    CGRect contAbsFrame = [_scroll.superview convertRect:_scroll.superview.bounds toView:nil];
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat bottomInset = contAbsFrame.origin.y + contAbsFrame.size.height - (screenBounds.size.height - kbFrame.size.height);
    UIEdgeInsets insets = UIEdgeInsetsMake(_origContentInset.top,
                                           _origContentInset.left,
                                           bottomInset,
                                           _origContentInset.right);
    
    _scroll.contentInset = insets;
    _scroll.scrollIndicatorInsets = insets;

    _isKeyboardOn = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(keyboardHandlerDidShowKeyboard)]) {
        [_delegate keyboardHandlerDidShowKeyboard];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _scroll.contentInset = _origContentInset;
    _scroll.scrollIndicatorInsets = _origContentInset;

    if (_delegate && [_delegate respondsToSelector:@selector(keyboardHandlerWillHideKeyboard)]) {
        [_delegate keyboardHandlerWillHideKeyboard];
    }
}

- (void)keyboardDidHide:(NSNotification *)notification {
    if (!_isKeyboardOn) {
        return;
    }
    _isKeyboardOn = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(keyboardHandlerDidHideKeyboard)]) {
        [_delegate keyboardHandlerDidHideKeyboard];
    }
}

- (void)scrollViewTapHandler:(UITapGestureRecognizer *)gesture {
    if (_isKeyboardOn && _autoHideEnable) {
        [_scroll endEditing:YES];
    }
}

- (void)unRegisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
}

- (void)dealloc {
    [self unRegisterNotifications];
}

@end
