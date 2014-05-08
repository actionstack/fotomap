//
//  FTMPAppDelegate.h
//  Fotomap
//
//  Created by Matt Quiros on 4/21/14.
//  Copyright (c) 2014 Action Stack. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLLocation;

@interface FTMPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocation *location;

@end
