//
//  DepictionViewController.h
//  IcyInstaller3
//
//  Created by ArtikusHG on 10/17/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IcyUniversalMethods.h"
#import "PackageInfoViewController.h"
#import "IcyDPKGViewController.h"

@interface DepictionViewController : UIViewController <UIAlertViewDelegate>

- (id)initWithURLString:(NSString *)urlString removeBundleID:(NSString *)removeBundleID downloadURLString:(NSString *)downloadURLString buttonType:(int)buttonType;

@property (nonatomic, retain) UIProgressView *progressView;
@property (strong, nonatomic) IcyUniversalMethods *icyUniversalMethods;

@end
