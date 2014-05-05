//
//  FTMPTileViewController.h
//  Fotomap
//
//  Created by Matt Quiros on 4/28/14.
//  Copyright (c) 2014 Action Stack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTMPTileViewController : UIViewController

@property (weak, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic, readonly) UICollectionView *collectionView;

@end
