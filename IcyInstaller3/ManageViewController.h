//
//  ManageViewController.h
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/23/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IcyPackageList.h"
#import "PackageInfoViewController.h"

@interface ManageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

+ (UITableView *)getManageTableView;
- (void)refreshList;

@end
