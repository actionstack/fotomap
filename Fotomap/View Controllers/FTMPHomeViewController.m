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

@interface FTMPHomeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) ALAssetsLibrary *library;
@property (strong, nonatomic) NSMutableArray *assets;

@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;

@property (weak, nonatomic) FTMPTileViewController *tileViewController;
@property (weak, nonatomic) FTMPMapViewController *mapViewController;

@end

@implementation FTMPHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the screen title.
    self.title = @"Fotomap";
    
    // Initialize an ALAssetsLibrary instance.
    self.library = [[ALAssetsLibrary alloc] init];
    
    // Add a camera button in the navigation bar.
    UIBarButtonItem *cameraBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonTapped)];
    self.navigationItem.rightBarButtonItem = cameraBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If the assets array is nil, then it is not yet initialized.
    // Initialize by enumerating all the photos in the device.
    if (self.assets == nil) {
        // While loading, put an activity indicator in the center of the screen.
        [self.activityIndicator startAnimating];
        [self.activityIndicator centerFrameInParent:self.view];
        [self.view addSubview:self.activityIndicator];
        
        __weak FTMPHomeViewController *weakSelf = self;
        
        [self enumeratePhotoAssetsWithSuccessBlock:^{
            // Create block-level strong reference to self.
            FTMPHomeViewController *innerSelf = weakSelf;
            
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
            
            // Assign the pointers to the tile and map view controllers.
            innerSelf.tileViewController = tileViewController;
            innerSelf.mapViewController = mapViewController;
            
            // Add a toolbar at the bottom to toggle between tile and map view.
            UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [UIScreen height] - 44, [UIScreen width], 44)];
            [toolbar addSubview:innerSelf.segmentedControl];
            [innerSelf.view addSubview:toolbar];
        } failureBlock:^{
            FTMPHomeViewController *innerSelf = weakSelf;
            [innerSelf.errorLabel centerFrameInParent:innerSelf.view];
            [innerSelf.view addSubview:innerSelf.errorLabel];
        }];
    }
}

- (void)enumeratePhotoAssetsWithSuccessBlock:(void (^)())successBlock failureBlock:(void (^)())failureBlock
{
    self.assets = [NSMutableArray array];
    
    __weak FTMPHomeViewController *weakSelf = self;
    
    [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        FTMPHomeViewController *innerSelf = weakSelf;
        
        // The group is nil if enumeration is completed.
        if (group == nil) {
            // If the final count for the assets is zero, consider it a failure.
            if (innerSelf.assets.count == 0) {
                failureBlock();
            } else {
                // Execute the provided success block.
                successBlock();
            }
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
        // Set the assets array to nil again to make sure it is marked as uninitialized.
        FTMPHomeViewController *innerSelf = weakSelf;
        innerSelf.assets = nil;
        
        // Display a dialog containing the error.
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        // Execute the provided failure block.
        failureBlock();
    }];
}

#pragma mark - Target actions

- (void)segmentedControlChanged
{
    self.tabBarController.selectedIndex = self.segmentedControl.selectedSegmentIndex;
}

- (void)cameraButtonTapped
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - Image picker controller delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Dismiss the image picker.
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // Save the image in the photo library.
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    __weak FTMPHomeViewController *weakSelf = self;
    
    [self.library writeImageToSavedPhotosAlbum:image.CGImage metadata:info[UIImagePickerControllerMediaMetadata] completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        FTMPHomeViewController *innerSelf = weakSelf;
        [innerSelf.library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            // Add the new ALAsset object to the assets array.
            [innerSelf.assets addObject:asset];
            
            // To refresh the tile view controller, simply call reloadData on its collectionView.
            // Because it holds a pointer to the same array, the above addition to the assets array
            // will be reflected when the collection view is reloaded.
            [innerSelf.tileViewController.collectionView reloadData];
            
            // To refresh the map view, we call on addAnnotationForAsset:.
            // While the map view also points to the same array of assets, its annotations are
            // based on a separate array called "points."
            [innerSelf.mapViewController addAnnotationForAssetAndRefresh:asset];
        } failureBlock:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    }];
    
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
//{
//    if (error) {

//    }
//    
//    // If no error happened, just re-enumerate the assets and refresh the tile and map view controllers.
//    
//    __weak FTMPHomeViewController *weakSelf = self;
//    [self enumeratePhotoAssetsWithSuccessBlock:^{
//        FTMPHomeViewController *innerSelf = weakSelf;
//        
//        // Re-assign the assets arrays of every view controller before refreshing them
//        // so that the data sources are updated.
//        
//        innerSelf.tileViewController.assets = innerSelf.assets;
//        [innerSelf.tileViewController refresh];
//        
//        innerSelf.mapViewController.assets = innerSelf.assets;
//        [innerSelf.mapViewController refresh];
//    } failureBlock:nil];
//}

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