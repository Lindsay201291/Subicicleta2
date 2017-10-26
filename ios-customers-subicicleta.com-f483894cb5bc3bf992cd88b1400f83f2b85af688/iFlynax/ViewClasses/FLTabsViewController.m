//
//  FLTabsViewController.m
//  iFlynax
//
//  Created by Alex on 12/10/14.
//  Copyright (c) 2014 Flynax. All rights reserved.
//

#import "FLTabsViewController.h"

@interface FLTabsViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic) BOOL swipeBackEnabled;
@end

@implementation FLTabsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.view.backgroundColor = FLHexColor(kColorBackgroundColor);
	self.contentView.backgroundColor = self.view.backgroundColor;

    [self prepareTabsControll];
}

- (void)prepareTabsControll {
    // init PageViewController
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    CGSize contentSize = _contentView.frame.size;
    _pageViewController.view.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    [_pageViewController setDataSource:self];
    [_pageViewController setDelegate:self];
    [_pageViewController.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    
    [self addChildViewController:_pageViewController];
    [_contentView addSubview:_pageViewController.view];
    
    // setup Tabs control
    [_tabsControl addTarget:self
                     action:@selector(tabsControlValueChanged:)
           forControlEvents:UIControlEventValueChanged];

    _tabsControl.backgroundColor              = [UIColor hexColor:kColorTabsBackground];
    _tabsControl.selectionIndicatorColor      = [UIColor hexColor:kColorTabsSelectionIndicator];
    _tabsControl.selectionIndicatorLocation   = HMSegmentedControlSelectionIndicatorLocationNone;
    _tabsControl.segmentWidthStyle            = HMSegmentedControlSegmentWidthStyleFixed;
    _tabsControl.selectionStyle               = HMSegmentedControlSelectionStyleBox;
    _tabsControl.selectionIndicatorBoxOpacity = 1.0f;

    _tabsControl.selectedTitleTextAttributes  = @{NSForegroundColorAttributeName:[UIColor hexColor:kColorTabsSelectedText]};
    _tabsControl.titleTextAttributes          = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:kTabsTextFontSize],
                                                  NSForegroundColorAttributeName:[UIColor hexColor:kColorTabsText]};
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    if (_pages.count > 0) {
        [self setSelectedPageIndex:_tabsControl.selectedSegmentIndex animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated {
	self.screenName = _gaScreenName;
	[super viewDidAppear:animated];
    self.swipeBackEnabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.swipeBackEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Getters

- (NSMutableArray *)tabsControlTitles {
    if (!_tabsControlTitles) {
		_tabsControlTitles = [NSMutableArray new];
    }
	return _tabsControlTitles;
}

- (NSMutableArray *)pages {
    if (!_pages) {
		_pages = [NSMutableArray new];
    }
	return _pages;
}

#pragma mark - Setters

- (void)setSwipeBackEnabled:(BOOL)swipeBackEnabled {
    _swipeBackEnabled = swipeBackEnabled;

    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = _swipeBackEnabled ? self : nil;
    }
}

#pragma mark - Helpers

- (void)addTabViewController:(UIViewController *)controller {
    [self addTabViewController:controller withTitle:nil];
}

- (void)addTabViewController:(UIViewController *)controller withTitle:(NSString *)title {
    [self.pages addObject:controller];
    [self.tabsControlTitles addObject:FLCleanString(title ?: controller.title.uppercaseString)];
}

- (void)appendTabsAndDisplaySelected {
    if (IS_RTL) {
        _tabsControl.selectedSegmentIndex = MAX(0, self.pages.count-1);
    }
    [self appendTabsAndDisplaySelected:_tabsControl.selectedSegmentIndex];
}

- (void)reverceTabsIfNecessary {
    if (IS_RTL) {
        self.pages = [[[self.pages reverseObjectEnumerator] allObjects] mutableCopy];
        self.tabsControlTitles = [[[self.tabsControlTitles reverseObjectEnumerator] allObjects] mutableCopy];
    }
}

- (void)appendTabsAndDisplaySelected:(NSInteger)index {
    [self reverceTabsIfNecessary];
    [self setSelectedPageIndex:index animated:NO];
    [self.tabsControl setSectionTitles:self.tabsControlTitles];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return _swipeBackEnabled;
}

- (void)setupPagesFromStoryboardWithIdentifiers:(NSArray *)identifiers {
	[self setupPagesFromStoryboardWithIdentifiers:identifiers configure:nil];
}

- (void)setupPagesFromStoryboardWithIdentifiers:(NSArray *)identifiers
									  configure:(FLTabsConfigureBlock)configureBlock {
	if (self.storyboard) {
		[identifiers enumerateObjectsUsingBlock:^(id expectedEdentifier, NSUInteger idx, BOOL *stop) {
            NSString *identifier = @""; //TODO: put some default controller as blankslate

            if ([expectedEdentifier isKindOfClass:NSString.class]) {
                identifier = expectedEdentifier;
            }
            else if ([expectedEdentifier isKindOfClass:NSDictionary.class]) {
                if (expectedEdentifier[kTabsIdentifierKey] != nil) {
                    identifier = FLCleanString(expectedEdentifier[kTabsIdentifierKey]);
                }
            }

			UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];

            if (configureBlock != nil) {
				configureBlock(viewController, idx, identifier);
            }

			if (viewController != nil) {
				[self.pages addObject:viewController];

				// collect tab title's
				NSString *tabTitle = viewController.title ?: identifier;
				[self.tabsControlTitles addObject:[tabTitle uppercaseString]];
			}
		}];
        [self appendTabsAndDisplaySelected];
	}
}

- (void)setSelectedPageIndex:(NSUInteger)index animated:(BOOL)animated {
	if (index < _pages.count) {
		[_tabsControl setSelectedSegmentIndex:index animated:animated];

        UIPageViewControllerNavigationDirection _direction = IS_RTL
        ? UIPageViewControllerNavigationDirectionReverse
        : UIPageViewControllerNavigationDirectionForward;

		[_pageViewController setViewControllers:@[_pages[index]]
									  direction:_direction
									   animated:animated
									 completion:nil];
	}
}

- (UIViewController *)selectedController {
	return _pages[_tabsControl.selectedSegmentIndex];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    return [self fetchPageVC:viewController after:NO];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    return [self fetchPageVC:viewController after:YES];
}

- (void)pageViewController:(UIPageViewController *)pageViewController
		didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers
	   transitionCompleted:(BOOL)completed {

	if (!completed)
		return;

	[_tabsControl setSelectedSegmentIndex:[_pages indexOfObject:[pageViewController.viewControllers lastObject]] animated:YES];
}

#pragma mark - helpers

- (UIViewController *)fetchPageVC:(UIViewController *)vc after:(BOOL)after {
    NSUInteger index = [_pages indexOfObject:vc];

    if (after) {
        if (IS_RTL) {
            if (index == NSNotFound || index == 0)
                return nil;
            index--;
        }
        else {
            if (index == NSNotFound || index + 1 >= _pages.count)
                return nil;
            index++;
        }
    }
    else {
        if (IS_RTL) {
            if (index == NSNotFound || index + 1 >= _pages.count)
                return nil;
            index++;
        }
        else {
            if (index == NSNotFound || index == 0)
                return nil;
            index--;
        }
    }
    return _pages[index];
}

#pragma mark - Callback

- (void)tabsControlValueChanged:(HMSegmentedControl *)control {
	if (!_pages.count)
		return;

    NSUInteger selectedPageIndex = [_pages indexOfObject:[_pageViewController.viewControllers lastObject]];
	BOOL diff_index = (_tabsControl.selectedSegmentIndex > selectedPageIndex);

	UIPageViewControllerNavigationDirection direction = diff_index
    ? UIPageViewControllerNavigationDirectionForward
    : UIPageViewControllerNavigationDirectionReverse;

	// scroll the page view controller
	[self.pageViewController setViewControllers:@[[self selectedController]]
                                      direction:direction animated:YES completion:nil];
}

@end
