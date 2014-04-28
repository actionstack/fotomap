//
//  FTMPScrollViewController.m
//  Fotomap
//
//  Created by Matt Quiros on 4/27/14.
//  Copyright (c) 2014 Action Stack. All rights reserved.
//

#import "FTMPScrollViewController.h"

// View controllers
#import "FTMPImageViewController.h"

@interface FTMPScrollViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) NSUInteger currentIndex;

@end

@implementation FTMPScrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize the page view controller.
    self.pageViewController = [[UIPageViewController alloc]
                               initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                               navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                               options:@{UIPageViewControllerOptionInterPageSpacingKey : @50}];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    // Add the initial page.
    FTMPImageViewController *imageViewController = [[FTMPImageViewController alloc] init];
    imageViewController.asset = self.assets[self.startingIndex];
    imageViewController.assetIndex = self.startingIndex;
    [self.pageViewController setViewControllers:@[imageViewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    // Add the page view controller to the scroll view controller.
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.currentIndex = self.startingIndex;
}

#pragma mark - Page view controller delegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    FTMPImageViewController *imageViewController = (FTMPImageViewController *)viewController;
    NSUInteger nextAssetIndex = imageViewController.assetIndex + 1;
    
    // Only return a view controller if the asset isn't yet at the end of the array.
    
    if (nextAssetIndex + 1 < self.assets.count) {
        FTMPImageViewController *nextViewController = [[FTMPImageViewController alloc] init];
        nextViewController.asset = self.assets[nextAssetIndex];
        nextViewController.assetIndex = nextAssetIndex;
        return nextViewController;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    FTMPImageViewController *imageViewController = (FTMPImageViewController *)viewController;
    NSUInteger previousAssetIndex = imageViewController.assetIndex - 1;
    
    // Only return a view controller if the asset isn't yet at the start of the array.
    
    if (previousAssetIndex + 1 > 0) {
        FTMPImageViewController *previousViewController = [[FTMPImageViewController alloc] init];
        previousViewController.asset = self.assets[previousAssetIndex];
        previousViewController.assetIndex = previousAssetIndex;
        return previousViewController;
    }
    
    return nil;
}

@end
