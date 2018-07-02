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
#include <bzlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <netdb.h>
#include "NSTask.h"
#import <dlfcn.h>
#import <mach/port.h>
#import <mach/kern_return.h>
#import <sys/utsname.h>
#import "ViewController.h"

@interface ViewController ()

// The download variables
@property (strong, nonatomic) NSURLConnection *connectionManager;
@property (strong, nonatomic) NSMutableData *downloadedMutableData;
@property (strong, nonatomic) NSURLResponse *urlResponse;
@property (strong, nonatomic) NSString *filename;

// UI
@property (strong, nonatomic) UIButton *aboutButton;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIWebView *welcomeWebView;
@property (strong, nonatomic) UIWebView *depictionWebView;
@property (strong, nonatomic) UIWebView *packageWebView;
@property (strong, nonatomic) UIView *navigationView;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIImageView *homeImage;
@property (strong, nonatomic) UIImageView *sourcesImage;
@property (strong, nonatomic) UIImageView *manageImage;
@property (strong, nonatomic) UILabel *homeLabel;
@property (strong, nonatomic) UILabel *sourcesLabel;
@property (strong, nonatomic) UILabel *manageLabel;
@property (strong, nonatomic) UITextField *searchField;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UITableView *tableView2;
@property (strong, nonatomic) UITableView *tableView3;
@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UITextView *loadingArea;
@property (strong, nonatomic) UIProgressView *progressView;

// Package management arrays
@property (strong, nonatomic) NSMutableArray *packageIDs;
@property (strong, nonatomic) NSMutableArray *packageNames;
@property (strong, nonatomic) NSMutableArray *packageImages;
@property (strong, nonatomic) NSMutableArray *packageIcons;

// Package search arrays
@property (strong, nonatomic) NSMutableArray *searchNames;
@property (strong, nonatomic) NSMutableArray *searchDescs;
@property (strong, nonatomic) NSMutableArray *searchDepictions;
@property (strong, nonatomic) NSMutableArray *searchFilenames;

// Reload needed arrays
@property (nonatomic) NSUInteger oldApplications;
@property (nonatomic) NSUInteger oldTweaks;

// Other random arrays
@property (strong, nonatomic) NSMutableArray *sources;
@property (strong, nonatomic) NSMutableArray *sourceLinks;

// Device info
@property (nonatomic) NSString *deviceModel;
@end
#define coolerBlueColor [UIColor colorWithRed:0.00 green:0.52 blue:1.00 alpha:1.0];
BOOL darkMode = NO;
int packageIndex;
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Get device model
    struct utsname systemInfo;
    uname(&systemInfo);
    _deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    // Initialize arrays
    _searchNames = [[NSMutableArray alloc] init];
    _searchDescs = [[NSMutableArray alloc] init];
    _searchDepictions = [[NSMutableArray alloc] init];
    _searchFilenames = [[NSMutableArray alloc] init];
    _packageIcons = [[NSMutableArray alloc] init];
    // Get arrays needed for reload
    _oldApplications = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Applications/" error:nil].count;
    _oldTweaks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/MobileSubstrate/DynamicLibraries/" error:nil].count;
    // Get value of darkMode
    darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"];
    // Stuff for downloading with progress
    self.downloadedMutableData = [[NSMutableData alloc] init];
    // The button at the right
    _aboutButton = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 100,55,75,30)];
    _aboutButton.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    if(darkMode) [_aboutButton setTitle:@"Light" forState:UIControlStateNormal];
    else [_aboutButton setTitle:@"Dark" forState:UIControlStateNormal];
    _aboutButton.titleLabel.textColor = coolerBlueColor;
    [_aboutButton addTarget:self action:@selector(about) forControlEvents:UIControlEventTouchUpInside];
    [self makeViewRound:_aboutButton withRadius:5];
    [self.view addSubview:_aboutButton];
    // The top label
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(26,50,[UIScreen mainScreen].bounds.size.width - 130,40)];
    _nameLabel.text = @"Icy Installer";
    _nameLabel.backgroundColor = [UIColor clearColor];
    [_nameLabel setFont:[UIFont boldSystemFontOfSize:30]];
    [self.view addSubview:_nameLabel];
    // The less top but still top label
    _dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(26,26,[UIScreen mainScreen].bounds.size.width,20)];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth fromDate:[NSDate date]];
    NSArray *weekdays = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    NSArray *months = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
    _dateLabel.text = [[NSString stringWithFormat:@"%@, %@ %ld",[weekdays objectAtIndex:[components weekday] - 1],[months objectAtIndex:[components month] - 1],[components day]] uppercaseString];
    _dateLabel.textColor = [UIColor grayColor];
    [_dateLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [self.view addSubview:_dateLabel];
    // The homepage webview, temporair and toreplace with something native like the AppStore homepage
    _welcomeWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100)];
    [_welcomeWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://artikus.pe.hu/Icy.html"]]];
    _welcomeWebView.scrollView.contentInset = UIEdgeInsetsMake(0,0,60,0);
    [self.view addSubview:_welcomeWebView];
    // The depiction webview
    _depictionWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100)];
    _depictionWebView.scrollView.contentInset = UIEdgeInsetsMake(0,0,60,0);
    [self.view addSubview:_depictionWebView];
    _depictionWebView.hidden = YES;
    // The package webview
    _packageWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 220)];
    [self.view addSubview:_packageWebView];
    _packageWebView.hidden = YES;
    // Change the user agent to a desktop one, so when we view depictions "Open in Cydia" doesn't appear
    NSDictionary *dictionary = @{@"UserAgent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1 Safari/605.1.15"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Navigation, I guess
    _navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 60, [UIScreen mainScreen].bounds.size.width, 60)];
    _navigationView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_navigationView];
    [self.view bringSubviewToFront:_navigationView];
    _toolbar = [[UIToolbar alloc] initWithFrame:_navigationView.bounds];
    if(darkMode) [_toolbar setBarTintColor:[UIColor blackColor]];
    else [_toolbar setBarTintColor:[UIColor whiteColor]];
    [_navigationView.layer insertSublayer:[_toolbar layer] atIndex:0];
    // The homeImage
    _homeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/Home.png"]];
    _homeImage.frame = CGRectMake(30,10,32,32);
    _homeImage.userInteractionEnabled = YES;
    _homeImage.image = [_homeImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if(darkMode) [_homeImage setTintColor:[UIColor orangeColor]];
    else _homeImage.tintColor = coolerBlueColor;
    [_navigationView addSubview:_homeImage];
    // The home label
    _homeLabel = [[UILabel alloc] initWithFrame:CGRectMake(27,45,40,10)];
    _homeLabel.textAlignment = NSTextAlignmentCenter;
    if(darkMode) _homeLabel.textColor = [UIColor orangeColor];
    else _homeLabel.textColor = coolerBlueColor;
    _homeLabel.text = @"Home";
    [_homeLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [_navigationView addSubview:_homeLabel];
    // The sourcesImage
    _sourcesImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/Sources.png"]];
    _sourcesImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 16, 10, 32, 32);
    _sourcesImage.userInteractionEnabled = YES;
    _sourcesImage.image = [_sourcesImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _sourcesImage.tintColor = [UIColor grayColor];
    [_navigationView addSubview:_sourcesImage];
    // The sources label
    _sourcesLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 25,45,50,10)];
    _sourcesLabel.textColor = [UIColor grayColor];
    _sourcesLabel.textAlignment = NSTextAlignmentCenter;
    _sourcesLabel.text = @"Sources";
    [_sourcesLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [_navigationView addSubview:_sourcesLabel];
    // The manageImage
    _manageImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/Installed.png"]];
    _manageImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 62,10,32,32);
    _manageImage.userInteractionEnabled = YES;
    _manageImage.image = [_manageImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _manageImage.tintColor = [UIColor grayColor];
    [_navigationView addSubview:_manageImage];
    // The manage label
    _manageLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 70,40,50,20)];
    _manageLabel.textColor = [UIColor grayColor];
    _manageLabel.textAlignment = NSTextAlignmentCenter;
    _manageLabel.text = @"Manage";
    [_manageLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [_navigationView addSubview:_manageLabel];
    // Gesture recognizers
    UITapGestureRecognizer *homeGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(homeAction)];
    [_homeImage addGestureRecognizer:homeGesture];
    UITapGestureRecognizer *sourcesGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sourcesAction)];
    [_sourcesImage addGestureRecognizer:sourcesGesture];
    UITapGestureRecognizer *manageGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(manageAction)];
    [_manageImage addGestureRecognizer:manageGesture];
    // Table views
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(13,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.contentInset = UIEdgeInsetsMake(0,0,70,0);
    [self.view addSubview:_tableView];
    _tableView.hidden = YES;
    _tableView2 = [[UITableView alloc] initWithFrame:CGRectMake(13,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100) style:UITableViewStylePlain];
    _tableView2.delegate = self;
    _tableView2.dataSource = self;
    _tableView2.backgroundColor = [UIColor whiteColor];
    [_tableView2 setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView2.contentInset = UIEdgeInsetsMake(0,0,70,0);
    [self.view addSubview:_tableView2];
    _tableView2.hidden = YES;
    _tableView3 = [[UITableView alloc] initWithFrame:CGRectMake(13,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100) style:UITableViewStylePlain];
    _tableView3.delegate = self;
    _tableView3.dataSource = self;
    _tableView3.backgroundColor = [UIColor whiteColor];
    [_tableView3 setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView3.contentInset = UIEdgeInsetsMake(0,0,70,0);
    [self.view addSubview:_tableView3];
    _tableView3.hidden = YES;
    // Search texfield
    _searchField = [[UITextField alloc] initWithFrame:CGRectMake(20,10,[UIScreen mainScreen].bounds.size.width - 40,30)];
    _searchField.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    _searchField.leftView = paddingView;
    _searchField.leftViewMode = UITextFieldViewModeAlways;
    _searchField.returnKeyType = UIReturnKeySearch;
    _searchField.delegate = self;
    _searchField.hidden = YES;
    [self makeViewRound:_searchField withRadius:5];
    [self.view addSubview:_searchField];
    // Loading view
    _loadingView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if(darkMode) _loadingView.backgroundColor = [UIColor blackColor];
    else _loadingView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_loadingView];
    // Gradient
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(30,[UIScreen mainScreen].bounds.size.height / 2 - 160,[UIScreen mainScreen].bounds.size.width - 60,360)];
    [self makeViewRound:gradientView withRadius:10];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)[UIColor colorWithRed:0.16 green:0.81 blue:0.93 alpha:1.0].CGColor, (id)[UIColor colorWithRed:0.15 green:0.48 blue:0.78 alpha:1.0].CGColor];
    gradient.frame = gradientView.bounds;
    if(darkMode) gradientView.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.1];
    else [gradientView.layer insertSublayer:gradient atIndex:0];
    [_loadingView addSubview:gradientView];
    // Top label
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, 50)];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"Icy Installer";
    [loadingLabel setFont:[UIFont boldSystemFontOfSize:30]];
    if(darkMode) loadingLabel.textColor = [UIColor whiteColor];
    else loadingLabel.textColor = [UIColor blackColor];
    [_loadingView addSubview:loadingLabel];
    // Loading textarea
    _loadingArea = [[UITextView alloc] initWithFrame:CGRectMake(0, 50, gradientView.bounds.size.width, 330)];
    _loadingArea.scrollEnabled = NO;
    _loadingArea.textColor = [UIColor whiteColor];
    _loadingArea.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0];
    _loadingArea.textAlignment = NSTextAlignmentCenter;
    [_loadingArea setFont:[UIFont boldSystemFontOfSize:15]];
    _loadingArea.text = @"Welcome to Icy Installer 3.1!\nMade by ArtikusHG.\nLoading packages....";
    [gradientView addSubview:_loadingArea];
    // Progress spinwheel
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.frame = CGRectMake(gradientView.bounds.size.width / 2 - 10,20,20,20);
    [gradientView addSubview:spinner];
    [spinner startAnimating];
    // Progress View
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.frame = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,10);
    _progressView.progress = 0;
    [self.view addSubview:_progressView];
    if(darkMode) [self switchToDarkMode];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self loadStuff];
    });
}

#pragma mark - Loading methods

- (void)loadStuff {
    // Check for needed directories
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy" isDirectory:nil]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy" withIntermediateDirectories:NO attributes:nil error:nil];
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/Repos" isDirectory:nil]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" withIntermediateDirectories:NO attributes:nil error:nil];
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/sources.list" isDirectory:nil]) [[NSFileManager defaultManager] createFileAtPath:@"/var/mobile/Media/Icy/sources.list" contents:nil attributes:nil];
    // Get third party source list
    if([[[NSFileManager defaultManager] attributesOfItemAtPath:@"/var/mobile/Media/Icy/sources.list" error:nil] fileSize] >= 11) {
        NSString *sources = [NSString stringWithContentsOfFile:@"/var/mobile/Media/Icy/sources.list" encoding:NSUTF8StringEncoding error:nil];
        sources = [sources substringToIndex:sources.length - 1];
        // 11 - shortest link that can ever exist: http://a.co, if it's less that this - it's not a valid sources.list file
        _sourceLinks = [[NSMutableArray alloc] initWithArray:[sources componentsSeparatedByString:@"\n"]];
    }
    _sources = [[NSMutableArray alloc] init];
    for(id object in [[NSUserDefaults standardUserDefaults] objectForKey:@"sourceNames"]) [_sources addObject:object];
    BOOL isDirectory;
    // Check for needed directories
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy" isDirectory:&isDirectory]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy" withIntermediateDirectories:NO attributes:nil error:nil];
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/Repos" isDirectory:&isDirectory]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" withIntermediateDirectories:NO attributes:nil error:nil];
    // Redirect log to a file
    freopen([@"/var/mobile/Media/Icy/log.txt" cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    // Get package list and put to table view
    _packageNames = [[NSMutableArray alloc] init];
    _packageIDs = [[NSMutableArray alloc] init];
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    NSString *icon = nil;
    NSString *lastID = nil;
    while(fgets(str, 999, file) != NULL) {
        if(strstr(str, "Package:"))  [_packageIDs addObject:[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Package: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
        if(strstr(str, "Name:")) [_packageNames addObject:[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Name: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
        if(strstr(str, "Section:")) {
            icon = [NSString stringWithFormat:@"/Applications/IcyInstaller3.app/icons/%@.png",[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Section: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
            if([icon rangeOfString:@" "].location != NSNotFound) icon = [NSString stringWithFormat:@"%@.png",[icon substringToIndex:[icon rangeOfString:@" "].location]];
        }
        if(strstr(str, "Icon:")) icon = [[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Icon: file://" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if(![[NSFileManager defaultManager] fileExistsAtPath:icon]) icon = @"/Applications/IcyInstaller3.app/icons/Unknown.png";
        if(strlen(str) < 2) {
            lastID = [_packageIDs lastObject];
            if(_packageIDs.count > _packageNames.count) [_packageNames addObject:lastID];
            NSString *lastObject = [_packageNames lastObject];
            [_packageNames sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [_packageIDs removeLastObject];
            [_packageIDs insertObject:lastID atIndex:[_packageNames indexOfObject:lastObject]];
            [_packageIcons insertObject:icon atIndex:[_packageNames indexOfObject:lastObject]];
        }
    }
    fclose(file);
    _loadingArea.text = [_loadingArea.text stringByAppendingString:@"Finished loading packages.\nLaunching Icy..."];
    [_tableView reloadData];
    [_tableView3 reloadData];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _loadingView.frame  = CGRectMake(0,-[UIScreen mainScreen].bounds.size.height - 20,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    } completion:^(BOOL finished) {
        if(darkMode) [_welcomeWebView stringByEvaluatingJavaScriptFromString:@"document.body.style.background = 'black'; var p = document.getElementsByTagName('p'); for (var i = 0; i < p.length; i++) { p[i].style.color = 'white'; }"];
    }];
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    if(theTableView == _tableView) return _packageNames.count;
    else if(theTableView == _tableView2) return _searchNames.count;
    else if(theTableView == _tableView3) return _sources.count;
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = (UITableViewCell *)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIImage *icon = nil;
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    if(theTableView == _tableView) {
        cell.textLabel.text = [_packageNames objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [_packageIDs objectAtIndex:indexPath.row];
        icon = [UIImage imageWithContentsOfFile:[_packageIcons objectAtIndex:indexPath.row]];
    } else if(theTableView == _tableView2) {
        cell.textLabel.text = [_searchNames objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [_searchDescs objectAtIndex:indexPath.row];
    } else if(theTableView == _tableView3) cell.textLabel.text = [[_sources objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    else cell.textLabel.text = @"Some stupid error happened";
    if(icon == nil) return cell;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40,40), NO, [UIScreen mainScreen].scale);
    [icon drawInRect:CGRectMake(0,0,40,40)];
    icon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self makeViewRound:cell.imageView withRadius:10];
    cell.imageView.image = icon;
    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(theTableView == _tableView) [self packageInfoWithIndexPath:indexPath];
    else if(theTableView == _tableView2) [self showDepictionForPackageWithIndexPath:indexPath];
    else if(theTableView == _tableView3) [self removeRepoAtIndexPath:indexPath];
    else [self messageWithTitle:@"Error" message:@"Literally an error, and a very, very strange one... Go report this to ArtikusHG."];
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Package management methods

UIView *infoView;
UITextView *infoText;
int removeIndex;
- (void)packageInfoWithIndexPath:(NSIndexPath *)indexPath {
    removeIndex = (int)indexPath.row;
    [_aboutButton setTitle:@"Remove" forState:UIControlStateNormal];
    if(darkMode) _aboutButton.titleLabel.textColor = [UIColor orangeColor];
    else _aboutButton.titleLabel.textColor = coolerBlueColor;
    _nameLabel.text = [_tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    UIView *infoTextView = [[UIView alloc] initWithFrame:CGRectMake(20,10,[UIScreen mainScreen].bounds.size.width - 40,[UIScreen mainScreen].bounds.size.height / 2 + 1)];
    [self makeViewRound:infoTextView withRadius:10];
    infoView = [[UIView alloc] initWithFrame:CGRectMake(0,-[UIScreen mainScreen].bounds.size.height - 161,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 161)];
    [infoView addSubview:infoTextView];
    [self.view addSubview:infoView];
    infoText = [[UITextView alloc] initWithFrame:infoTextView.bounds];
    infoText.editable = NO;
    infoText.scrollEnabled = YES;
    infoText.textColor = [UIColor whiteColor];
    infoText.backgroundColor = [UIColor clearColor];
    if(darkMode) {
        infoTextView.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.1];
        infoView.backgroundColor = [UIColor blackColor];
    } else {
        infoTextView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
        infoView.backgroundColor = [UIColor whiteColor];
        infoText.textColor = [UIColor blackColor];
    }
    [infoText setFont:[UIFont boldSystemFontOfSize:15]];
    [self makeViewRound:infoText withRadius:10];
    [infoTextView addSubview:infoText];
    UIButton *dismiss = [[UIButton alloc] initWithFrame:CGRectMake(20,infoView.bounds.size.height - 50,[UIScreen mainScreen].bounds.size.width - 40,40)];
    if(darkMode) dismiss.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.1];
    else dismiss.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    [dismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
    dismiss.layer.masksToBounds = YES;
    dismiss.layer.cornerRadius = 10;
    [dismiss.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    if(darkMode) dismiss.titleLabel.textColor = [UIColor orangeColor];
    else dismiss.titleLabel.textColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    [dismiss addTarget:self action:@selector(dismissInfo) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:dismiss];
    UIButton *more = [[UIButton alloc] initWithFrame:CGRectMake(20,infoView.bounds.size.height - 100,[UIScreen mainScreen].bounds.size.width - 40,40)];
    more.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.1];
    [more setTitle:@"More info" forState:UIControlStateNormal];
    [more setTitle:@"More info unavailable" forState:UIControlStateDisabled];
    more.layer.masksToBounds = YES;
    more.layer.cornerRadius = 10;
    more.enabled = NO;
    [more.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    more.titleLabel.textColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5];
    [more addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:more];
    NSString *searchString = [NSString stringWithFormat:@"Package: %@\n",[_packageIDs objectAtIndex:indexPath.row]];
    NSString *info = @"";
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    BOOL shouldWrite = NO;
    const char *search = [searchString UTF8String];
    while(fgets(str, 999, file) != NULL) {
        if(strcmp(str, search) == 0) shouldWrite = YES;
        if(strlen(str) < 2 && shouldWrite) break;
        if(shouldWrite && !strstr(str, "Priority:") && !strstr(str, "Status:") && !strstr(str, "Installed-Size:") && !strstr(str, "Maintainer:") && !strstr(str, "Architecture:") && !strstr(str, "Replaces:") && !strstr(str, "Provides:") && !strstr(str, "Homepage:") && !strstr(str, "Depiction:") && !strstr(str, "Depiction:") && !strstr(str, "Sponsor:") && !strstr(str, "dev:") && !strstr(str, "Tag:") && !strstr(str, "Icon:") && !strstr(str, "Website:") && !strstr(str, "Conflicts:") && !strstr(str, "Depends:")) info = [NSString stringWithFormat:@"%@%@",info,[NSString stringWithCString:str encoding:NSASCIIStringEncoding]];
        if(shouldWrite && strstr(str, "Depiction:")) {
            more.enabled = YES;
            more.titleLabel.textColor = [UIColor orangeColor];
        }
    }
    fclose(file);
    infoText.text = info;
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        infoView.frame  = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 160);
    } completion:nil];
}

- (void)moreInfo {
    if(![self isNetworkAvailable]) {
        [self messageWithTitle:@"Error" message:@"This action requires an internet connection. If you are connected to the internet, but the problem still occurs, try relaunching Icy."];
        return;
    }
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    char search[999];
    snprintf(search, sizeof(search), "Package: %s", [[_packageIDs objectAtIndex:removeIndex] UTF8String]);
    BOOL shouldReturn = NO;
    while (fgets(str, 999, file) != NULL) {
        if(strstr(str, search)) shouldReturn = YES;
        if(strstr(str, "Depiction:") && shouldReturn) break;
    }
    fclose(file);
    [_packageWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] substringFromIndex:11] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]]];
    _packageWebView.hidden = NO;
    [self.view bringSubviewToFront:_packageWebView];
}

- (void)dismissInfo {
    _packageWebView.hidden = YES;
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        infoView.frame  = CGRectMake(0,-[UIScreen mainScreen].bounds.size.height - 100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 161);
    } completion:nil];
    [self manageAction];
}

- (void)removePackageButtonAction {
    [self removePackageWithBundleID:[_packageIDs objectAtIndex:removeIndex]];
    [self reload];
}

UIView *dependencyView;
NSMutableArray *dependencies;
UIAlertView *dependencyAlert;
- (void)removePackageWithBundleID:(NSString *)bundleID {
    NSString *output = [self runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze"] withArguments:@[@"-r", bundleID] errors:YES];
    // If the command had dependency errors we do some extra stuff to remove dependencies too
    if([output rangeOfString:@"dpkg: dependency problems prevent removal"].location != NSNotFound) {
        output = [output stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"dpkg: dependency problems prevent removal of %@:\n",bundleID] withString:@""];
        dependencies = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray *dependencyNames = [[[NSMutableArray alloc] init] autorelease];
        for (id object in [output componentsSeparatedByString:@"\n"]) if([object rangeOfString:@"depends"].location != NSNotFound) [dependencies addObject:[[object substringToIndex:[[object substringFromIndex:1] rangeOfString:@" "].location + 1] stringByReplacingOccurrencesOfString:@" " withString:@""]];
        dependencies = [[[NSOrderedSet orderedSetWithArray:dependencies] array] mutableCopy];
        for (id object in dependencies) [dependencyNames addObject:[self packageNameForBundleID:object]];
        NSString *message = @"The following packages depend on the package you're trying to remove:\n";
        for(id object in dependencyNames) message = [message stringByAppendingString:[NSString stringWithFormat:@"- %@\n",object]];
        message = [message stringByAppendingString:@"Would you also like to remove those packages?"];
        dependencyAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", nil];
        [dependencyAlert show];
    }
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView == dependencyAlert && buttonIndex != [alertView cancelButtonIndex]) {
        for (id object in dependencies) [self removePackageWithBundleID:object];
        [self reload];
    }
    else if(alertView == respringAlert && buttonIndex != [alertView cancelButtonIndex]) {
        pid_t pid;
        int status;
        const char *argv[] = {"killall", "-9", "SpringBoard", NULL};
        posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char**)argv, NULL);
        waitpid(pid, &status, 0);
    }
    else if(alertView == manageAlert && buttonIndex == 1) [self refreshSources];
    else if(alertView == manageAlert && buttonIndex == 2) [self updatePackages];
    else if(alertView == manageAlert && buttonIndex == 3) [self addSource];
    else if(alertView == addSourceAlert && buttonIndex != alertView.cancelButtonIndex) {
        long releaseStatusCode = [self statusCodeOfFileAtURL:[NSString stringWithFormat:@"http://%@/Release",[alertView textFieldAtIndex:0].text]];
        if(releaseStatusCode != 200) {
            [self messageWithTitle:@"Error" message:[NSString stringWithFormat:@"Requesting the \"Release\" file of the repository returned the error code %ld or another error. This means a readable third-party source no longer exists at this URL (or it actually never did), has been moved or temporairly taken down. You can try contacting the repository owner or the developer of Icy Installer by sending the contents of the /var/mobile/Media/Icy/log.txt file.",releaseStatusCode]];
            NSLog(@"Response code: %ld",releaseStatusCode);
            return;
        }
        long packagesStatusCode = [self statusCodeOfFileAtURL:[NSString stringWithFormat:@"http://%@/Packages.bz2",[alertView textFieldAtIndex:0].text]];
        if(releaseStatusCode != 200) {
            [self messageWithTitle:@"Error" message:[NSString stringWithFormat:@"Requesting the \"Packages.bz2\" file of the repository returned the error code %ld or another error. This means a readable third-party source no longer exists at this URL (or it actually never did), has been moved or temporairly taken down. You can try contacting the repository owner or the developer of Icy Installer by sending the contents of the /var/mobile/Media/Icy/log.txt file.",packagesStatusCode]];
            NSLog(@"Response code: %ld",packagesStatusCode);
            return;
        }
        if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/sources.list" isDirectory:nil]) [[NSFileManager defaultManager] createFileAtPath:@"/var/mobile/Media/Icy/sources.list" contents:nil attributes:nil];
        if([[NSString stringWithContentsOfFile:@"/var/mobile/Media/Icy/sources.list" encoding:NSUTF8StringEncoding error:nil] rangeOfString:[@"http://" stringByAppendingString:[alertView textFieldAtIndex:0].text]].location != NSNotFound) {
            [self messageWithTitle:@"Error" message:@"This source is already added to Icy Installer's source list."];
            return;
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:@"/var/mobile/Media/Icy/sources.list"];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[[NSString stringWithFormat:@"http://%@\n",[alertView textFieldAtIndex:0].text] dataUsingEncoding:NSUTF8StringEncoding]];
        [self messageWithTitle:@"Done" message:@"The source was added to your personal list and downloaded to the device's storage."];
        // 11 - shortest link that can ever exist: http://a.co, if it's less that this - it's not a valid sources.list file
        if([[[NSFileManager defaultManager] attributesOfItemAtPath:@"/var/mobile/Media/Icy/sources.list" error:nil] fileSize] >= 11) {
            NSString *sources = [NSString stringWithContentsOfFile:@"/var/mobile/Media/Icy/sources.list" encoding:NSUTF8StringEncoding error:nil];
            // Remove last \n (newline character)
            sources = [sources substringToIndex:sources.length - 1];
            _sourceLinks = [[NSMutableArray alloc] initWithArray:[sources componentsSeparatedByString:@"\n"]];
        }
        [self refreshSources];
    } else if(alertView == removeRepoAlert) {
        [[NSFileManager defaultManager] removeItemAtPath:[@"/var/mobile/Media/Icy/Repos/" stringByAppendingString:[_sources objectAtIndex:repoRemoveIndex]] error:nil];
        [_sources removeObjectAtIndex:repoRemoveIndex];
        [[NSUserDefaults standardUserDefaults] setObject:_sources forKey:@"sourceNames"];
        [_tableView3 reloadData];
        [[[NSString stringWithContentsOfFile:@"/var/mobile/Media/Icy/sources.list" encoding:NSUTF8StringEncoding error:nil] stringByReplacingOccurrencesOfString:[[_sourceLinks objectAtIndex:repoRemoveIndex] stringByAppendingString:@"\n"] withString:@""] writeToFile:@"/var/mobile/Media/Icy/sources.list" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

- (NSString *)packageNameForBundleID:(NSString *)bundleID {
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    char search[999];
    snprintf(search, sizeof(search), "Package: %s", [bundleID UTF8String]);
    BOOL shouldReturn = NO;
    while (fgets(str, 999, file) != NULL) {
        if(strstr(str, search)) shouldReturn = YES;
        if(strstr(str, "Name:") && shouldReturn) break;
    }
    fclose(file);
    return [[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] substringFromIndex:6] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

#pragma mark - Reload method
- (void)reload {
    NSArray *newApplications = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Applications/" error:nil];
    NSArray *newTweaks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/MobileSubstrate/DynamicLibraries/" error:nil];
    if(newApplications.count != _oldApplications) [self uicache];
    if(newTweaks.count != _oldTweaks) [self respring];
}

#pragma mark - Manage methods

UIAlertView *manageAlert;
- (void)manage {
    manageAlert = [[UIAlertView alloc] initWithTitle:@"Manage" message:nil delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Reload sources", @"Scan updates", @"Add source", nil];
    [manageAlert show];
}

- (void)refreshSources {
    NSError *err = nil;
    for(id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" error:nil]) [[NSFileManager defaultManager] removeItemAtPath:[@"/var/mobile/Media/Icy/Repos/" stringByAppendingString:object] error:&err];
    if(err) {
        [self messageWithTitle:@"Error" message:[err localizedDescription]];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reloading sources..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/sources.list"]) [[NSFileManager defaultManager] createFileAtPath:@"/var/mobile/Media/Icy/sources.list" contents:nil attributes:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        // BigBoss
        [[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://apt.thebigboss.org/repofiles/cydia/dists/stable/main/binary-iphoneos-arm/Packages.bz2"]] writeToFile:@"/var/mobile/Media/Icy/Repos/BigBoss.bz2" atomically:YES];
        // ModMyi
        if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/Repos/ModMyi" isDirectory:nil]) [[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://apt.modmyi.com/dists/stable/main/binary-iphoneos-arm/Packages.bz2"]] writeToFile:@"/var/mobile/Media/Icy/Repos/ModMyi.bz2" atomically:YES];
        // Zodttd and MacCiti
        if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/Repos/Zodttd" isDirectory:nil]) [[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://zodttd.saurik.com/repo/cydia/dists/stable/main/binary-iphoneos-arm/Packages.bz2"]] writeToFile:@"/var/mobile/Media/Icy/Repos/Zodttd.bz2" atomically:YES];
        // Saurik's repo
        [[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://apt.saurik.com/cydia/Packages.bz2"]] writeToFile:@"/var/mobile/Media/Icy/Repos/Saurik.bz2" atomically:YES];
        for(id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos/" error:nil]) bunzip_one([[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@",object] UTF8String], [[[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@",object] stringByReplacingOccurrencesOfString:@".bz2" withString:@""] UTF8String]);
        // Third party repos
        for(id object in _sourceLinks) {
            long releaseResponse = [self statusCodeOfFileAtURL:[object stringByAppendingString:@"/Release"]];
            if(releaseResponse != 200) {
                NSLog(@"Request returned code not equal to 200 (%ld)",releaseResponse);
                [self messageWithTitle:@"Error" message:[NSString stringWithFormat:@"Consider removing the  \"%@\" source from yout list because it does not seem to respond.",object]];
            } else {
                [_sources addObject:[[[[[[NSString stringWithContentsOfURL:[NSURL URLWithString:[object stringByAppendingString:@"/Release"]] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"Origin: " withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
                [self downloadFileFromURLString:[object stringByAppendingString:@"/Packages.bz2"] saveFilename:[NSString stringWithFormat:@"Repos/%@.bz2",[_sources lastObject]]];
            }
        }
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:_sources];
        _sources = [[NSMutableArray alloc] initWithArray:[orderedSet array]];
        [[NSUserDefaults standardUserDefaults] setObject:_sources forKey:@"sourceNames"];
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        [_tableView3 reloadData];
    });
}

int bunzip_one(const char file[999], const char output[999]) {
    FILE *f = fopen(file, "r+b");
    FILE *outfile = fopen(output, "w");
    fprintf(outfile, "");
    outfile = fopen(output, "a");
    int bzError;
    BZFILE *bzf;
    char buf[4096];
    
    bzf = BZ2_bzReadOpen(&bzError, f, 0, 0, NULL, 0);
    if (bzError != BZ_OK) {
        printf("E: BZ2_bzReadOpen: %d\n", bzError);
        return -1;
    }
    
    while (bzError == BZ_OK) {
        int nread = BZ2_bzRead(&bzError, bzf, buf, sizeof buf);
        if (bzError == BZ_OK || bzError == BZ_STREAM_END) {
            size_t nwritten = fwrite(buf, 1, nread, stdout);
            fprintf(outfile, "%s", buf);
            if (nwritten != (size_t) nread) {
                printf("E: short write\n");
                return -1;
            }
        }
    }
    
    if (bzError != BZ_STREAM_END) {
        printf("E: bzip error after read: %d\n", bzError);
        return -1;
    }
    
    BZ2_bzReadClose(&bzError, bzf);
    fclose(outfile);
    fclose(f);
    return 0;
}

- (void)updatePackages {
    // TODO
}

UIAlertView *removeRepoAlert;
int repoRemoveIndex;
- (void)removeRepoAtIndexPath:(NSIndexPath *)indexPath {
    repoRemoveIndex = (int)indexPath.row;
    removeRepoAlert = [[UIAlertView alloc] initWithTitle:@"Confirm action" message:[NSString stringWithFormat:@"Please confirm that you really want to remove \"%@\" from the list of your sources.",[_tableView3 cellForRowAtIndexPath:indexPath].textLabel.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", nil];
    [removeRepoAlert show];
}

UIAlertView *addSourceAlert;
- (void)addSource {
    addSourceAlert = [[UIAlertView alloc] initWithTitle:@"Add source" message:@"Please enter the URL of the source WITHOUT including \"http(s)://\" or \"www\"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    addSourceAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [addSourceAlert show];
}

- (void)about {
    if([_aboutButton.currentTitle isEqualToString:@"Dark"]) {
        [_aboutButton setTitle:@"Light" forState:UIControlStateNormal];
        [self switchToDarkMode];
    } else if([_aboutButton.currentTitle isEqualToString:@"Light"]) {
        [_aboutButton setTitle:@"Dark" forState:UIControlStateNormal];
        [self switchToLightMode];
    } else if([_aboutButton.currentTitle isEqualToString:@"Install"] && _depictionWebView.hidden) {
        [self messageWithTitle:@"Error" message:@"You need to search for a package first."];
    } else if([_aboutButton.currentTitle isEqualToString:@"Install"] && !_depictionWebView.hidden) {
        _nameLabel.text = @"Getting...";
        [self downloadWithProgressAndURLString:[_searchFilenames objectAtIndex:packageIndex] saveFilename:@"downloaded.deb"];
        //[self messageWithTitle:@"Link" message:[_searchFilenames objectAtIndex:packageIndex]];
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
    } else if([_aboutButton.currentTitle isEqualToString:@"Manage"]) [self manage];
    else if([_aboutButton.currentTitle isEqualToString:@"Remove"]) [self removePackageButtonAction];
    else [self messageWithTitle:@"Some random shit happened" message:@"Literally the title."];
}

#pragma mark - Dark/light modes

- (void)switchToDarkMode {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"darkMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    darkMode = YES;
    _aboutButton.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.1];
    _aboutButton.titleLabel.textColor = [UIColor orangeColor];
    [_toolbar setBarTintColor:[UIColor blackColor]];
    _nameLabel.textColor = [UIColor whiteColor];
    _dateLabel.textColor = [UIColor grayColor];
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
    _aboutButton.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    _aboutButton.titleLabel.textColor = [UIColor blueColor];
    [_toolbar setBarTintColor:[UIColor whiteColor]];
    _nameLabel.textColor = [UIColor blackColor];
    _dateLabel.textColor = [UIColor grayColor];
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView2.backgroundColor = [UIColor whiteColor];
    _searchField.backgroundColor = [UIColor whiteColor];
    _searchField.textColor = [UIColor blackColor];
    _searchField.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    infoView.backgroundColor = [UIColor whiteColor];
    [_welcomeWebView reload];
    _searchField.keyboardAppearance = UIKeyboardAppearanceLight;
    [self homeAction];
}

#pragma mark - Navigation methods

- (void)homeAction {
    _nameLabel.text = @"Icy Installer";
    _dateLabel.hidden = NO;
    [UIView performWithoutAnimation:^{
        if(darkMode) {
            [_aboutButton setTitle:@"Light" forState:UIControlStateNormal];
        } else {
            [_aboutButton setTitle:@"Dark" forState:UIControlStateNormal];
        }
        [_aboutButton layoutIfNeeded];
    }];
    if(darkMode) _aboutButton.titleLabel.textColor = [UIColor orangeColor];
    else _aboutButton.titleLabel.textColor = coolerBlueColor;
    _welcomeWebView.hidden = NO;
    _depictionWebView.hidden = YES;
    if(darkMode) _homeImage.tintColor = [UIColor orangeColor];
    else _homeImage.tintColor = coolerBlueColor;
    if(darkMode) _homeLabel.textColor = [UIColor orangeColor];
    else _homeLabel.textColor = coolerBlueColor;
    _sourcesImage.tintColor = [UIColor grayColor];
    _sourcesLabel.textColor = [UIColor grayColor];
    _manageImage.tintColor = [UIColor grayColor];
    _manageLabel.textColor = [UIColor grayColor];
    _tableView.hidden = YES;
    _tableView2.hidden = YES;
    _tableView3.hidden = YES;
    _searchField.hidden = YES;
}
- (void)sourcesAction {
    _nameLabel.text = @"Sources";
    _dateLabel.hidden = YES;
    [UIView performWithoutAnimation:^{
        [_aboutButton setTitle:@"Manage" forState:UIControlStateNormal];
        [_aboutButton layoutIfNeeded];
    }];
    if(darkMode) _aboutButton.titleLabel.textColor = [UIColor orangeColor];
    else _aboutButton.titleLabel.textColor = coolerBlueColor;
    _welcomeWebView.hidden = YES;
    _depictionWebView.hidden = YES;
    _homeImage.tintColor = [UIColor grayColor];
    _homeLabel.textColor = [UIColor grayColor];
    if(darkMode) _sourcesImage.tintColor = [UIColor orangeColor];
    else _sourcesImage.tintColor = coolerBlueColor;
    if(darkMode) _sourcesLabel.textColor = [UIColor orangeColor];
    else _sourcesLabel.textColor = coolerBlueColor;
    _manageImage.tintColor = [UIColor grayColor];
    _manageLabel.textColor = [UIColor grayColor];
    _tableView.hidden = YES;
    _tableView2.hidden = NO;
    _tableView3.hidden = NO;
    [self.view bringSubviewToFront:_tableView3];
    //_tableView3.hidden = NO;
    [self.view bringSubviewToFront:_tableView3];
    _searchField.hidden = NO;
    if(!darkMode) _searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
    else _searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: [UIColor orangeColor]}];
    [self.view bringSubviewToFront:_navigationView];
}
- (void)manageAction {
    _nameLabel.text = @"Manage";
    _dateLabel.hidden = NO;
    [UIView performWithoutAnimation:^{
        [_aboutButton setTitle:@"Backup" forState:UIControlStateNormal];
        [_aboutButton layoutIfNeeded];
    }];
    if(darkMode) _aboutButton.titleLabel.textColor = [UIColor orangeColor];
    else _aboutButton.titleLabel.textColor = coolerBlueColor;
    _welcomeWebView.hidden = YES;
    _depictionWebView.hidden = YES;
    _homeImage.tintColor = [UIColor grayColor];
    _homeLabel.textColor = [UIColor grayColor];
    _sourcesImage.tintColor = [UIColor grayColor];
    _sourcesLabel.textColor = [UIColor grayColor];
    if(darkMode) _manageImage.tintColor = [UIColor orangeColor];
    else _manageImage.tintColor = coolerBlueColor;
    if(darkMode) _manageLabel.textColor = [UIColor orangeColor];
    else _manageLabel.textColor = coolerBlueColor;
    _tableView.hidden = NO;
    _tableView2.hidden = YES;
    _tableView3.hidden = YES;
    _searchField.hidden = YES;
    [self.view bringSubviewToFront:_navigationView];
}

#pragma mark - Small but useful bits of code

- (void)messageWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    [alert release];
    _aboutButton.titleLabel.textColor = coolerBlueColor;
}

- (void)makeViewRound:(UIView *)view withRadius:(int)radius {
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = radius;
}

#pragma mark - Search methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.text.length < 4) {
        [self.view endEditing:YES];
        [self messageWithTitle:@"Sorry" message:@"This is too short for Icy to search. Please enter three or more symbols."];
        return YES;
    }
    NSArray *repos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" error:NULL];
    for (id repo in repos) {
        NSString *fullURL = nil;
        if([repo rangeOfString:@".bz2"].location != NSNotFound) continue;
        if([repo isEqualToString:@"ModMyi"]) fullURL = @"http://modmyi.saurik.com/";
        else if ([repo isEqualToString:@"Zodttd"]) fullURL = @"http://cydia.zodttd.com/repo/cydia/";
        else if([repo isEqualToString:@"Saurik"]) fullURL = @"http://apt.saurik.com/";
        else if([repo isEqualToString:@"BigBoss"]) fullURL = @"http://apt.thebigboss.org/repofiles/cydia/";
        else fullURL = [_sourceLinks objectAtIndex:[_sources indexOfObject:repo]];
        if(![[fullURL substringFromIndex:fullURL.length - 1] isEqualToString:@"/"]) fullURL = [fullURL stringByAppendingString:@"/"];
        [self searchForPackage:_searchField.text inRepo:[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@",repo] withFullURLString:fullURL];
    }
    [_tableView2 reloadData];
    _tableView3.hidden = YES;
    [self.view endEditing:YES];
    return YES;
}

- (void)searchForPackage:(NSString *)package inRepo:(NSString *)repo withFullURLString:(NSString *)fullURL {
    char str[999];
    const char *filename = [repo UTF8String];
    FILE *file = fopen(filename, "r");
    BOOL shouldAdd = NO;
    NSString *lastDesc = nil;
    NSString *lastDepiction = nil;
    NSString *lastFilename = nil;
    NSString *lastName = nil;
    while(fgets(str, 999, file) != NULL) {
        if(strstr(str, [package UTF8String]) && strstr(str, "Name:")) shouldAdd = YES;
        if(strstr(str, "Description:")) lastDesc = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Description: " withString:@""];
        if(strstr(str, "Depiction:")) lastDepiction = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Depiction: " withString:@""];
        if(strstr(str, "Filename:")) lastFilename = [NSString stringWithFormat:@"%@%@",fullURL,[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Filename: " withString:@""]];
        if(strstr(str, "Name:")) lastName = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Name: " withString:@""];
        if(strlen(str) < 2 && shouldAdd) {
            [_searchNames addObject:lastName];
            [_searchDescs addObject:lastDesc];
            [_searchDepictions addObject:lastDepiction];
            lastFilename = [lastFilename stringByReplacingOccurrencesOfString:@" " withString:@""];
            lastFilename = [lastFilename stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [_searchFilenames addObject:lastFilename];
            shouldAdd = NO;
        }
    }
    fclose(file);
}

- (void)showDepictionForPackageWithIndexPath:(NSIndexPath *)indexPath {
    packageIndex = (int)indexPath.row;
    [_aboutButton setTitle:@"Install" forState:UIControlStateNormal];
    NSString *depictionString = [_searchDepictions objectAtIndex:indexPath.row];
    depictionString = [depictionString stringByReplacingOccurrencesOfString:@" " withString:@""];
    depictionString = [depictionString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [_depictionWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:depictionString]]];
    _depictionWebView.hidden = NO;
    [self.view bringSubviewToFront:_depictionWebView];
    [self.view bringSubviewToFront:_navigationView];
}

#pragma mark - UI Orientation methods

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        [self changeToPortrait];
    }
    else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        [self changeToLandscape];
    }
}

- (void)changeToPortrait {
    _aboutButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 120,55,75,30);
    _nameLabel.frame = CGRectMake(26,50,[UIScreen mainScreen].bounds.size.width,40);
    _dateLabel.frame = CGRectMake(26,26,[UIScreen mainScreen].bounds.size.width,20);
    _welcomeWebView.frame = CGRectMake(0,120,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 200);
    _navigationView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 75, [UIScreen mainScreen].bounds.size.width, 75);
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
    _aboutButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - 120,55,75,30);
    _nameLabel.frame = CGRectMake(26,50,[UIScreen mainScreen].bounds.size.height,40);
    _dateLabel.frame = CGRectMake(26,26,[UIScreen mainScreen].bounds.size.height,20);
    _welcomeWebView.frame = CGRectMake(0,120,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 200);
    _navigationView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.width - 75, [UIScreen mainScreen].bounds.size.height, 75);
    _homeImage.frame = CGRectMake(30,10,32,32);
    _homeLabel.frame = CGRectMake(27,45,40,10);
    _sourcesImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.height / 2 - 16, 10, 32, 32);
    _sourcesLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.height / 2 - 25,45,50,10);
    _manageImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - 62,10,32,32);
    _manageLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - 70,40,50,20);
    _tableView.frame = CGRectMake(13,100,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 200);
    _tableView2.frame = CGRectMake(13,140,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 220);
    _searchField.frame = CGRectMake(20,120,[UIScreen mainScreen].bounds.size.height - 40,20);
}

#pragma mark - Random backend methods

- (long)statusCodeOfFileAtURL:(NSString *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    if([url rangeOfString:@"yourepo"].location != NSNotFound) {
        [mutableRequest setValue:@"Telesphoreo APT-HTTP/1.0.592" forHTTPHeaderField:@"User-Agent"];
        [mutableRequest setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"X-Firmware"];
        [mutableRequest setValue:_deviceModel forHTTPHeaderField:@"X-Machine"];
        [mutableRequest setValue:[self uniqueDeviceID] forHTTPHeaderField:@"X-Unique-ID"];
    }
    [NSURLConnection sendSynchronousRequest:mutableRequest returningResponse:&response error:&error];
    if(error) NSLog(@"Status code: %ld\nError: %@",(long)response.statusCode,[error localizedDescription]);
    return (long)response.statusCode;
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
        [self runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze"] withArguments:@[@"-i", @"/var/mobile/Media/downloaded.deb"] errors:NO];
        [self reload];
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Media/downloaded.deb" error:nil];
        _nameLabel.text = @"Done";
    } else if([_filename rangeOfString:@".bz2"].location != NSNotFound) for (id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos/" error:nil]) bunzip_one([[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@",object] UTF8String], [[[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@",object] stringByReplacingOccurrencesOfString:@".bz2" withString:@""] UTF8String]);
}

- (void)downloadWithProgressAndURLString:(NSString *)urlString saveFilename:(NSString *)filename {
    _filename = filename;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    //if([urlString rangeOfString:@"yourepo"].location != NSNotFound) {
        [request setValue:@"Telesphoreo APT-HTTP/1.0.592" forHTTPHeaderField:@"User-Agent"];
        [request setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"X-Firmware"];
        [request setValue:_deviceModel forHTTPHeaderField:@"X-Machine"];
        [request setValue:[self uniqueDeviceID] forHTTPHeaderField:@"X-Unique-ID"];
    //}
    self.connectionManager = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)downloadFileFromURLString:(NSString *)urlString saveFilename:(NSString *)filename {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    if([urlString rangeOfString:@"yourepo"].location != NSNotFound) config.HTTPAdditionalHeaders = @{@"User-Agent": @"Telesphoreo APT-HTTP/1.0.592", @"X-Firmware": [[UIDevice currentDevice] systemVersion], @"X-Machine": _deviceModel, @"X-Unique-ID": [self uniqueDeviceID]};
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            return;
        }
        [data writeToFile:[NSString stringWithFormat:@"/var/mobile/Media/Icy/%@",filename] atomically:YES];
        // Fallback: sometimes the above code does not seem to work, so we use the simplest way of downloading files
        if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/var/mobile/Media/Icy/%@",filename]]) {
            NSData *fallbackData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            if(fallbackData) [fallbackData writeToFile:[NSString stringWithFormat:@"/var/mobile/Media/Icy/%@",filename] atomically:YES];
        }
        char cfilename[999];
        snprintf(cfilename, sizeof(cfilename), "/var/mobile/Media/Icy/%s", [filename UTF8String]);
        char coutname[999];
        snprintf(coutname, sizeof(coutname), "/var/mobile/Media/Icy/%s", [[filename stringByReplacingOccurrencesOfString:@".bz2" withString:@""] UTF8String]);
        bunzip_one(cfilename, coutname);
    }];
    [task resume];
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
