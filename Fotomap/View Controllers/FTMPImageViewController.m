//
//  FTMPImageViewController.m
//  Fotomap
//
//  Created by Matt Quiros on 4/23/14.
//  Copyright (c) 2014 Action Stack. All rights reserved.
//

#import "FTMPImageViewController.h"

// Frameworks
#import <AssetsLibrary/AssetsLibrary.h>

@interface FTMPImageViewController ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation FTMPImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // Initialize the image view.
    ALAssetRepresentation *assetRepresentation = [self.asset defaultRepresentation];
    CGImageRef imageRef = [assetRepresentation fullResolutionImage];
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:[assetRepresentation scale] orientation:(UIImageOrientation)[assetRepresentation orientation]];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    // Add a tap gesture recognizer to the view to toggle the display of the navigation bar.
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Because self.view's dimensions are ready at this point in the view controller's
    // life cycle, we can now set self.imageView's dimensions to occupy the whole view.
    self.imageView.frame = CGRectMake(0, 0, [self.view width], [self.view height]);
    
    // Add the image view as a subview.
    [self.view addSubview:self.imageView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Hide the navigation bar once the view controller appears.
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - Target actions

- (void)viewWasTapped
{
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

@end
