//
//  SourcesViewController.h
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/20/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <bzlib.h>
#import <sys/utsname.h>


@interface SourcesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void)manage;
@property (strong, nonatomic) UITableView *sourcesTableView;
@property (strong, nonatomic) NSMutableArray *sources;
@property (strong, nonatomic) NSMutableArray *sourceLinks;
@property (strong, nonatomic) NSString *deviceModel;

@end
