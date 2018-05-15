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
#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSURLConnection *connectionManager;
@property (strong, nonatomic) NSMutableData *downloadedMutableData;
@property (strong, nonatomic) NSURLResponse *urlResponse;

@end
#define coolerBlueColor [UIColor colorWithRed:0.00 green:0.52 blue:1.00 alpha:1.0];
@implementation ViewController
UIButton *aboutButton;
UILabel *nameLabel;
UILabel *descLabel;
UIWebView *welcomeWebView;
UIWebView *depictionWebView;
UIView *navigationView;
UIImageView *homeImage;
UIImageView *homeImageSEL;
UIImageView *sourcesImage;
UIImageView *sourcesImageSEL;
UIImageView *manageImage;
UIImageView *manageImageSEL;
UILabel *homeLabel;
UILabel *sourcesLabel;
UILabel *manageLabel;
UITextField *searchField;
UITableView *tableView;
UITableView *tableView2;
UIView *loadingView;
UITextView *loadingArea;
UIProgressView *progressView;
NSMutableArray *packageIDs;
NSMutableArray *packageNames;
NSMutableArray *packageImages;
NSMutableArray *packageIcons;
NSMutableArray *searchNames;
NSMutableArray *searchDescs;
NSMutableArray *searchDepictions;
NSMutableArray *searchFilenames;
NSString *filename;
BOOL darkMode = NO;
int packageIndex;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Get value of darkMode
    darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"];
    // Stuff for downloading with progress
    self.downloadedMutableData = [[NSMutableData alloc] init];
    // The button at the right
    aboutButton = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 120,33,75,30)];
    aboutButton.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    if(darkMode) {
        [aboutButton setTitle:@"Light" forState:UIControlStateNormal];
    } else {
        [aboutButton setTitle:@"Dark" forState:UIControlStateNormal];
    }
    aboutButton.titleLabel.textColor = coolerBlueColor;
    [aboutButton addTarget:self action:@selector(about) forControlEvents:UIControlEventTouchUpInside];
    [self makeViewRound:aboutButton withRadius:5];
    [self.view addSubview:aboutButton];
    // The top label
    nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(26,26,[UIScreen mainScreen].bounds.size.width,40)];
    nameLabel.text = @"Icy Installer";
    [nameLabel setFont:[UIFont boldSystemFontOfSize:30]];
    [self.view addSubview:nameLabel];
    // The less top but still top label
    descLabel = [[UILabel alloc]initWithFrame:CGRectMake(26,76,[UIScreen mainScreen].bounds.size.width,20)];
    descLabel.text = @"Where the possibilities are endless";
    [descLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.view addSubview:descLabel];
    // The homepage website
    welcomeWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,120,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 180)];
    [welcomeWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://artikus.pe.hu/Icy.html"]]];
    [self.view addSubview:welcomeWebView];
    // The depiction webview
    depictionWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,120,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 180)];
    [self.view addSubview:depictionWebView];
    depictionWebView.hidden = YES;
    // Change the user agent to a desktop one, so when we view depictions "Open in Cydia" doesn't appear
    NSDictionary *dictionary = @{@"UserAgent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1 Safari/605.1.15"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Navigation, I guess
    navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 60, [UIScreen mainScreen].bounds.size.width, 60)];
    UIView *border = [[UIView alloc]initWithFrame:CGRectMake(0, 0, navigationView.frame.size.width, 1)];
    border.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    [navigationView addSubview:border];
    [self.view addSubview:navigationView];
    // The homeImage
    homeImageSEL = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/HomeSEL.png"]];
    homeImageSEL.frame = CGRectMake(30,10,32,32);
    [navigationView addSubview:homeImageSEL];
    homeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/Home.png"]];
    homeImage.frame = CGRectMake(30,10,32,32);
    homeImage.userInteractionEnabled = YES;
    homeImage.hidden = YES;
    [navigationView addSubview:homeImage];
    // The home label
    homeLabel = [[UILabel alloc] initWithFrame:CGRectMake(27,45,40,10)];
    homeLabel.textAlignment = NSTextAlignmentCenter;
    homeLabel.textColor = coolerBlueColor;
    homeLabel.text = @"Home";
    [homeLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [navigationView addSubview:homeLabel];
    // The sourcesImage
    sourcesImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/Sources.png"]];
    sourcesImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 16, 10, 32, 32);
    sourcesImage.userInteractionEnabled = YES;
    [navigationView addSubview:sourcesImage];
    sourcesImageSEL = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/SourcesSEL.png"]];
    sourcesImageSEL.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 16, 10, 32, 32);
    sourcesImageSEL.hidden = YES;
    [navigationView addSubview:sourcesImageSEL];
    // The sources label
    sourcesLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 25,45,50,10)];
    sourcesLabel.textColor = [UIColor grayColor];
    sourcesLabel.textAlignment = NSTextAlignmentCenter;
    sourcesLabel.text = @"Sources";
    [sourcesLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [navigationView addSubview:sourcesLabel];
    // The manageImage
    manageImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/Installed.png"]];
    manageImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 62,10,32,32);
    manageImage.userInteractionEnabled = YES;
    [navigationView addSubview:manageImage];
    manageImageSEL = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/InstalledSEL.png"]];
    manageImageSEL.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 62,10,32,32);
    manageImageSEL.hidden = YES;
    [navigationView addSubview:manageImageSEL];
    // The manage label
    manageLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 70,40,50,20)];
    manageLabel.textColor = [UIColor grayColor];
    manageLabel.textAlignment = NSTextAlignmentCenter;
    manageLabel.text = @"Manage";
    [manageLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [navigationView addSubview:manageLabel];
    // Gesture recognizers
    UITapGestureRecognizer *homeGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(homeAction)];
    [homeImage addGestureRecognizer:homeGesture];
    UITapGestureRecognizer *sourcesGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sourcesAction)];
    [sourcesImage addGestureRecognizer:sourcesGesture];
    UITapGestureRecognizer *manageGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(manageAction)];
    [manageImage addGestureRecognizer:manageGesture];
    // Table views
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(13,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 160) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView2 = [[UITableView alloc] initWithFrame:CGRectMake(13,160,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 220) style:UITableViewStylePlain];
    tableView2.delegate = self;
    tableView2.dataSource = self;
    tableView2.backgroundColor = [UIColor whiteColor];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView2 setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    [self.view addSubview:tableView2];
    tableView.hidden = YES;
    tableView2.hidden = YES;
    // Search texfield
    searchField = [[UITextField alloc]initWithFrame:CGRectMake(20,120,[UIScreen mainScreen].bounds.size.width - 40,30)];
    searchField.placeholder = @"Search";
    searchField.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    searchField.textAlignment = NSTextAlignmentCenter;
    searchField.returnKeyType = UIReturnKeySearch;
    searchField.delegate = self;
    searchField.hidden = YES;
    [self makeViewRound:searchField withRadius:5];
    [self.view addSubview:searchField];
    // Loading view
    loadingView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    if(darkMode) loadingView.backgroundColor = [UIColor blackColor];
    else loadingView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:loadingView];
    // Gradient
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(30,[UIScreen mainScreen].bounds.size.height / 2 - 160,[UIScreen mainScreen].bounds.size.width - 60,360)];
    [self makeViewRound:gradientView withRadius:10];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)[UIColor colorWithRed:0.16 green:0.81 blue:0.93 alpha:1.0].CGColor, (id)[UIColor colorWithRed:0.15 green:0.48 blue:0.78 alpha:1.0].CGColor];
    gradient.frame = gradientView.bounds;
    if(!darkMode) [gradientView.layer insertSublayer:gradient atIndex:0];
    [loadingView addSubview:gradientView];
    // Top label
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, 50)];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"Icy Installer";
    [loadingLabel setFont:[UIFont boldSystemFontOfSize:30]];
    if(darkMode) {
        loadingLabel.textColor = [UIColor whiteColor];
    } else {
        loadingLabel.textColor = [UIColor blackColor];
    }
    [loadingView addSubview:loadingLabel];
    // Loading textarea
    loadingArea = [[UITextView alloc] initWithFrame:CGRectMake(0, 50, gradientView.bounds.size.width, 330)];
    loadingArea.scrollEnabled = NO;
    loadingArea.textColor = [UIColor whiteColor];
    loadingArea.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0];
    loadingArea.textAlignment = NSTextAlignmentCenter;
    [loadingArea setFont:[UIFont boldSystemFontOfSize:15]];
    loadingArea.text = @"Welcome to Icy Installer 3.1!\nMade by ArtikusHG.\nLoading packages....";
    [gradientView addSubview:loadingArea];
    // Progress spinwheel
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.frame = CGRectMake(gradientView.bounds.size.width / 2 - 10,20,20,20);
    [gradientView addSubview:spinner];
    [spinner startAnimating];
    // Progress View
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progressView.frame = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,10);
    progressView.progress = 0;
    [self.view addSubview:progressView];
    if(darkMode) {
        [self switchToDarkMode];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self loadStuff];
        [self redirectLogToDocuments];
    });
}

#pragma mark - Loading methods

- (void)redirectLogToDocuments {
    NSString *pathForLog = @"/var/mobile/Media/log.txt";
    freopen([pathForLog cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

- (void)loadStuff {
    // Initialize arrays
    searchNames = [[NSMutableArray alloc] init];
    searchDescs = [[NSMutableArray alloc] init];
    searchDepictions = [[NSMutableArray alloc] init];
    searchFilenames = [[NSMutableArray alloc] init];
    packageIcons = [[NSMutableArray alloc] init];
    BOOL isDirectory;
    // Check for needed directories
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy" isDirectory:&isDirectory]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy" withIntermediateDirectories:NO attributes:nil error:nil];
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/Repos" isDirectory:&isDirectory]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" withIntermediateDirectories:NO attributes:nil error:nil];
    // Get package list and put to table view
    packageNames = [[NSMutableArray alloc] init];
    packageIDs = [[NSMutableArray alloc] init];
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    NSString *icon = nil;
    NSString *lastID = nil;
    while(fgets(str, 999, file) != NULL) {
        if(strstr(str, "Package:"))  [packageIDs addObject:[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Package: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
        if(strstr(str, "Name:")) [packageNames addObject:[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Name: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
        if(strstr(str, "Section:")) {
            icon = [NSString stringWithFormat:@"/Applications/IcyInstaller3.app/icons/%@.png",[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Section: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
            if([icon rangeOfString:@" "].location != NSNotFound) icon = [NSString stringWithFormat:@"%@.png",[icon substringToIndex:[icon rangeOfString:@" "].location]];
            if(![[NSFileManager defaultManager] fileExistsAtPath:icon]) icon = @"/Applications/IcyInstaller3.app/icons/Home.png";
        }
        if(strstr(str, "Icon:")) icon = [[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Icon: file://" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if(strlen(str) < 2) {
            lastID = [packageIDs lastObject];
            if(packageIDs.count > packageNames.count) [packageNames addObject:lastID];
            NSString *lastObject = [packageNames lastObject];
            [packageNames sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [packageIDs removeLastObject];
            [packageIDs insertObject:lastID atIndex:[packageNames indexOfObject:lastObject]];
            [packageIcons insertObject:icon atIndex:[packageNames indexOfObject:lastObject]];
        }
    }
    loadingArea.text = [loadingArea.text stringByAppendingString:@"Finished loading packages.\nLaunching Icy..."];
    [tableView reloadData];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        loadingView.frame  = CGRectMake(0,-[UIScreen mainScreen].bounds.size.height - 20,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    } completion:^(BOOL finished) {
        if(darkMode) [welcomeWebView stringByEvaluatingJavaScriptFromString:@"document.body.style.background = 'black'; var p = document.getElementsByTagName('p'); for (var i = 0; i < p.length; i++) { p[i].style.color = 'white'; }"];
        }];
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    if(theTableView == tableView) {
        return packageNames.count;
    } else if(theTableView == tableView2) {
        return searchNames.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = (UITableViewCell *)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    if(theTableView == tableView) {
        cell.textLabel.text = [packageNames objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [packageIDs objectAtIndex:indexPath.row];
        UIImage *icon = [UIImage imageWithContentsOfFile:[packageIcons objectAtIndex:indexPath.row]];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(40,40), NO, [UIScreen mainScreen].scale);
        [icon drawInRect:CGRectMake(0,0,40,40)];
        icon = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self makeViewRound:cell.imageView withRadius:10];
        cell.imageView.image = icon;
    } else if(theTableView == tableView2) {
        cell.textLabel.text = [searchNames objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [searchDescs objectAtIndex:indexPath.row];
    } else cell.textLabel.text = @"Some stupid error happened";
    return cell;
}

NSString *packageName;
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(theTableView == tableView) [self packageInfoWithIndexPath:indexPath];
        else if(theTableView == tableView2) [self showDepictionForPackageWithIndexPath:indexPath];
        else [self messageWithTitle:@"Error" message:@"Literally an error. Go report this to @ArtikusHG."];
}

#pragma mark - Package management methods

UIView *infoView;
UITextView *infoText;
- (void)packageInfoWithIndexPath:(NSIndexPath *)indexPath {
    nameLabel.text = @"Info";
    descLabel.text = [NSString stringWithFormat:@"%@",[packageIDs objectAtIndex:indexPath.row]];
    descLabel.text = [descLabel.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *searchString = [NSString stringWithFormat:@"Package: %@",descLabel.text];
    NSString *info = @"";
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    int shouldWrite = 0;
    const char *search = [searchString UTF8String];
    while(fgets(str, 999, file) != NULL) {
        if(strstr(str, search)) {
            shouldWrite = 1;
        }
        if(strlen(str) < 2 && shouldWrite == 1) {
            break;
        }
        if(shouldWrite == 1 && !strstr(str, "Priority:") && !strstr(str, "Status:") && !strstr(str, "Installed-Size:") && !strstr(str, "Maintainer:") && !strstr(str, "Architecture:") && !strstr(str, "Replaces:") && !strstr(str, "Provides:") && !strstr(str, "Homepage:") && !strstr(str, "Depiction:") && !strstr(str, "Depiction:") && !strstr(str, "Sponsor:") && !strstr(str, "dev:") && !strstr(str, "Tag:") && !strstr(str, "Icon:") && !strstr(str, "Website:")) {
            info = [NSString stringWithFormat:@"%@%@",info,[NSString stringWithCString:str encoding:NSASCIIStringEncoding]];
        }
    }
    UIView *infoTextView = [[UIView alloc] initWithFrame:CGRectMake(20,10,[UIScreen mainScreen].bounds.size.width - 40,[UIScreen mainScreen].bounds.size.height / 2 - 20)];
    [self makeViewRound:infoTextView withRadius:10];
    infoView = [[UIView alloc] initWithFrame:CGRectMake(0,-[UIScreen mainScreen].bounds.size.height - 160,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 160)];
    [infoView addSubview:infoTextView];
    [self.view addSubview:infoView];
    infoText = [[UITextView alloc] initWithFrame:infoTextView.bounds];
    infoText.editable = NO;
    infoText.scrollEnabled = YES;
    infoText.text = info;
    infoText.textColor = [UIColor whiteColor];
    infoText.backgroundColor = [UIColor clearColor];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)[UIColor colorWithRed:0.16 green:0.81 blue:0.93 alpha:1.0].CGColor, (id)[UIColor colorWithRed:0.15 green:0.48 blue:0.78 alpha:1.0].CGColor];
    gradient.frame = infoTextView.bounds;
    if(darkMode) {
        infoView.backgroundColor = [UIColor blackColor];
        infoText.backgroundColor = [UIColor blackColor];
    } else {
        infoView.backgroundColor = [UIColor whiteColor];
        [infoTextView.layer insertSublayer:gradient atIndex:0];
    }
    [infoText setFont:[UIFont boldSystemFontOfSize:15]];
    [self makeViewRound:infoText withRadius:10];
    [infoTextView addSubview:infoText];
    UIButton *dismiss = [[UIButton alloc] initWithFrame:CGRectMake(20,infoView.bounds.size.height - 50,[UIScreen mainScreen].bounds.size.width - 40,40)];
    dismiss.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    [dismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
    dismiss.layer.masksToBounds = YES;
    dismiss.layer.cornerRadius = 10;
    [dismiss.titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
    dismiss.titleLabel.textColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    [dismiss addTarget:self action:@selector(dismissInfo) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:dismiss];
    UIButton *remove = [[UIButton alloc] initWithFrame:CGRectMake(20,infoView.bounds.size.height - 100,[UIScreen mainScreen].bounds.size.width - 40,40)];
    remove.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.1];
    [remove setTitle:@"Remove" forState:UIControlStateNormal];
    remove.layer.masksToBounds = YES;
    remove.layer.cornerRadius = 10;
    [remove.titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
    remove.titleLabel.textColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    [remove addTarget:self action:@selector(removePackage) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:remove];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        infoView.frame  = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 160);
    } completion:nil];
}

- (void)dismissInfo {
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        infoView.frame  = CGRectMake(0,-[UIScreen mainScreen].bounds.size.height - 100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 160);
    } completion:nil];
    [self manageAction];
}

- (void)removePackage {
    pid_t pid;
    int status;
    const char *argv[] = {"freeze", "-r", [descLabel.text UTF8String], NULL};
    const char *path[] = {"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games", NULL};
    posix_spawn(&pid, "/usr/bin/freeze", NULL, NULL, (char**)argv, (char**)path);
    waitpid(pid, &status, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self reload];
    });
}

#pragma mark - Reload methods
UIView *reloadView;
UIView *darkenView;
- (void)reload {
    darkenView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    darkenView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:darkenView];
    reloadView = [[UIView alloc] initWithFrame:CGRectMake(30,-230,[UIScreen mainScreen].bounds.size.width - 60,230)];
    if(darkMode) reloadView.backgroundColor = [UIColor blackColor];
    else reloadView.backgroundColor = [UIColor whiteColor];
    [self makeViewRound:reloadView withRadius:10];
    [self.view addSubview:reloadView];
    UIButton *respring = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, reloadView.bounds.size.width - 40, 50)];
    [self makeViewRound:respring withRadius:10];
    respring.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.1];
    [respring setTitle:@"Respring" forState:UIControlStateNormal];
    [respring setTitleColor:[[UIColor greenColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [respring.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [respring addTarget:self action:@selector(respring) forControlEvents:UIControlEventTouchUpInside];
    [reloadView addSubview:respring];
    UIButton *uicache = [[UIButton alloc] initWithFrame:CGRectMake(20, 90, reloadView.bounds.size.width - 40, 50)];
    [self makeViewRound:uicache withRadius:10];
    uicache.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    [uicache setTitle:@"Reload cache" forState:UIControlStateNormal];
    [uicache setTitleColor:[[UIColor blueColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [uicache.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [uicache addTarget:self action:@selector(uicache) forControlEvents:UIControlEventTouchUpInside];
    [reloadView addSubview:uicache];
    UIButton *dismiss = [[UIButton alloc] initWithFrame:CGRectMake(20, 160, reloadView.bounds.size.width - 40, 50)];
    [self makeViewRound:dismiss withRadius:10];
    dismiss.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.1];
    [dismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
    [dismiss setTitleColor:[[UIColor redColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [dismiss.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [dismiss addTarget:self action:@selector(dismissReload) forControlEvents:UIControlEventTouchUpInside];
    [reloadView addSubview:dismiss];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        reloadView.frame = CGRectMake(30,[UIScreen mainScreen].bounds.size.height / 2 - 115,[UIScreen mainScreen].bounds.size.width - 60,230);
    } completion:nil];
}

- (void)uicache {
    pid_t pid;
    int status;
    const char *argv[] = {"uicache", NULL};
    posix_spawn(&pid, "/usr/bin/uicache", NULL, NULL, (char* const*)argv, NULL);
    waitpid(pid, &status, 0);
}

- (void)respring {
    pid_t pid;
    int status;
    const char *argv[] = {"killall", "-9", "SpringBoard", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)argv, NULL);
    waitpid(pid, &status, 0);
}

- (void)dismissReload {
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        reloadView.frame = CGRectMake(30,-230,[UIScreen mainScreen].bounds.size.width - 60,230);
        } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3 animations:^ {
            [darkenView setAlpha:0];
        }];
    }];
}

#pragma mark - Manage methods

UIView *manageView;
- (void)manage {
    darkenView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    darkenView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:darkenView];
    manageView = [[UIView alloc] initWithFrame:CGRectMake(30,-230,[UIScreen mainScreen].bounds.size.width - 60,230)];
    if(darkMode) manageView.backgroundColor = [UIColor blackColor];
    else manageView.backgroundColor = [UIColor whiteColor];
    [self makeViewRound:manageView withRadius:10];
    [self.view addSubview:manageView];
    UIButton *refresh = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, manageView.bounds.size.width - 40, 50)];
    [self makeViewRound:refresh withRadius:10];
    refresh.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.1];
    [refresh setTitle:@"Refresh sources" forState:UIControlStateNormal];
    [refresh setTitleColor:[[UIColor greenColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [refresh.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [refresh addTarget:self action:@selector(refreshSources) forControlEvents:UIControlEventTouchUpInside];
    [manageView addSubview:refresh];
    UIButton *update = [[UIButton alloc] initWithFrame:CGRectMake(20, 90, manageView.bounds.size.width - 40, 50)];
    [self makeViewRound:update withRadius:10];
    update.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    [update setTitle:@"Scan updates" forState:UIControlStateNormal];
    [update setTitleColor:[[UIColor blueColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [update.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [update addTarget:self action:@selector(updatePackages) forControlEvents:UIControlEventTouchUpInside];
    [manageView addSubview:update];
    UIButton *dismiss = [[UIButton alloc] initWithFrame:CGRectMake(20, 160, manageView.bounds.size.width - 40, 50)];
    [self makeViewRound:dismiss withRadius:10];
    dismiss.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.1];
    [dismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
    [dismiss setTitleColor:[[UIColor redColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [dismiss.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [dismiss addTarget:self action:@selector(dismissManage) forControlEvents:UIControlEventTouchUpInside];
    [manageView addSubview:dismiss];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        manageView.frame = CGRectMake(30,[UIScreen mainScreen].bounds.size.height / 2 - 115,[UIScreen mainScreen].bounds.size.width - 60,230);
    } completion:nil];
}

- (void)dismissManage {
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        manageView.frame = CGRectMake(30,-230,[UIScreen mainScreen].bounds.size.width - 60,230);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3 animations:^ {
            [darkenView setAlpha:0];
        }];
    }];
}

- (void)refreshSources {
    // BigBoss
    NSString *bigboss = @"http://apt.thebigboss.org/repofiles/cydia/dists/stable/main/binary-iphoneos-arm/Packages.bz2";
     NSURL *bigbossURL = [NSURL URLWithString:bigboss];
     NSData *bigbossURLData = [NSData dataWithContentsOfURL:bigbossURL];
     if (bigbossURLData) [bigbossURLData writeToFile:@"/var/mobile/Media/Icy/Repos/BigBoss.bz2" atomically:YES];
     // ModMyi
     NSString *modmyi = @"http://apt.modmyi.com/dists/stable/main/binary-iphoneos-arm/Packages.bz2";
     NSURL *modmyiURL = [NSURL URLWithString:modmyi];
     NSData *modmyiURLData = [NSData dataWithContentsOfURL:modmyiURL];
     if (modmyiURLData) {
     [modmyiURLData writeToFile:@"/var/mobile/Media/Icy/Repos/ModMyi.bz2" atomically:YES];
     }
     // Zodttd and MacCiti
     NSString *zodttd = @"http://zodttd.saurik.com/repo/cydia/dists/stable/main/binary-iphoneos-arm/Packages.bz2";
     NSURL *zodttdURL = [NSURL URLWithString:zodttd];
     NSData *zodttdURLData = [NSData dataWithContentsOfURL:zodttdURL];
     if (zodttdURLData) {
     [zodttdURLData writeToFile:@"/var/mobile/Media/Icy/Repos/Zodttd.bz2" atomically:YES];
     }
     // Saurik's repo
     NSString *saurik = @"http://apt.saurik.com/cydia/Packages.bz2";
     NSURL *saurikURL = [NSURL URLWithString:saurik];
     NSData *saurikURLData = [NSData dataWithContentsOfURL:saurikURL];
     if (saurikURLData) [saurikURLData writeToFile:@"/var/mobile/Media/Icy/Repos/Saurik.bz2" atomically:YES];
    // Unpack the files
    bunzip_one("/var/mobile/Media/Icy/Repos/BigBoss.bz2", "/var/mobile/Media/Icy/Repos/BigBoss");
    bunzip_one("/var/mobile/Media/Icy/Repos/Zodttd.bz2", "/var/mobile/Media/Icy/Repos/Zodttd");
    bunzip_one("/var/mobile/Media/Icy/Repos/ModMyi.bz2", "/var/mobile/Media/Icy/Repos/ModMyi");
    bunzip_one("/var/mobile/Media/Icy/Repos/Saurik.bz2", "/var/mobile/Media/Icy/Repos/Saurik");
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
        fprintf(stderr, "E: BZ2_bzReadOpen: %d\n", bzError);
        return -1;
    }
    
    while (bzError == BZ_OK) {
        int nread = BZ2_bzRead(&bzError, bzf, buf, sizeof buf);
        if (bzError == BZ_OK || bzError == BZ_STREAM_END) {
            size_t nwritten = fwrite(buf, 1, nread, stdout);
            fprintf(outfile, "%s", buf);
            if (nwritten != (size_t) nread) {
                fprintf(stderr, "E: short write\n");
                return -1;
            }
        }
    }
    
    if (bzError != BZ_STREAM_END) {
        fprintf(stderr, "E: bzip error after read: %d\n", bzError);
        return -1;
    }
    
    BZ2_bzReadClose(&bzError, bzf);
    unlink(file);
    return 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)about {
    if([aboutButton.currentTitle isEqualToString:@"Dark"]) {
        [aboutButton setTitle:@"Light" forState:UIControlStateNormal];
        [self switchToDarkMode];
    } else if([aboutButton.currentTitle isEqualToString:@"Light"]) {
        [aboutButton setTitle:@"Dark" forState:UIControlStateNormal];
        [self switchToLightMode];
    } else if([aboutButton.currentTitle isEqualToString:@"Install"] && depictionWebView.hidden) {
        [self messageWithTitle:@"Error" message:@"You need to search for a package first."];
    } else if([aboutButton.currentTitle isEqualToString:@"Install"] && !depictionWebView.hidden) {
        nameLabel.text = @"Getting...";
        descLabel.text = @"Downloading and installing...";
        [self downloadWithProgressAndURLString:[searchFilenames objectAtIndex:packageIndex] saveFilename:@"downloaded.deb"];
    } else if([aboutButton.currentTitle isEqualToString:@"Backup"]){
        if([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Backup.txt"]) {
            [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Backup.txt" error:nil];
        }
        FILE *file = fopen("/var/lib/dpkg/status", "r");
        char str[999];
        while(fgets(str, 999, file) != NULL) {
            if(strstr(str, "Name:")) {
                memmove(str, str+6, strlen(str));
                [[NSString stringWithFormat:@"%@%@", [NSString stringWithContentsOfFile:@"/var/mobile/Backup.txt" encoding:NSUTF8StringEncoding error:nil], [NSString stringWithCString:str encoding:NSASCIIStringEncoding]] writeToFile:@"/var/mobile/Backup.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
        }
        [self messageWithTitle:@"Done" message:@"The package backup was saved to /var/mobile/Backup.txt"];
    } else if([aboutButton.currentTitle isEqualToString:@"Manage"]) [self manage];
    else [self messageWithTitle:@"Some random shit happened" message:@"Literally the title."];
}

#pragma mark - Dark/light modes

- (void)switchToDarkMode {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"darkMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    darkMode = YES;
    navigationView.backgroundColor = [UIColor blackColor];
    nameLabel.textColor = [UIColor whiteColor];
    descLabel.textColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor blackColor];
    tableView.backgroundColor = [UIColor blackColor];
    tableView2.backgroundColor = [UIColor blackColor];
    searchField.backgroundColor = [UIColor grayColor];
    searchField.textColor = [UIColor whiteColor];
    infoView.backgroundColor = [UIColor blackColor];
    [welcomeWebView stringByEvaluatingJavaScriptFromString:@"document.body.style.background = 'black'; var p = document.getElementsByTagName('p'); for (var i = 0; i < p.length; i++) { p[i].style.color = 'white'; }"];
    searchField.keyboardAppearance = UIKeyboardAppearanceDark;
}

- (void)switchToLightMode {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"darkMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    darkMode = NO;
    navigationView.backgroundColor = [UIColor whiteColor];
    nameLabel.textColor = [UIColor blackColor];
    descLabel.textColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor whiteColor];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView2.backgroundColor = [UIColor whiteColor];
    searchField.backgroundColor = [UIColor whiteColor];
    searchField.textColor = [UIColor blackColor];
    infoView.backgroundColor = [UIColor whiteColor];
    [welcomeWebView reload];
    searchField.keyboardAppearance = UIKeyboardAppearanceLight;
}

#pragma mark - Navigation methods

- (void)homeAction {
    nameLabel.text = @"Icy Installer";
    descLabel.text = @"Where the possibilities are endless";
    [UIView performWithoutAnimation:^{
        if(darkMode) {
            [aboutButton setTitle:@"Light" forState:UIControlStateNormal];
        } else {
            [aboutButton setTitle:@"Dark" forState:UIControlStateNormal];
        }
        [aboutButton layoutIfNeeded];
    }];
    aboutButton.titleLabel.textColor = coolerBlueColor;
    welcomeWebView.hidden = NO;
    depictionWebView.hidden = YES;
    homeImage.hidden = YES;
    homeImageSEL.hidden = NO;
    homeLabel.textColor = coolerBlueColor;
    sourcesImageSEL.hidden = YES;
    sourcesImage.hidden = NO;
    sourcesLabel.textColor = [UIColor grayColor];
    manageImageSEL.hidden = YES;
    manageImage.hidden = NO;
    manageLabel.textColor = [UIColor grayColor];
    tableView.hidden = YES;
    tableView2.hidden = YES;
    searchField.hidden = YES;
}
- (void)sourcesAction {
    nameLabel.text = @"Sources";
    descLabel.text = @"Search Cydia package sources";
    [UIView performWithoutAnimation:^{
        [aboutButton setTitle:@"Manage" forState:UIControlStateNormal];
        [aboutButton layoutIfNeeded];
    }];
    aboutButton.titleLabel.textColor = coolerBlueColor;
    welcomeWebView.hidden = YES;
    depictionWebView.hidden = YES;
    homeImageSEL.hidden = YES;
    homeImage.hidden = NO;
    homeLabel.textColor = [UIColor grayColor];
    sourcesImageSEL.hidden = NO;
    sourcesImage.hidden = YES;
    sourcesLabel.textColor = coolerBlueColor;
    manageImageSEL.hidden = YES;
    manageImage.hidden = NO;
    manageLabel.textColor = [UIColor grayColor];
    tableView.hidden = YES;
    tableView2.hidden = NO;
    searchField.hidden = NO;
    searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: [UIColor lightTextColor]}];
}
- (void)manageAction {
    nameLabel.text = @"Manage";
    descLabel.text = @"Manage already installed packages";
    [UIView performWithoutAnimation:^{
        [aboutButton setTitle:@"Backup" forState:UIControlStateNormal];
        [aboutButton layoutIfNeeded];
    }];
    aboutButton.titleLabel.textColor = coolerBlueColor;
    welcomeWebView.hidden = YES;
    depictionWebView.hidden = YES;
    homeImageSEL.hidden = YES;
    homeImage.hidden = NO;
    homeLabel.textColor = [UIColor grayColor];
    sourcesImageSEL.hidden = YES;
    sourcesImage.hidden = NO;
    sourcesLabel.textColor = [UIColor grayColor];
    manageImageSEL.hidden = NO;
    manageImage.hidden = YES;
    manageLabel.textColor = coolerBlueColor;
    tableView.hidden = NO;
    tableView2.hidden = YES;
    searchField.hidden = YES;
}

#pragma mark - Small but useful bits of code

- (void)messageWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    [alert release];
    aboutButton.titleLabel.textColor = coolerBlueColor;
}

- (void)dealloc {
    [super dealloc];
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
        if([repo isEqualToString:@"ModMyi"]) fullURL = @"http://modmyi.saurik.com/";
        else if ([repo isEqualToString:@"Zodttd"]) fullURL = @"http://cydia.zodttd.com/repo/cydia/";
        else if([repo isEqualToString:@"Saurik"]) fullURL = @"http://apt.saurik.com/";
        else if([repo isEqualToString:@"BigBoss"]) fullURL = @"http://apt.thebigboss.org/repofiles/cydia/";
        [self searchForPackage:searchField.text inRepo:[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@",repo] withFullURLString:fullURL];
    }
    [tableView2 reloadData];
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
            [searchNames addObject:lastName];
            [searchDescs addObject:lastDesc];
            [searchDepictions addObject:lastDepiction];
            lastFilename = [lastFilename stringByReplacingOccurrencesOfString:@" " withString:@""];
            lastFilename = [lastFilename stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [searchFilenames addObject:lastFilename];
            shouldAdd = NO;
        }
    }
}

- (void)showDepictionForPackageWithIndexPath:(NSIndexPath *)indexPath {
    packageIndex = (int)indexPath.row;
    [aboutButton setTitle:@"Install" forState:UIControlStateNormal];
    NSString *depictionString = [searchDepictions objectAtIndex:indexPath.row];
    depictionString = [depictionString stringByReplacingOccurrencesOfString:@" " withString:@""];
    depictionString = [depictionString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [depictionWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:depictionString]]];
    depictionWebView.hidden = NO;
    [self.view bringSubviewToFront:depictionWebView];
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
    aboutButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 120,33,75,30);
    nameLabel.frame = CGRectMake(26,26,[UIScreen mainScreen].bounds.size.width,40);
    descLabel.frame = CGRectMake(26,76,[UIScreen mainScreen].bounds.size.width,20);
    welcomeWebView.frame = CGRectMake(0,120,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 200);
    navigationView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 75, [UIScreen mainScreen].bounds.size.width, 75);
    homeImage.frame = CGRectMake(30,10,32,32);
    homeLabel.frame = CGRectMake(27,45,40,10);
    sourcesImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 16, 10, 32, 32);
    sourcesLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 25,45,50,10);
    manageImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 62,10,32,32);
    manageLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 70,40,50,20);
    tableView.frame = CGRectMake(13,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 200);
    tableView2.frame = CGRectMake(13,140,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 220);
    searchField.frame = CGRectMake(20,120,[UIScreen mainScreen].bounds.size.width - 40,20);
}

- (void)changeToLandscape {
    aboutButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - 120,33,75,30);
    nameLabel.frame = CGRectMake(26,26,[UIScreen mainScreen].bounds.size.height,40);
    descLabel.frame = CGRectMake(26,76,[UIScreen mainScreen].bounds.size.height,20);
    welcomeWebView.frame = CGRectMake(0,120,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 200);
    navigationView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.width - 75, [UIScreen mainScreen].bounds.size.height, 75);
    homeImage.frame = CGRectMake(30,10,32,32);
    homeLabel.frame = CGRectMake(27,45,40,10);
    sourcesImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.height / 2 - 16, 10, 32, 32);
    sourcesLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.height / 2 - 25,45,50,10);
    manageImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - 62,10,32,32);
    manageLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.height - 70,40,50,20);
    tableView.frame = CGRectMake(13,100,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 200);
    tableView2.frame = CGRectMake(13,140,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 220);
    searchField.frame = CGRectMake(20,120,[UIScreen mainScreen].bounds.size.height - 40,20);
}

#pragma mark - Download progress methods
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.urlResponse = response;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.downloadedMutableData appendData:data];
    progressView.progress = ((100.0/self.urlResponse.expectedContentLength)*self.downloadedMutableData.length)/100;
    if (progressView.progress == 1) {
        progressView.hidden = YES;
    } else {
        progressView.hidden = NO;
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.downloadedMutableData writeToFile:[NSString stringWithFormat:@"/var/mobile/Media/%@",filename] atomically:YES];
    if([filename isEqualToString:@"downloaded.deb"]) {
        pid_t pid1;
        int status1;
        const char *argv1[] = {"freeze", "-i", "--force-depends", "/var/mobile/Media/downloaded.deb", NULL};
        const char *path[] = {"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games", NULL};
        posix_spawn(&pid1, "/usr/bin/freeze", NULL, NULL, (char**)argv1, (char**)path);
        waitpid(pid1, &status1, 0);
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Media/downloaded.deb" error:nil];
        nameLabel.text = @"Done";
        descLabel.text = @"The package was installed";
        [self reload];
    }
}

- (void)downloadWithProgressAndURLString:(NSString *)urlString saveFilename:(NSString *)filename1 {
    filename = filename1;
    self.connectionManager = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 60.0] delegate:self];
}

@end
