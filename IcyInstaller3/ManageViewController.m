//
//  ManageViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/23/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import "ManageViewController.h"
#import "NSTask.h"

@interface ManageViewController ()

@end

@implementation ManageViewController

UITableView *_manageTableView;
IcyPackageList *_packageList;
UIRefreshControl *refreshControl;
UINavigationBar *manageNavigationBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize view controller and package list
    _packageList = [[IcyPackageList alloc] init];
    // Table view
    _manageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height) style:UITableViewStylePlain];
    _manageTableView.delegate = self;
    _manageTableView.dataSource = self;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) _manageTableView.backgroundColor = [UIColor blackColor];
    [_manageTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _manageTableView.contentInset = UIEdgeInsetsMake(70,0,60,0);
    // Pull-to-refresh stuff
    refreshControl = [[UIRefreshControl alloc] init];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) [refreshControl setTintColor:[UIColor whiteColor]];
    [_manageTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshList) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_manageTableView];
    [self.view bringSubviewToFront:_manageTableView];
    [_manageTableView reloadData];
    // Navbar
    manageNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,64)];
    UINavigationItem *titleNavigationItem = [[UINavigationItem alloc] initWithTitle:@"Installed"];
    UIBarButtonItem *backupButton = [[UIBarButtonItem alloc] initWithTitle:@"Backup" style:UIBarButtonItemStylePlain target:self action:@selector(backup)];
    titleNavigationItem.rightBarButtonItem = backupButton;
    [manageNavigationBar setItems:@[titleNavigationItem]];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        manageNavigationBar.tintColor = [UIColor orangeColor];
        manageNavigationBar.barTintColor = [UIColor blackColor];
        manageNavigationBar.barStyle = UIBarStyleBlack;
        self.view.backgroundColor = [UIColor blackColor];
    }
    [self.view addSubview:manageNavigationBar];
    [self resetFrames];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resetFrames];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self resetFrames];
}

- (void)resetFrames {
    _manageTableView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    manageNavigationBar.frame = CGRectMake(0,0,self.view.bounds.size.width,64);
}

- (void)backup {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Backing up..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Backup.txt"]) [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Backup.txt" error:nil];
        FILE *file = fopen("/var/lib/dpkg/status", "r");
        char str[999];
        while(fgets(str, 999, file) != NULL) {
            if(strstr(str, "Name:")) [[NSString stringWithFormat:@"%@%@", [[NSString stringWithContentsOfFile:@"/var/mobile/Backup.txt" encoding:NSUTF8StringEncoding error:nil] stringByReplacingOccurrencesOfString:@"(null)" withString:@""], [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Name: " withString:@""]] writeToFile:@"/var/mobile/Backup.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        fclose(file);
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        UIAlertView *done = [[UIAlertView alloc] initWithTitle:@"Done" message:@"The backup was saved to /var/mobile/Backup.txt" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [done show];
    });
}

- (void)refreshList {
    [_packageList load];
    [_manageTableView reloadData];
    //[_manageTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
    if([refreshControl isRefreshing]) [refreshControl endRefreshing];
}

+ (UITableView *)getManageTableView {
    return _manageTableView;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return _packageList.packageNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = (UITableViewCell *)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    //if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    //}
    cell.textLabel.text = [_packageList.packageNames objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [_packageList.packageDescs objectAtIndex:indexPath.row];
    UIImage *icon = [UIImage imageWithContentsOfFile:[_packageList.packageIcons objectAtIndex:indexPath.row]];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40,40), NO, [UIScreen mainScreen].scale);
    [icon drawInRect:CGRectMake(0,0,40,40)];
    icon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 10;
    cell.imageView.image = icon;
    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PackageInfoViewController *infoViewController = [[PackageInfoViewController alloc] init];
    if(![PackageInfoViewController getInfoPresent]) [infoViewController packageInfoWithIndexPath:indexPath];
    [self presentViewController:infoViewController animated:YES completion:nil];
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
