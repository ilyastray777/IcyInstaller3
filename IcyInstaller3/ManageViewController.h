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

- (void)removePackageButtonAction;
- (void)removePackageWithBundleID:(NSString *)bundleID;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) IcyPackageList *packageList;
@property (strong, nonatomic) UIWebView *packageWebView;
@property (strong, nonatomic) UITableView *manageTableView;

@end
