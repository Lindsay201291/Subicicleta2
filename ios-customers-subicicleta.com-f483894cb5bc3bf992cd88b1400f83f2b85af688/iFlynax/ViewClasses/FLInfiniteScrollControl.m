//
//  FLTableISContolView.m
//  iFlynax
//
//  Created by Evgeniy Novikov on 6/17/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLInfiniteScrollControl.h"


@interface FLInfiniteScrollControl ()<UIScrollViewDelegate>

@end

@implementation FLInfiniteScrollControl

static NSString * const viewNidName = @"FLInfiniteScrollControl";

+ (instancetype)initWithRect:(CGRect)rect {
    return [[self alloc] initWithFrame:rect];
}

#pragma mark - Instance constructors

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperties];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initProperties];
    }
    return self;
}

- (void)initProperties {
    [[NSBundle mainBundle] loadNibNamed:viewNidName owner:self options:nil];
    self.view.frame = self.bounds;
    
    NSInteger _batch = [FLConfig displayListingsNumberPerPage];
    
    self.autoLoadMessage = F(FLLocalizedString(@"loading_next_number_listings"), _batch);
    self.manualLoadMessage = F(FLLocalizedString(@"load_next_number_listings"), _batch);
    self.infiniteScroll = [FLUserDefaults isPreloadType:FLPreloadTypeScroll];
    [self insertSubview:_view atIndex:0];
}

#pragma mark - Accessors

- (void)setInfiniteScroll:(BOOL)enabled {
    _infiniteScroll = enabled;
    if (enabled) {
        _loadMoreButton.hidden = YES;
        _spinnerControlView.hidden = NO;
    }
    else {
        _spinnerControlView.hidden = YES;
        _loadMoreButton.hidden = NO;
    }
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    NSString *title = loading ? _autoLoadMessage : _manualLoadMessage;
    [self.loadMoreButton setTitle:title forState:UIControlStateNormal];
    _loadMoreButton.enabled = !loading;
}

- (void)setAutoLoadMessage:(NSString *)message {
    _autoLoadMessage = message;
    self.spinnerTextLabel.text = message;
}

- (void)setManualLoadMessage:(NSString *)message {
    _manualLoadMessage = message;
    [self.loadMoreButton setTitle:message forState:UIControlStateNormal];
}

#pragma mark - Advanced features

- (void)defineMessagesWithStackType:(FLLoadingStackType)type withLoadAmount:(NSInteger)amount withTargetName:(NSString *)target {
    NSString *messageTail  = F(@"%@ %ld %@", [self stringFromType:type], (long)amount, target);
    self.autoLoadMessage   = F(@"%@ %@",FLLocalizedString(@"inf_scroll_loading"), messageTail);
    self.manualLoadMessage = F(@"%@ %@",FLLocalizedString(@"inf_scroll_load"), messageTail);
}

- (void)defineMessagesWithTotal:(NSInteger)total withCurrentAmount:(NSInteger)amount withBatch:(NSInteger)batch withTarget:(NSString *)target {
    NSInteger number = total - amount;
    FLLoadingStackType stackType = FLLoadingStackTypeLast;
    if (number > batch) {
        number = batch;
        stackType = FLLoadingStackTypeNext;
    }
    
    [self defineMessagesWithStackType:stackType
                                    withLoadAmount:number
                                    withTargetName:target];
}

- (NSString *)stringFromType:(FLLoadingStackType)type {
    switch (type) {
        case FLLoadingStackTypeLast:
            return FLLocalizedString(@"inf_scroll_last");
        case FLLoadingStackTypeNext:
            return FLLocalizedString(@"inf_scroll_next");
    }
    return nil;
}

#pragma mark - Actions

- (IBAction)loadMoreButtonTaped:(id)sender {
    self.loading = YES;
    [self.delegate flInfiniteScrollControl:self loadMoreButtonTaped:sender];
}

@end
