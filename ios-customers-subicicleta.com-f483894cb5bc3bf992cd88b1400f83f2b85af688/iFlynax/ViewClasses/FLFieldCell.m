//
//  FLFieldCell.m
//  iFlynax
//
//  Created by Alex on 10/5/15.
//  Copyright © 2015 Flynax. All rights reserved.
//

#import "FLFieldCell.h"

@implementation FLFieldCell

- (UILabel *)fieldPlaceholder {
    if (_fieldPlaceholder == nil) {
        _fieldPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 14)];
        _fieldPlaceholder.font = [UIFont italicSystemFontOfSize:12];
        _fieldPlaceholder.textAlignment = NSTextAlignmentCenter;
        _fieldPlaceholder.textColor = [UIColor darkGrayColor];
    }
    return _fieldPlaceholder;
}

- (void)cellDidLoad {
    [super cellDidLoad];

    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.actionBar.tintColor = FLHexColor(kColorInputAccessoryToolbarTint);

    // modify action bar
    UIImage *leftArrow  = [UIImage imageNamed:@"UIButtonBarArrowLeft"];
    UIImage *rightArrow = [UIImage imageNamed:@"UIButtonBarArrowRight"];
    [self.actionBar.navigationControl setImage:leftArrow forSegmentAtIndex:IS_RTL ? 1 : 0];
    [self.actionBar.navigationControl setImage:rightArrow forSegmentAtIndex:IS_RTL ? 0 : 1];

    [self.actionBar.navigationControl setBackgroundImage:[UIImage imageNamed:@"Transparent"]
                                                forState:UIControlStateNormal
                                              barMetrics:UIBarMetricsDefault];

    NSMutableArray *_items = [[self.actionBar.items subarrayWithRange:NSMakeRange(0, 1)] mutableCopy];

    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fieldPlaceholderWrapper = [[UIBarButtonItem alloc] initWithCustomView:self.fieldPlaceholder];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:FLLocalizedString(@"button_done")
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self.actionBar
                                                                  action:@selector(handleActionBarDone:)];

    [_items insertObject:flexible atIndex:1];
    [_items insertObject:fieldPlaceholderWrapper atIndex:2];
    [_items insertObject:flexible atIndex:3];
    [_items insertObject:doneButton atIndex:4];

    self.actionBar.items = _items;
}

- (void)highlightInput:(id)input highlighted:(BOOL)highlighted {
    NSString *_hexColor = highlighted ? kColorFieldHasError : kColorFLTextFieldBorder;
    ((UIView *)input).layer.borderColor = [UIColor hexColor:_hexColor].CGColor;
    ((UIView *)input).layer.borderWidth = highlighted ? 1.5f : 1.0f;
}

@end
