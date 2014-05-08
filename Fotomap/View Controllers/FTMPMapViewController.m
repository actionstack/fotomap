//
//  FTMPMapViewController.m
//  Fotomap
//
//  Created by Matt Quiros on 4/28/14.
//  Copyright (c) 2014 Action Stack. All rights reserved.
//

#import "FTMPMapViewController.h"

// Frameworks
#import <MapKit/MapKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

// App delegate
#import "FTMPAppDelegate.h"

@interface FTMPMapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *points;

@end

@implementation FTMPMapViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add the map view as a subview if it hasn't been added yet.
    if (![self.view.subviews containsObject:self.mapView]) {
        [self.view addSubview:self.mapView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Only enumerate the points if they haven't been yet.
    if (self.points == nil) {
        self.points = [NSMutableArray array];
        
        ALAsset *asset;
        CLLocation *location;
        for (int i = 0; i < self.assets.count; i++) {
            asset = self.assets[i];
            location = [asset valueForProperty:ALAssetPropertyLocation];
            
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = location.coordinate;
            [self.points addObject:point];
        }
        
        [self.mapView addAnnotations:[NSArray arrayWithArray:self.points]];
    }
}

- (void)addAnnotationForAssetAndRefresh:(ALAsset *)asset
{
    FTMPAppDelegate *appDelegate = (FTMPAppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocation *location = appDelegate.location;
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = location.coordinate;
    
    [self.points addObject:point];
    [self.mapView addAnnotation:point];
}

#pragma mark - Map view delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // Get the asset for which this annotation is a pin.
    NSUInteger indexOfAnnotation = [self.points indexOfObject:annotation];
    ALAsset *asset = self.assets[indexOfAnnotation];
    
    // Use the asset's thumbnail as the view's image.
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
    view.image = [UIImage imageWithCGImage:[asset thumbnail]];
    
    // Make the annotation view 60 points by 60.
    view.frame = CGRectMake(0, 0, 60, 60);
    
    return view;
}

#pragma mark - Lazy initializers

- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen width], [UIScreen height])];
        _mapView.delegate = self;
    }
    return _mapView;
}

@end
