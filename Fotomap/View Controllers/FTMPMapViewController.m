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

@interface FTMPMapViewController ()

@property (strong, nonatomic) MKMapView *mapView;

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

#pragma mark - Lazy initializers

- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen width], [UIScreen height])];
    }
    return _mapView;
}

@end
