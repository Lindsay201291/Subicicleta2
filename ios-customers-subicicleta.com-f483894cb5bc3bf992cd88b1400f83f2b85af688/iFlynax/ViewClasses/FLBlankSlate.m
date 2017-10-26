//
//  FLEmptyDataSet.m
//  iFlynax
//
//  Created by Alex on 7/10/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLBlankSlate.h"
#import "UIScrollView+EmptyDataSet.h"

static NSString * const kDefaultEmptyImageName = @"empty_placeholder_logo";

@interface FLBlankSlate () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property UIScrollView *attachedScroll;

@end

@implementation FLBlankSlate

+ (instancetype)sharedInstance {
    static FLBlankSlate *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

+ (void)attachTo:(UIScrollView *)scrollView withTitle:(NSString *)title {
    return [[FLBlankSlate sharedInstance] attachTo:scrollView withTitle:title message:nil];
}

+ (void)attachTo:(UIScrollView *)scrollView withTitle:(NSString *)title message:(NSString *)message {
    return [[FLBlankSlate sharedInstance] attachTo:scrollView withTitle:title message:message];
}

- (void)attachTo:(UIScrollView *)scrollView withTitle:(NSString *)title message:(NSString *)message {

    // unregister internal observers and invalidate private states.
    if (_attachedScroll != nil) {
        [self unregisterObservers];
    }

    _attachedScroll = scrollView;
    _message        = message;
    _title          = title;
    _displayImage   = YES;

    _attachedScroll.emptyDataSetDelegate = self;
    _attachedScroll.emptyDataSetSource = self;

    // A little trick for removing the cell separators
    if ([scrollView isKindOfClass:UITableView.class]) {
        UITableView *table = (UITableView *)scrollView;
        if (table.tableFooterView == nil) {
            table.tableFooterView = [UIView new];
        }
    }
}

- (void)unregisterObservers {
    _attachedScroll.emptyDataSetDelegate = nil;
    _attachedScroll.emptyDataSetSource = nil;
}

#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if (_title == nil) {
        return nil;
    }

    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17.0],
                                 NSForegroundColorAttributeName: [UIColor blackColor]};
    return [[NSAttributedString alloc] initWithString:_title attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    if (_message == nil) {
        return nil;
    }

    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;

    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    return [[NSAttributedString alloc] initWithString:_message attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *_imageName = _displayImage ? kDefaultEmptyImageName : @"clear_point";
    return [UIImage imageNamed:_imageName];
}

#pragma mark - DZNEmptyDataSetDelegate

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

@end
