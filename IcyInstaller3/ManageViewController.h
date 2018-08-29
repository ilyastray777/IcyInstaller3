//
//  ManageViewController.h
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/23/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IcyPackageList.h"
#import "ViewController.h"

@interface ManageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

+ (void)dismissInfo;
+ (UITableView *)getManageTableView;
- (void)removePackageButtonAction;
- (void)removePackageWithBundleID:(NSString *)bundleID;

@end
