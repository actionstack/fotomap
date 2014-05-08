//
//  FTMPAppDelegate.m
//  Fotomap
//
//  Created by Matt Quiros on 4/21/14.
//  Copyright (c) 2014 Action Stack. All rights reserved.
//

#import "FTMPAppDelegate.h"

// View Controllers
#import "FTMPHomeViewController.h"

// Frameworks
#import <CoreLocation/CoreLocation.h>

@interface FTMPAppDelegate () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation FTMPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    FTMPHomeViewController *homeViewController = [[FTMPHomeViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
    self.window.rootViewController = navigationController;
    
    // Set up the location manager.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 1000;
    [self.locationManager startMonitoringSignificantLocationChanges];
    
//    if ([CLLocationManager locationServicesEnabled]) {
//        switch ([CLLocationManager authorizationStatus]) {
//            case kCLAuthorizationStatusNotDetermined: {
//                break;
//            }
//            case kCLAuthorizationStatusAuthorized: {
//                [self.locationManager startMonitoringSignificantLocationChanges];
//                break;
//            }
//            case kCLAuthorizationStatusDenied: {
//                // Tell the user that Location Services may be enables in Settings.
//                break;
//            }
//            case kCLAuthorizationStatusRestricted: {
//                // Tell the user that there's absolutely no way to show the location
//                // of the photos taken from inside this app.
//                break;
//            }
//        }
//    } else {
//        // Prompt the user to Enable Location Services in Settings.
//    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

#pragma mark - Core location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // When we get a location update, just save it in the property.
    self.location = [locations firstObject];
}

@end
