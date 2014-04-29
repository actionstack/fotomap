//
//  FTMPHomeViewController.m
//  Fotomap
//
//  Created by Matt Quiros on 4/21/14.
//  Copyright (c) 2014 Action Stack. All rights reserved.
//

#import "FTMPHomeViewController.h"

// Frameworks
#import <AssetsLibrary/AssetsLibrary.h>

// View controllers
#import "FTMPTileViewController.h"
#import "FTMPMapViewController.h"

@interface FTMPHomeViewController ()

@property (strong, nonatomic) ALAssetsLibrary *library;
@property (strong, nonatomic) NSMutableArray *assets;

@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;

@end

@implementation FTMPHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the screen title.
    self.title = @"Fotomap";
    
    // Initialize an ALAssetsLibrary instance.
    self.library = [[ALAssetsLibrary alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If the assets array is nil, then it is not yet initialized.
    // Initialize by enumerating all the photos in the device.
    if (self.assets == nil) {
        self.assets = [NSMutableArray array];
        
        [self.activityIndicator startAnimating];
        [self.activityIndicator centerFrameInParent:self.view];
        [self.view addSubview:self.activityIndicator];
        
        __weak FTMPHomeViewController *weakSelf = self;
        
        [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            // Create block-level strong reference to self.
            FTMPHomeViewController *innerSelf = weakSelf;
            
            // The group is nil if enumeration is completed.
            if (group == nil) {
                // Stop the loading animation and remove it.
                [innerSelf.activityIndicator stopAnimating];
                [innerSelf.activityIndicator removeFromSuperview];
                
                // Set up the tab bar controller.
                FTMPTileViewController *tileViewController = [[FTMPTileViewController alloc] init];
                tileViewController.assets = innerSelf.assets;
                
                FTMPMapViewController *mapViewController = [[FTMPMapViewController alloc] init];
                mapViewController.assets = innerSelf.assets;
                
                innerSelf.tabBarController = [[UITabBarController alloc] init];
                innerSelf.tabBarController.tabBar.hidden = YES;
                innerSelf.tabBarController.viewControllers = @[tileViewController, mapViewController];
                
                // Add the tab bar controller to the view.
                [innerSelf addChildViewController:innerSelf.tabBarController];
                [innerSelf.view addSubview:innerSelf.tabBarController.view];
                [innerSelf.tabBarController didMoveToParentViewController:innerSelf];
                
                UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [UIScreen height] - 44, [UIScreen width], 44)];
                [toolbar addSubview:innerSelf.segmentedControl];
                [innerSelf.view addSubview:toolbar];
                return;
            }
            
            // Create an enumeration filter to get only the photos from the assets group.
            ALAssetsFilter *photosOnlyFilter = [ALAssetsFilter allPhotos];
            [group setAssetsFilter:photosOnlyFilter];
            
            // Don't bother enumerating assets for groups with zero assets.
            if ([group numberOfAssets] > 0) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        [innerSelf.assets addObject:result];
                    }
                }];
            }
        } failureBlock:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            
            FTMPHomeViewController *innerSelf = weakSelf;
            [innerSelf.errorLabel centerFrameInParent:innerSelf.view];
            [innerSelf.view addSubview:innerSelf.errorLabel];
        }];
    }
    
    else {
        
    }
}

#pragma mark - Target actions

- (void)segmentedControlChanged
{
    self.tabBarController.selectedIndex = self.segmentedControl.selectedSegmentIndex;
}

#pragma mark - Lazy initializers

- (UISegmentedControl *)segmentedControl
{
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Tile", @"Map"]];
        _segmentedControl.frame = CGRectMake(20, 7, [UIScreen width] - 40, 30);
        
        // Select the first segment by default.
        _segmentedControl.selectedSegmentIndex = 0;
        
        // Set which method gets invoked when the segmented control changes selection.
        [_segmentedControl addTarget:self action:@selector(segmentedControlChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activityIndicator;
}

- (UILabel *)errorLabel
{
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.text = @"Can't find photos to load.";
        
        // Set the label's dimensions to fit its text content.
        [_errorLabel sizeToFit];
    }
    return _errorLabel;
}

@end