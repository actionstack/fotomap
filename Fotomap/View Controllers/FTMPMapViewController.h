//
//  FTMPMapViewController.h
//  Fotomap
//
//  Created by Matt Quiros on 4/28/14.
//  Copyright (c) 2014 Action Stack. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAsset;

@interface FTMPMapViewController : UIViewController

@property (weak, nonatomic) NSMutableArray *assets;

- (void)addAnnotationForAssetAndRefresh:(ALAsset *)asset;

@end
