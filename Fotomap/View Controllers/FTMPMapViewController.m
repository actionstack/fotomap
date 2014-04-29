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

#pragma mark - Lazy initializers

- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen width], [UIScreen height])];
    }
    return _mapView;
}

@end
