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

static NSString * const kCellIdentifier = @"Cell";

@interface FTMPHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) ALAssetsLibrary *library;
@property (strong, nonatomic) NSMutableArray *assets;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UILabel *errorLabel;

@end

@implementation FTMPHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.library = [[ALAssetsLibrary alloc] init];
    
    // Register a collection view cell class and an identifier.
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    
    // Set a content inset of 64 so that the cells aren't hidden under
    // the status bar (20) and the navigation bar (44);
    self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
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
        
        [self.library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            // Create block-level strong reference to self.
            FTMPHomeViewController *innerSelf = weakSelf;
            
            // The group is nil if enumeration is completed.
            if (group == nil) {
                // Stop the loading animation and remove it.
                [innerSelf.activityIndicator stopAnimating];
                [innerSelf.activityIndicator removeFromSuperview];
                
                // Add the collection view to the view.
                [innerSelf.view addSubview:innerSelf.collectionView];
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

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger count = [self.assets count];
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    // Get a reference to the asset at this index path.
    ALAsset *asset = self.assets[indexPath.row];
    
    // Get the UIImageView in the cell.
    static NSInteger kImageViewTag = 1000;
    UIImageView *thumbnailImageView = (UIImageView *)[cell viewWithTag:kImageViewTag];
    
    // If the cell has no UIImageView subview yet, initialize one and add it to the cell.
    if (thumbnailImageView == nil) {
        thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [cell width], [cell height])];
        
        // Set the subview's tag so that it is identifiable later.
        thumbnailImageView.tag = kImageViewTag;
        
        // Scale the image so that it fills the cell.
        thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        // Clip the image if it is beyond the image view's dimensions.
        thumbnailImageView.clipsToBounds = YES;
        
        [cell addSubview:thumbnailImageView];
    }
    
    // Set the thumbnail image.
    CGImageRef thumbnail = [asset thumbnail];
    UIImage *image = [UIImage imageWithCGImage:thumbnail];
    thumbnailImageView.image = image;
    
    return cell;
}

#pragma mark - Collection view delegate

#pragma mark - Collection view flow layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(106, 106);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1, 0, 1, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

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