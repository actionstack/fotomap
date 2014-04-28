//
//  FTMPTileViewController.m
//  Fotomap
//
//  Created by Matt Quiros on 4/28/14.
//  Copyright (c) 2014 Action Stack. All rights reserved.
//

#import "FTMPTileViewController.h"

// View controllers
#import "FTMPScrollViewController.h"

// Frameworks
#import <AssetsLibrary/AssetsLibrary.h>

static NSString * const kCellIdentifier = @"Cell";

@interface FTMPTileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation FTMPTileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register a collection view cell class and an identifier.
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    
    // Set which edges to extend for the translucent top and bottom bars.
    self.edgesForExtendedLayout = UIRectEdgeTop|UIRectEdgeBottom;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.view.subviews containsObject:self.collectionView]) {
        [self.view addSubview:self.collectionView];
    }
}

- (void)viewDidLayoutSubviews
{
    // Set a content inset so that the cells aren't hidden
    // under the status bar and navigation bar.
    self.collectionView.contentInset = UIEdgeInsetsMake(self.tabBarController.topLayoutGuide.length, 0, 44, 0);
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Instantiate the next screen.
    FTMPScrollViewController *scrollViewController = [[FTMPScrollViewController alloc] init];
    scrollViewController.assets = self.assets;
    scrollViewController.startingIndex = indexPath.row;
    
    [self.navigationController pushViewController:scrollViewController animated:YES];
}

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
        
        // A collection view's default background is black, so let's change it.
        _collectionView.backgroundColor = [UIColor lightGrayColor];
    }
    return _collectionView;
}

@end
