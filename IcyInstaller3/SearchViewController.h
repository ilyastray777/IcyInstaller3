//
//  SearchViewController.h
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/20/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IcyUniversalMethods.h"
#import "DepictionViewController.h"

@interface SearchViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate>

+ (int)getPackageIndex;
+ (NSMutableArray *)getSearchFilenames;
+ (UITextField *)getSearchField;
+ (UITableView *)getSearchTableView;
@property (strong, nonatomic) NSMutableArray *searchPackages;
@property (strong, nonatomic) NSMutableArray *searchNames;
@property (strong, nonatomic) NSMutableArray *searchDescs;
@property (strong, retain) NSMutableArray *searchDepictions;

@end
