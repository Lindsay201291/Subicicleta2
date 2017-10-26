//
//  FLCommentsView.m
//  iFlynax
//
//  Created by Alex on 9/1/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLCommentsView.h"
#import "FLCommentCell.h"
#import "FLCommentModel.h"
#import "FLAddCommentViewController.h"
#import "FLNavigationController.h"

@interface FLCommentsView () {
    BOOL _animateInsertedCell;
}

@end

@implementation FLCommentsView


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = FLLocalizedString(@"screen_comments");
    
    self.initStack    = 1;
    self.currentStack = 1;
    self.itemsInStack = [FLConfigWithKey(kConfigCommentsPerPage) intValue];
    self.targetItemName = FLLocalizedString(@"inf_scroll_target_comments");
    
    self.apiCmd = kApiItemRequests_getComments;
    [self addApiParameter:@(_addID) forKey:@"lid"];
    
    UINib *cellNib = [UINib nibWithNibName:kNibNameCommentCell bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kStoryBoardCommentCellIdentifier];
    
    if (_comments.count > 0) {
        [self.entries addObjectsFromArray:_comments];
        self.currentStack++;
        self.itemsTotal = _commentsTotal;
        [self resignLoadingMessages];
        [self fadeTableViewIn];
    }
    
    _animateInsertedCell = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newCommentDidSend:)
                                                 name:kNotificationNewCommentAdded
                                               object:nil];
}

- (void)handleSucceedRequest:(id)results {
    NSArray *commentsInfo = results[@"comments"];
    for (NSDictionary *commentData in commentsInfo) {
        [self.entries addObject:[FLCommentModel fromDictionary:commentData]];
    }
    self.itemsTotal = [results[@"calc"] intValue];
}

#pragma mark - UITableViewDataSouce

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoryBoardCommentCellIdentifier];
    [self prepareCommentCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)prepareCommentCell:(FLCommentCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FLCommentModel * comment = self.entries[indexPath.row];
    [cell fillWithCommentModel:comment];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FLCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kStoryBoardCommentCellIdentifier];
    [self prepareCommentCell:cell atIndexPath:indexPath];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(FLCommentCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_animateInsertedCell && indexPath.row == 0) {
        [cell blink];
        _animateInsertedCell = NO;
    }
}

#pragma mark - Navigation

- (void)scrollToTopWithAnimation:(BOOL)animation {
    CGPoint contentOffset = CGPointMake(0, 0);
    if (animation)
        [UIView animateWithDuration:.3f animations:^{
            self.tableView.contentOffset = contentOffset;
        }];
    else
        self.tableView.contentOffset = contentOffset;
}

- (IBAction)addCommentButtonTaped:(UIButton *)sender {
    FLAddCommentViewController *addCommentViewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardAddCommentView];
    addCommentViewController.adId = _addID;
    FLNavigationController *navigator = [[FLNavigationController alloc] initWithRootViewController:addCommentViewController];
    [self.navigationController presentViewController:navigator animated:YES completion:nil];
}

- (void)newCommentDidSend:(NSNotification *)notification {
    _animateInsertedCell = YES;
    [self.entries insertObject:notification.object atIndex:0];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self scrollToTopWithAnimation:YES];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationNewCommentAdded
                                                  object:nil];
}

@end
