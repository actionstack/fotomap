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

@interface FTMPHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray *assets;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UILabel *errorLabel;

@end

@implementation FTMPHomeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If the assets array is nil, then it is not yet initialized.
    // Initialize by enumerating all the photos in the device.
    if (self.assets == nil) {
        [self.activityIndicator startAnimating];
        [self.activityIndicator centerFrameInParent:self.view];
        [self.view addSubview:self.activityIndicator];
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        __weak FTMPHomeViewController *weakSelf = self;
        
        [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            // Create an enumeration filter to get only the photos from the assets group.
            ALAssetsFilter *photosOnlyFilter = [ALAssetsFilter allPhotos];
            [group setAssetsFilter:photosOnlyFilter];
            
            // Don't bother enumerating assets for groups with zero assets.
            if ([group numberOfAssets] > 0) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    // Create block-level strong reference to self.
                    FTMPHomeViewController *innerSelf = weakSelf;
                    
                    if (result) {
                        [innerSelf.assets addObject:result];
                    }
                    
                    NSLog(@"Group: %@ index: %d", group, index);
                    if (index == [group numberOfAssets] - 1) {
                        // Stop the loading animation and remove it.
                        [innerSelf.activityIndicator stopAnimating];
                        [innerSelf.activityIndicator removeFromSuperview];
                        
                        // Add the collection view to the view.
                        [innerSelf.view addSubview:innerSelf.collectionView];
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

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.assets count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UICollectionViewCell alloc] init];
}

#pragma mark - Collection view delegate

#pragma mark - Collection view flow layout

#pragma mark - Lazy initializers

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        CGRect frame = CGRectMake(0, 0, [UIScreen width], [UIScreen height]);
        _collectionView = [[UICollectionView alloc] initWithFrame:frame
                                             collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {;
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