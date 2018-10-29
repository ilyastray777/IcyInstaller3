//
//  PackageInfoViewController.h
//  IcyInstaller3
//
//  Created by ArtikusHG on 10/16/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IcyPackageList.h"
#import "IcyUniversalMethods.h"

@interface PackageInfoViewController : UIViewController

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

// Properties

@property (nonatomic) int removeIndex;
@property (strong,nonatomic) UIView *infoView;
@property (strong,nonatomic) UITextView *infoText;
@property (strong,nonatomic) IcyPackageList *packageList;
@property (strong,nonatomic) IcyUniversalMethods *icyUniversalMethods;

// Methods

- (void)removePackageWithBundleID:(NSString *)bundleID;
- (void)packageInfoWithIndexPath:(NSIndexPath *)indexPath;
+ (BOOL)getInfoPresent;

@end
