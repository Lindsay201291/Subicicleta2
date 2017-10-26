//
//  FLMyMessagesView.m
//  iFlynax
//
//  Created by Alex on 3/19/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLMyMessagesView.h"
#import "FLConversationCell.h"
#import "REFrostedViewController.h"
#import "FLMessageModel.h"
#import "FLMessaging.h"

static NSString * const kConversationCellIdentifier = @"conversationCell";

static NSString * const kNewMessagesCountKey = @"new_messages";
static NSString * const kConversationsKey    = @"conversations";

@interface FLMyMessagesView () {
    UIRefreshControl *_refreshControl;
    FLNavigationController *_flNavigationController;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *entries;
@end

@implementation FLMyMessagesView

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = FLLocalizedString(@"screen_my_messages");
    self.view.backgroundColor = _tableView.backgroundColor = FLHexColor(kColorBackgroundColor);

    // append refresh control
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl setTintColor:FLHexColor(kColorBarTintColor)];
    [_refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];

    [FLBlankSlate attachTo:self.tableView
                 withTitle:FLLocalizedString(@"blankSlate_conversations_title")
                   message:FLLocalizedString(@"blankSlate_conversations_message")];

    _entries = [@[] mutableCopy];
    [self.editButtonItem setTitle:FLLocalizedString(@"button_edit")];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];

    [self.editButtonItem setTitle:FLLocalizedString(editing ? @"button_done" : @"button_edit")];
    [_tableView setEditing:editing animated:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // simulation of first launch (aka: viewDidLoad)
    if (!_entries.count) {
        self.tableView.alpha = 0;
        [self loadConversations];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    self.screenName = self.title;
    [super viewDidAppear:animated];
}

#pragma mark -

- (void)handleRefresh:(UIRefreshControl *)sender {
    [self loadConversations];
}

- (void)refreshConversations {
    [_refreshControl beginRefreshing];
    [self loadConversations];
}

- (void)loadConversations {
    if (!_refreshControl.refreshing) {
        [FLProgressHUD showWithStatus:FLLocalizedString(@"loading")];
    }

    [flynaxAPIClient getApiItem:kApiItemRequests
                     parameters:@{@"cmd": kApiItemRequests_conversations}
                     completion:^(NSDictionary *response, NSError *error) {
                         if (error == nil) {
                             if ([response isKindOfClass:NSDictionary.class]) {
                                 if (response[kConversationsKey] != nil && [response[kConversationsKey] count]) {
                                     _entries = [response[kConversationsKey] mutableCopy];
                                     self.navigationItem.rightBarButtonItem = self.editButtonItem;
                                 }
                                 else {
                                     self.navigationItem.rightBarButtonItem = nil;
                                 }
                                 [FLAccount loggedUser].newMessageCount = FLTrueInteger(response[kNewMessagesCountKey]);
                             }
                         } else [FLDebug showAdaptedError:error apiItem:kApiItemRequests_conversations];

                         dispatch_async(dispatch_get_main_queue(), ^{
                             [_tableView reloadData];

                             [UIView animateWithDuration:.3f animations:^{
                                 self.tableView.alpha = 1.0f;
                             } completion:^(BOOL finished) {
                                 [_refreshControl endRefreshing];
                                 [FLProgressHUD dismiss];
                             }];
                         });
                     }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _entries.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 91;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	FLConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kConversationCellIdentifier];
	NSDictionary *conversation = _entries[indexPath.row];

    cell.dateOfMessage = conversation[@"datetime"];
    cell.authorName = conversation[@"authorName"];
    cell.message = conversation[@"message"];
    cell.photoUrl = conversation[@"photo"];
    cell.newMessagesCount = FLTrueInteger(conversation[@"count"]);

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FLConversationCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *rowInfo = _entries[indexPath.row];

    NSInteger _author = FLTrueInteger(rowInfo[@"authorId"]);

    FLMessaging *messaging;
    messaging = [self.storyboard instantiateViewControllerWithIdentifier:kStoryBoardMessagingView];
    messaging.title = FLCleanString(rowInfo[@"authorName"]);
    messaging.partnerImage = [cell thumbnail];
    messaging.recipient = @(_author);

    if (_author == kUserWebsiteVisitor) {
        messaging.visitorMail = _entries[indexPath.row][@"email"];
    }

    [self.navigationController pushViewController:messaging animated:YES];

    // decrease newMessages counter
    [FLAccount loggedUser].newMessageCount -= FLTrueInteger(rowInfo[@"count"]);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeConversation:_entries[indexPath.row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
    [tableView endUpdates];
}

- (void)removeConversation:(NSDictionary *)conversation {
    [_entries removeObject:conversation];

    [flynaxAPIClient postApiItem:kApiItemRequests
                      parameters:@{@"cmd": kApiItemRequests_remove_conversation,
                                   @"authorId": conversation[@"authorId"]}
                      completion:nil];

    if (_entries.count == 0) {
        [self.navigationItem setRightBarButtonItem:nil];
        [self setEditing:NO animated:NO];
    }
}

#pragma mark - Navigation

- (FLNavigationController *)flNavigationController {
    if (!_flNavigationController) {
        _flNavigationController = [[FLNavigationController alloc] initWithRootViewController:self];
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:FLLocalizedString(@"button_cancel")
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(cancelButtonDidTap:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    return _flNavigationController;
}

- (void)cancelButtonDidTap:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showSideMenu:(UIBarButtonItem *)sender {
    [self.frostedViewController presentMenuViewController];
}

@end
