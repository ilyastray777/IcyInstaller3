//
//  ViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 2/8/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//
#include <spawn.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <netdb.h>
#include "NSTask.h"
#import <dlfcn.h>
#import <sys/utsname.h>
#import "ViewController.h"
#import "HomeViewController.h"
#import "SourcesViewController.h"
#import "SearchViewController.h"
#import "ManageViewController.h"

@interface ViewController ()
// View Controllers
@property (strong, nonatomic) HomeViewController *homeViewController;
@property (strong, nonatomic) SourcesViewController *sourcesViewController;
@property (strong, nonatomic) SearchViewController *searchViewController;
@property (strong, nonatomic) ManageViewController *manageViewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Get device model and UDID
    struct utsname systemInfo;
    uname(&systemInfo);
    [[NSUserDefaults standardUserDefaults] setObject:[self uniqueDeviceID] forKey:@"udid"];
    _deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    // Get arrays needed for reload
    _oldApplications = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Applications/" error:nil].count;
    _oldTweaks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/MobileSubstrate/DynamicLibraries/" error:nil].count;
    // Get value of darkMode
    // Stuff for downloading with progress
    self.downloadedMutableData = [[NSMutableData alloc] init];
    // The navbar
    _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        _navigationBar.barTintColor = [UIColor blackColor];
        _navigationBar.backgroundColor = [UIColor blackColor];
    } else {
        _navigationBar.barTintColor = [UIColor whiteColor];
        _navigationBar.backgroundColor = [UIColor whiteColor];
    }
    [self.view addSubview:_navigationBar];
    // The button at the right
    _aboutButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,75,30)];
    _aboutButton.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) [_aboutButton setTitle:@"Light" forState:UIControlStateNormal];
    else [_aboutButton setTitle:@"Dark" forState:UIControlStateNormal];
    _aboutButton.titleLabel.textColor = coolerBlueColor;
    [_aboutButton addTarget:self action:@selector(about) forControlEvents:UIControlEventTouchUpInside];
    [self makeViewRound:_aboutButton withRadius:5];
    UIView *aboutButtonView = [[UIView alloc] initWithFrame:_aboutButton.bounds];
    aboutButtonView.bounds = CGRectOffset(_aboutButton.bounds, 0, 6);
    [aboutButtonView addSubview:_aboutButton];
    _rightItem = [[UIBarButtonItem alloc] initWithCustomView:aboutButtonView];
    UINavigationItem *right = [[UINavigationItem alloc] initWithTitle:@""];
    right.rightBarButtonItem = _rightItem;
    [_navigationBar setItems:@[right]];
    // The top label
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,50,[UIScreen mainScreen].bounds.size.width - 130,40)];
    _nameLabel.backgroundColor = [UIColor clearColor];
    [_nameLabel setFont:[UIFont boldSystemFontOfSize:30]];
    _nameLabel.text = @"Icy Installer";
    [_navigationBar addSubview:_nameLabel];
    // The less top but still top label
    _dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,30,[UIScreen mainScreen].bounds.size.width,20)];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth fromDate:[NSDate date]];
    NSArray *weekdays = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    NSArray *months = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
    _dateLabel.text = [[NSString stringWithFormat:@"%@, %@ %zd",[weekdays objectAtIndex:[components weekday] - 1],[months objectAtIndex:[components month] - 1],(long)[components day]] uppercaseString];
    _dateLabel.textColor = [UIColor grayColor];
    [_dateLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [_navigationBar addSubview:_dateLabel];
    // The tabbar
    _tabbar = [[UITabBar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 49, [UIScreen mainScreen].bounds.size.width, 50)];
    _tabbar.delegate = self;
    NSMutableArray *tabBarItems = [[NSMutableArray alloc] initWithArray:@[[[UITabBarItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@"icons/Home.png"] tag:0], [[UITabBarItem alloc] initWithTitle:@"Sources" image:[UIImage imageNamed:@"icons/Sources.png"] tag:1], [[UITabBarItem alloc] initWithTitle:@"Installed" image:[UIImage imageNamed:@"icons/Installed.png"] tag:2], [[UITabBarItem alloc] initWithTitle:@"Search" image:[UIImage imageNamed:@"icons/Search.png"] tag:3]]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10]} forState:UIControlStateNormal];
    _tabbar.items = tabBarItems;
    _tabbar.selectedItem = [tabBarItems objectAtIndex:0];
    [self.view addSubview:_tabbar];
    // View Controllers
    _homeViewController = [[HomeViewController alloc] init];
    _sourcesViewController = [[SourcesViewController alloc] init];
    _searchViewController = [[SearchViewController alloc] init];
    _manageViewController = [[ManageViewController alloc] init];
    [self.view addSubview:_homeViewController.view];
    [self.view addSubview:_sourcesViewController.view];
    [self.view addSubview:_searchViewController.view];
    [self.view addSubview:_manageViewController.view];
    _homeViewController.view.hidden = YES;
    _sourcesViewController.view.hidden = YES;
    _searchViewController.view.hidden = YES;
    _manageViewController.view.hidden = YES;
    // Fixup current views
    [self.view bringSubviewToFront:_tabbar];
    [self.view bringSubviewToFront:_navigationBar];
    // Progress View
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.frame = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,10);
    _progressView.progress = 0;
    [self.view addSubview:_progressView];
    //if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) [self switchToDarkMode];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self loadStuff];
    });
}

#pragma mark - Loading methods

- (void)loadStuff {
    // ---- DEPENDENCIES ARTIKUS SEE IT'S HERE NOT SOMEWHERE ELSE IDIOT ---- //
    /*NSMutableArray *packageDependencies = [[NSMutableArray alloc] initWithArray:[[self runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze"] withArguments:@[@"-f", @"/var/mobile/deb.deb", @"Depends"] errors:NO] componentsSeparatedByString:@", "]];
    NSMutableArray *missingDependencies = [[NSMutableArray alloc] init];
    [self messageWithTitle:@"Dependencies" message:[NSString stringWithFormat:@"%@",packageDependencies]];
    for (id object in packageDependencies) {
        object = [object stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *noSpace = object;
        if([object rangeOfString:@" "].location != NSNotFound) noSpace = [[object substringToIndex:[object rangeOfString:@" "].location] stringByReplacingOccurrencesOfString:@" " withString:@""];
        if([object isEqualToString:noSpace] && ![self isPackageInstalled:object]) [missingDependencies addObject:object];
        if(![object isEqualToString:noSpace] && ![self isPackageInstalled:noSpace]) {
            NSString *version = [object substringFromIndex:[object rangeOfString:@"("].location];
            NSString *compare = [NSString stringWithFormat:@"%@ %@",[[UIDevice currentDevice] systemVersion],[[version stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""]];
            if([noSpace isEqualToString:@"firmware"] && [self returnOfCommand:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze"] withArguments:@[@"--compare-versions", compare]] != 0) [self messageWithTitle:@"Error" message:@"This package requires a newer or older version of iOS."];
            else if(![noSpace isEqualToString:@"firmware"] && [self returnOfCommand:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze"] withArguments:@[@"--compare-versions", compare]] != 0) [missingDependencies addObject:noSpace];
        }
    }
    [self messageWithTitle:@"Missing dependencies" message:[NSString stringWithFormat:@"%@",missingDependencies]];*/
    // ---- END OF DEPENDENCIES ARTIKUS AGAIN THE END IS HERE NOT SOME OTHER WHERE ELSE ---- //
    // Check for needed directories
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy" isDirectory:nil]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy" withIntermediateDirectories:NO attributes:nil error:nil];
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/Repos" isDirectory:nil]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" withIntermediateDirectories:NO attributes:nil error:nil];
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/sources.list" isDirectory:nil]) [[NSFileManager defaultManager] createFileAtPath:@"/var/mobile/Media/Icy/sources.list" contents:nil attributes:nil];
    // Get third party source list
    if([[[NSFileManager defaultManager] attributesOfItemAtPath:@"/var/mobile/Media/Icy/sources.list" error:nil] fileSize] >= 11) {
        NSString *sources = [NSString stringWithContentsOfFile:@"/var/mobile/Media/Icy/sources.list" encoding:NSUTF8StringEncoding error:nil];
        sources = [sources substringToIndex:sources.length - 1];
        // 11 - shortest link that can ever exist: http://a.co, if it's less that this - it's not a valid sources.list file
        _sourcesViewController.sourceLinks = [[NSMutableArray alloc] initWithArray:[sources componentsSeparatedByString:@"\n"]];
    }
    _sourcesViewController.sources = [[NSMutableArray alloc] init];
    for(id object in [[NSUserDefaults standardUserDefaults] objectForKey:@"sourceNames"]) [_sourcesViewController.sources addObject:object];
    BOOL isDirectory;
    // Check for needed directories
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy" isDirectory:&isDirectory]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy" withIntermediateDirectories:NO attributes:nil error:nil];
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/Repos" isDirectory:&isDirectory]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" withIntermediateDirectories:NO attributes:nil error:nil];
    // Redirect log to a file
    freopen([@"/var/mobile/Media/Icy/log.txt" cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    [_manageViewController.manageTableView reloadData];
    [_sourcesViewController.sourcesTableView reloadData];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) [[[HomeViewController alloc] init].welcomeWebView stringByEvaluatingJavaScriptFromString:@"document.body.style.background = 'black'; var p = document.getElementsByTagName('p'); for (var i = 0; i < p.length; i++) { p[i].style.color = 'white'; }"];
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

UIAlertView *respringAlert;
- (void)respring {
    respringAlert = [[UIAlertView alloc] initWithTitle:@"Respring required" message:@"Would you like to respring right now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [respringAlert show];
}

- (void)uicache {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reloading caches" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    // Run uicache
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        pid_t pid;
        int status;
        const char *argv[] = {"uicache", NULL};
        posix_spawn(&pid, "/usr/bin/uicache", NULL, NULL, (char* const*)argv, NULL);
        waitpid(pid, &status, 0);
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    [self.view endEditing:YES];
}

#pragma mark - Reload method

- (void)reload {
    NSArray *newApplications = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Applications/" error:nil];
    NSArray *newTweaks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/MobileSubstrate/DynamicLibraries/" error:nil];
    if(newApplications.count != _oldApplications) [self uicache];
    if(newTweaks.count != _oldTweaks) [self respring];
}

- (void)about {
    if([_aboutButton.currentTitle isEqualToString:@"Dark"]) {
        [_aboutButton setTitle:@"Light" forState:UIControlStateNormal];
        [self switchToDarkMode];
    } else if([_aboutButton.currentTitle isEqualToString:@"Light"]) {
        [_aboutButton setTitle:@"Dark" forState:UIControlStateNormal];
        [self switchToLightMode];
    } else if([_aboutButton.currentTitle isEqualToString:@"Install"] && _searchViewController.depictionWebView.hidden) {
        [self messageWithTitle:@"Error" message:@"You need to search for a package first."];
    } else if([_aboutButton.currentTitle isEqualToString:@"Install"] && !_searchViewController.depictionWebView.hidden) {
        _nameLabel.text = @"Getting...";
        [self downloadWithProgressAndURLString:[_searchViewController.searchFilenames objectAtIndex:_packageIndex] saveFilename:@"downloaded.deb"];
    } else if([_aboutButton.currentTitle isEqualToString:@"Backup"]){
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
            [alert release];
            [self messageWithTitle:@"Done" message:@"The package backup was saved to /var/mobile/Backup.txt"];
        });
    } else if([_aboutButton.currentTitle isEqualToString:@"Manage"]) [_sourcesViewController manage];
    else if([_aboutButton.currentTitle isEqualToString:@"Remove"]) [_manageViewController removePackageButtonAction];
    else if([_aboutButton.currentTitle isEqualToString:@"Options"]) [_searchViewController showPackageOptions];
    else [self messageWithTitle:@"Some random shit happened" message:@"Literally the title."];
}

#pragma mark - Dark/light modes

/*- (void)switchToDarkMode {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"darkMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    darkMode = YES;
    //_aboutButton.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.1];
    //_aboutButton.titleLabel.textColor = [UIColor orangeColor];
    [_toolbar setBarTintColor:[UIColor blackColor]];
    _nameLabel.textColor = [UIColor whiteColor];
    //_dateLabel.textColor = [UIColor grayColor];
    self.view.backgroundColor = [UIColor blackColor];
    _tableView.backgroundColor = [UIColor blackColor];
    _tableView2.backgroundColor = [UIColor blackColor];
    _tableView3.backgroundColor = [UIColor blackColor];
    _searchField.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.1];
    _searchField.textColor = [UIColor whiteColor];
    infoView.backgroundColor = [UIColor blackColor];
    [_welcomeWebView stringByEvaluatingJavaScriptFromString:@"document.body.style.background = 'black'; var p = document.getElementsByTagName('p'); for (var i = 0; i < p.length; i++) { p[i].style.color = 'white'; }"];
    _searchField.keyboardAppearance = UIKeyboardAppearanceDark;
    [self homeAction];
}

- (void)switchToLightMode {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"darkMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    darkMode = NO;
    //_aboutButton.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    //_aboutButton.titleLabel.textColor = [UIColor blueColor];
    [_toolbar setBarTintColor:[UIColor whiteColor]];
    _nameLabel.textColor = [UIColor blackColor];
    //_dateLabel.textColor = [UIColor grayColor];
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView2.backgroundColor = [UIColor whiteColor];
    _tableView3.backgroundColor = [UIColor whiteColor];
    _searchField.backgroundColor = [UIColor whiteColor];
    _searchField.textColor = [UIColor blackColor];
    _searchField.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    infoView.backgroundColor = [UIColor whiteColor];
    [_welcomeWebView reload];
    _searchField.keyboardAppearance = UIKeyboardAppearanceLight;
    [self homeAction];
}*/

#pragma mark - Navigation methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    _nameLabel.text = item.title;
    _dateLabel.hidden = YES;
    if (tabBar.selectedItem.tag == 0) [self homeAction];
    else if(tabBar.selectedItem.tag == 1) [self sourcesAction];
    else if(tabBar.selectedItem.tag == 2) [self manageAction];
    else if(tabBar.selectedItem.tag == 3) [self searchAction];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) _aboutButton.titleLabel.textColor = [UIColor orangeColor];
    else _aboutButton.titleLabel.textColor = coolerBlueColor;
    [self.view bringSubviewToFront:_tabbar];
    [self.view bringSubviewToFront:_navigationBar];
}

- (void)homeAction {
    _dateLabel.hidden = NO;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) [_aboutButton setTitle:@"Light" forState:UIControlStateNormal];
    else [_aboutButton setTitle:@"Dark" forState:UIControlStateNormal];
    _homeViewController.view.hidden = NO;
    [self.view bringSubviewToFront:_homeViewController.view];
}
- (void)sourcesAction {
    [_aboutButton setTitle:@"Manage" forState:UIControlStateNormal];
    _sourcesViewController.view.hidden = NO;
    [self.view bringSubviewToFront:_sourcesViewController.view];
}
- (void)manageAction {
    [_aboutButton setTitle:@"Backup" forState:UIControlStateNormal];
    _manageViewController.view.hidden = NO;
    [self.view bringSubviewToFront:_manageViewController.view];
}

- (void)searchAction {
    [_aboutButton setTitle:@"Install" forState:UIControlStateNormal];
    _searchViewController.view.hidden = NO;
    [self.view bringSubviewToFront:_searchViewController.view];
}

#pragma mark - Small but useful bits of code

- (void)messageWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    [alert release];
    //_aboutButton.titleLabel.textColor = coolerBlueColor;
}

- (void)makeViewRound:(UIView *)view withRadius:(int)radius {
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = radius;
}

#pragma mark - UI Orientation methods

/*- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        [self changeToPortrait];
    }
    else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        [self changeToLandscape];
    }
}

- (void)changeToPortrait {
    //_aboutButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 120,55,75,30);
    _nameLabel.frame = CGRectMake(26,50,[UIScreen mainScreen].bounds.size.width,40);
    //_dateLabel.frame = CGRectMake(26,26,[UIScreen mainScreen].bounds.size.width,20);
    _welcomeWebView.frame = CGRectMake(0,120,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 200);
    _homeImage.frame = CGRectMake(30,10,32,32);
    _homeLabel.frame = CGRectMake(27,45,40,10);
    _sourcesImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 16, 10, 32, 32);
    _sourcesLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 25,45,50,10);
    _manageImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 62,10,32,32);
    _manageLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 70,40,50,20);
    _tableView.frame = CGRectMake(13,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 200);
    _tableView2.frame = CGRectMake(13,140,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 220);
    _searchField.frame = CGRectMake(20,120,[UIScreen mainScreen].bounds.size.width - 40,20);
}

- (void)changeToLandscape {
    //_aboutButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - 120,55,75,30);
    _nameLabel.frame = CGRectMake(26,50,[UIScreen mainScreen].bounds.size.height,40);
    //_dateLabel.frame = CGRectMake(26,26,[UIScreen mainScreen].bounds.size.height,20);
    _welcomeWebView.frame = CGRectMake(0,120,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 200);
    _homeImage.frame = CGRectMake(30,10,32,32);
    _homeLabel.frame = CGRectMake(27,45,40,10);
    _sourcesImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.height / 2 - 16, 10, 32, 32);
    _sourcesLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.height / 2 - 25,45,50,10);
    _manageImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - 62,10,32,32);
    _manageLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - 70,40,50,20);
    _tableView.frame = CGRectMake(13,100,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 200);
    _tableView2.frame = CGRectMake(13,140,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 220);
    _searchField.frame = CGRectMake(20,120,[UIScreen mainScreen].bounds.size.height - 40,20);
}*/

#pragma mark - Random backend methods

- (NSString *)versionOfPackage:(NSString *)package {
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    const char *pkgsearch = [[NSString stringWithFormat:@"Package: %@\n",package] UTF8String];
    BOOL shouldReturn = NO;
    while(fgets(str, 999, file) != NULL) {
        if(strcmp(str, pkgsearch) == 0) shouldReturn = YES;
        if(shouldReturn && strstr(str, "Version:")) return [[NSString stringWithCString:str encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"Version: " withString:@""];
    }
    return @"No such package";
}

- (BOOL)isPackageInstalled:(NSString *)package {
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    const char *pkgsearch = [[NSString stringWithFormat:@"Package: %@\n",package] UTF8String];
    const char *search = [package UTF8String];
    while(fgets(str, 999, file) != NULL) {
        if(strcmp(str, pkgsearch) == 0) return YES;
        if(strstr(str, "Provides:") && strstr(str, search)) return YES;
        if(strstr(str, "Replaces:") && strstr(str, search)) return YES;
    }
    return NO;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.urlResponse = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.downloadedMutableData appendData:data];
    _progressView.progress = ((100.0/self.urlResponse.expectedContentLength)*self.downloadedMutableData.length)/100;
    if (_progressView.progress == 1) {
        _progressView.hidden = YES;
    } else {
        _progressView.hidden = NO;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.downloadedMutableData writeToFile:[NSString stringWithFormat:@"/var/mobile/Media/%@",_filename] atomically:YES];
    if([_filename isEqualToString:@"downloaded.deb"]) {
        // Dependencies
        //dpkg-deb -f ./com.artikus.IcyInstaller3_3.1.1_iphoneos-arm.deb Depends
        /*NSArray *packageDependencies = [[self runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze"] withArguments:@[@"-f", @"/var/mobile/Media/downloaded.deb", @"Depends"] errors:NO] componentsSeparatedByString:@", "];
        NSString *message = @"This package dependes on the following packages:";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        for (id object in packageDependencies) message = [message stringByAppendingString:[@"\n - " stringByAppendingString:object]];
        message = [message stringByAppendingString:@"Attempting to search for these packages in your sources list."];
        [alert show];
        for (id object in packageDependencies) {
            NSString *noSpace = nil;
            if([object rangeOfString:@" "].location != NSNotFound) noSpace = [[object substringToIndex:[object rangeOfString:@" "].location] stringByReplacingOccurrencesOfString:@" " withString:@""];
            
        }*/
        // Install
        [self runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze"] withArguments:@[@"-i", @"/var/mobile/Media/downloaded.deb"] errors:NO];
        [self reload];
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Media/downloaded.deb" error:nil];
        _nameLabel.text = @"Done";
    }
}

- (void)downloadWithProgressAndURLString:(NSString *)urlString saveFilename:(NSString *)filename {
    _filename = filename;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    [request setValue:[self uniqueDeviceID] forHTTPHeaderField:@"X-Unique-ID"];
    [request setValue:@"Telesphoreo APT-HTTP/1.0.592" forHTTPHeaderField:@"User-Agent"];
    [request setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"X-Firmware"];
    [request setValue:_deviceModel forHTTPHeaderField:@"X-Machine"];
    _connectionManager = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (NSString *)runCommandWithOutput:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:command];
    [task setCurrentDirectoryPath:@"/"];
    [task setArguments:args];
    NSPipe *out = [NSPipe pipe];
    NSPipe *err = [NSPipe pipe];
    [task setStandardOutput:out];
    [task setStandardError:err];
    [task launch];
    [task waitUntilExit];
    [task release];
    if(errors) return [[[NSString alloc] initWithData:[[err fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding] autorelease];
    else return [[[NSString alloc] initWithData:[[out fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding] autorelease];
}

- (NSInteger)returnOfCommand:(NSString *)command withArguments:(NSArray *)args {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:command];
    [task setCurrentDirectoryPath:@"/"];
    [task setArguments:args];
    [task launch];
    [task waitUntilExit];
    return [task terminationStatus];
}

#pragma mark - Random methods

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)isNetworkAvailable {
    char *hostname;
    struct hostent *hostinfo;
    hostname = "google.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL) return NO;
    else return YES;
}

OBJC_EXTERN CFStringRef MGCopyAnswer(CFStringRef key) WEAK_IMPORT_ATTRIBUTE;
- (NSString *)uniqueDeviceID {
    CFStringRef udid = MGCopyAnswer(CFSTR("UniqueDeviceID"));
    return (NSString *)udid;
}

@end
