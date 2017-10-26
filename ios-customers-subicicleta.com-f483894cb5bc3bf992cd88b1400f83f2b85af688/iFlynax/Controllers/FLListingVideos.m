//
//  FLListingVideos.m
//  iFlynax
//
//  Created by Alex on 7/17/15.
//  Copyright (c) 2015 Flynax. All rights reserved.
//

#import "FLListingVideos.h"
#import "FLListingVideoCell.h"
#import "FLVideoModel.h"

@interface FLListingVideos () {
    NSArray *_entries;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation FLListingVideos

- (void)awakeFromNib {
    [super awakeFromNib];

    self.title = FLLocalizedString(@"screen_listing_videos");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = FLHexColor(kColorBackgroundColor);
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 15.0f)];
}

- (void)viewDidAppear:(BOOL)animated {
    self.screenName = self.title;
    [super viewDidAppear:animated];
}

#pragma mark - Setters

- (void)setVideos:(NSArray *)videos {
    _videos = videos;

    NSMutableArray *videoModels = [NSMutableArray array];

    [videos enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
        [videoModels addObject:[FLVideoModel fromDictionary:data]];
    }];
    
    _entries = videoModels;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _entries.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 180;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	FLListingVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"adVideoCell"];
    FLVideoModel *video = _entries[indexPath.row];

    [cell loadVideo:video.urlString];

	return cell;
}

@end
