//
//  SearchViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/20/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import "SearchViewController.h"
#import "SourcesViewController.h"
#import "ManageViewController.h"
#import "NSTask.h"
@import AVFoundation;

@interface SearchViewController ()

@end

@implementation SearchViewController
UITableView *_searchTableView;
UIWebView *_depictionWebView;
static int _packageIndex;
static NSMutableArray *_searchFilenames;
NSURLConnection *connectionManager;
NSMutableData *downloadedMutableData;
NSURLResponse *urlResponse;
NSString *_filename;
UIProgressView *progressView;
UITextView *progressTextView;
UIView *_dismiss;
UITextField *_searchField;
UIButton *dismiss;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Init download stuff
    downloadedMutableData = [[NSMutableData alloc] init];
    // Initialize arrays
    _searchPackages = [[NSMutableArray alloc] init];
    _searchNames = [[NSMutableArray alloc] init];
    _searchDescs = [[NSMutableArray alloc] init];
    _searchDepictions = [[NSMutableArray alloc] init];
    _searchFilenames = [[NSMutableArray alloc] init];
    // The depiction webview
    _depictionWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 200)];
    _depictionWebView.hidden = YES;
    [self.view addSubview:_depictionWebView];
    progressTextView = [[UITextView alloc] initWithFrame:_depictionWebView.bounds];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        progressTextView.backgroundColor = [UIColor blackColor];
        progressTextView.textColor = [UIColor whiteColor];
    }
    else progressTextView.backgroundColor = [UIColor whiteColor];
    progressTextView.font = [UIFont boldSystemFontOfSize:15];
    progressTextView.hidden = YES;
    progressTextView.editable = NO;
    progressTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [_depictionWebView addSubview:progressTextView];
    _dismiss = [[UIView alloc] initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height - 110,[UIScreen mainScreen].bounds.size.width,50)];
    _dismiss.backgroundColor = [UIColor whiteColor];
    _dismiss.hidden = YES;
    dismiss = [[UIButton alloc] initWithFrame:CGRectMake(20,10,[UIScreen mainScreen].bounds.size.width - 40,40)];
    dismiss.backgroundColor = [UIColor colorWithRed:0.00 green:0.48 blue:1.00 alpha:1.0];
    [dismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
    dismiss.layer.masksToBounds = YES;
    dismiss.layer.cornerRadius = 5;
    [dismiss addTarget:[self class] action:@selector(dismissDepiction) forControlEvents:UIControlEventTouchUpInside];
    [dismiss.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [_dismiss addSubview:dismiss];
    [self.view addSubview:_dismiss];
    // Search texfield
    _searchField = [[UITextField alloc] initWithFrame:CGRectMake(15,100,[UIScreen mainScreen].bounds.size.width - 30,35)];
    _searchField.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    UIView *searchImageView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 27, 17)];
    UIImageView *searchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/Search.png"]];
    searchImage.frame = CGRectMake(5, 0, 17, 17);
    searchImage.image = [searchImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    searchImage.tintColor = [UIColor grayColor];
    [searchImageView addSubview:searchImage];
    _searchField.leftViewMode = UITextFieldViewModeAlways;
    _searchField.leftView = searchImageView;
    _searchField.returnKeyType = UIReturnKeySearch;
    _searchField.delegate = self;
    _searchField.layer.masksToBounds = YES;
    _searchField.layer.cornerRadius = 5;
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) _searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
    else _searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: [UIColor orangeColor]}];
    [self.view addSubview:_searchField];
    _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,150,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100) style:UITableViewStylePlain];
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    [_searchTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _searchTableView.contentInset = UIEdgeInsetsMake(0,0,100,0);
    if([(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        if(CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) _searchTableView.contentInset = UIEdgeInsetsMake(0,-160,100,0);
        else _searchTableView.contentInset = UIEdgeInsetsMake(0,-30,100,0);
    }
    _searchTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_searchTableView];
    // Progress View
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progressView.frame = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,10);
    progressView.progress = 0;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        progressView.progressTintColor = [UIColor colorWithRed:1.00 green:0.58 blue:0.00 alpha:1.0];
        self.view.backgroundColor = [UIColor blackColor];
        _searchTableView.backgroundColor = [UIColor blackColor];
        _searchField.keyboardAppearance = UIKeyboardAppearanceDark;
    }
    progressView.hidden = NO;
    [self.view addSubview:progressView];
}

+ (UIView *)getDismiss {
    return _dismiss;
}

+ (UIWebView *)getDepictionWebView {
    return _depictionWebView;
}

+ (UITextField *)getSearchField {
    return _searchField;
}

+ (UITableView *)getSearchTableView {
    return _searchTableView;
}

+ (UITextView *)getProgressTextView {
    return progressTextView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return _searchNames.count;
}
 
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     static NSString *cellIdentifier = @"cell";
     UITableViewCell *cell = (UITableViewCell *)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
     if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        cell.backgroundColor = [UIColor clearColor];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
    }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    }
     if(_searchNames.count > indexPath.row) cell.textLabel.text = [_searchNames objectAtIndex:indexPath.row];
     if(_searchDescs.count > indexPath.row) cell.detailTextLabel.text = [_searchDescs objectAtIndex:indexPath.row];
     return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showDepictionForPackageWithIndexPath:indexPath];
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    ManageViewController *manageViewController = [[ManageViewController alloc] init];
    if(alertView == optionsAlert && buttonIndex == 1) [manageViewController removePackageWithBundleID:[_searchPackages objectAtIndex:_packageIndex]];
    else if(alertView == optionsAlert && buttonIndex == 2) {
        [self downloadWithProgressAndURLString:[_searchFilenames objectAtIndex:_packageIndex] saveFilename:@"downloaded.deb"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.text.length < 3) {
        [self.view endEditing:YES];
        [self messageWithTitle:@"Sorry" message:@"This is too short for Icy to search. Please enter three or more symbols."];
        return YES;
    }
    [self searchForPackageInAllRepos:_searchField.text];
    [_searchTableView reloadData];
    [self.view endEditing:YES];
    return YES;
}

- (void)searchForPackageInAllRepos:(NSString *)package {
    // Clean up arrays
    [_searchPackages removeAllObjects];
    [_searchNames removeAllObjects];
    [_searchDescs removeAllObjects];
    [_searchFilenames removeAllObjects];
    [_searchDepictions removeAllObjects];
    // For loop to search in all repos
    for (id repo in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" error:NULL]) {
        SourcesViewController *sourcesViewController = [[SourcesViewController alloc] init];
        NSString *fullURL = nil;
        if([repo rangeOfString:@".bz2"].location != NSNotFound) continue;
        if([repo isEqualToString:@"ModMyi"]) fullURL = @"http://modmyi.saurik.com/";
        else if ([repo isEqualToString:@"Zodttd"]) fullURL = @"http://cydia.zodttd.com/repo/cydia/";
        else if([repo isEqualToString:@"Saurik"]) fullURL = @"http://apt.saurik.com/";
        else if([repo isEqualToString:@"BigBoss"]) fullURL = @"http://apt.thebigboss.org/repofiles/cydia/";
        else if([repo isEqualToString:@"updates"]) continue;
        else fullURL = [sourcesViewController.sourceLinks objectAtIndex:[sourcesViewController.sources indexOfObject:repo]];
        if(![[fullURL substringFromIndex:fullURL.length - 1] isEqualToString:@"/"]) fullURL = [fullURL stringByAppendingString:@"/"];
        [self searchForPackage:package inRepo:[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@",repo] withFullURLString:fullURL];
    }
}

- (void)searchForPackage:(NSString *)package inRepo:(NSString *)repo withFullURLString:(NSString *)fullURL {
    char str[999];
    const char *filename = [repo UTF8String];
    NSString *strictSearch = [NSString stringWithFormat:@"Package: %@\n",package];
    FILE *file = fopen(filename, "r");
    BOOL shouldAdd = NO;
    BOOL shouldDoWeirdStuffWithName = NO;
    NSString *lastDesc = nil;
    NSString *lastDepiction = @"ITHASNODEPICTION";
    NSString *lastFilename = nil;
    NSString *lastName = nil;
    NSString *lastPackage = nil;
    NSString *lastVersion = nil;
    while(fgets(str, 999, file) != NULL) {
        if(strstr(str, [package UTF8String]) && strstr(str, "Name:")) shouldAdd = YES;
        if(strcmp(str, [strictSearch UTF8String]) == 0) {
            shouldAdd = YES;
            shouldDoWeirdStuffWithName = YES;
        }
        if(strstr(str, "Package:")) {
            lastPackage = [[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Package: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            if(shouldDoWeirdStuffWithName) lastName = lastPackage;
        }
        if(strstr(str, "Description:")) lastDesc = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Description: " withString:@""];
        if(strstr(str, "Depiction:")) lastDepiction = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Depiction: " withString:@""];
        if(strstr(str, "Filename:")) lastFilename = [[[NSString stringWithFormat:@"%@%@",fullURL,[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Filename: " withString:@""]] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if(strstr(str, "Version:")) lastVersion = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Version: " withString:@""];
        if(strstr(str, "Name:")) lastName = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Name: " withString:@""];
        if(strlen(str) < 2 && shouldAdd) {
            if(shouldDoWeirdStuffWithName) lastName = lastPackage;
            NSString *add = @"";
            if(lastVersion != nil) add = [[lastName stringByAppendingString:lastVersion] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            else add = lastName;
            if(add != nil) [_searchNames addObject:add];
            if(lastDesc != nil) [_searchDescs addObject:lastDesc];
            if(lastPackage != nil) [_searchPackages addObject:lastPackage];
            [_searchDepictions addObject:lastDepiction];
            if(lastFilename != nil) [_searchFilenames addObject:lastFilename];
            if(_searchPackages.count > _searchNames.count) [_searchNames addObject:[_searchPackages lastObject]];
            shouldAdd = NO;
            lastDesc = nil;
            lastDepiction = @"ITHASNODEPICTION";
            lastFilename = nil;
            lastName = nil;
            lastPackage = nil;
            lastVersion = nil;
        }
    }
    fclose(file);
}

- (NSString *)filenameOfPackage:(NSString *)package fromRepo:(NSString *)repo withFullURL:(NSString *)fullURL {
    BOOL shouldReturn = NO;
    FILE *file = fopen([[@"/var/mobile/Media/Icy/Repos/" stringByAppendingString:repo] UTF8String], "r");
    char str[999];
    const char *search = [[NSString stringWithFormat:@"Package: %@\n",package] UTF8String];
    while (fgets(str, 999, file) != NULL) {
        if(strcmp(str, search) == 0) shouldReturn = YES;
        if(strstr(str, "Filename:") && shouldReturn) {
            NSString *filename = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Filename: " withString:@""];
            return [NSString stringWithFormat:@"%@%@",fullURL,filename];
        }
    }
    fclose(file);
    return @"NONE";
}

- (void)showDepictionForPackageWithIndexPath:(NSIndexPath *)indexPath {
    ViewController *viewController = [[ViewController alloc] init];
    _packageIndex = (int)indexPath.row;
    if([self isPackageInstalled:[_searchPackages objectAtIndex:indexPath.row]]) {
        [[ViewController getAboutButton] setTitle:@"Options" forState:UIControlStateNormal];
        options = YES;
    } else [[ViewController getAboutButton] setTitle:@"Install" forState:UIControlStateNormal];
    NSString *depictionString = [_searchDepictions objectAtIndex:indexPath.row];
    depictionString = [depictionString stringByReplacingOccurrencesOfString:@" " withString:@""];
    depictionString = [depictionString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if([depictionString isEqualToString:@"ITHASNODEPICTION"] && ![self isPackageInstalled:[_searchPackages objectAtIndex:indexPath.row]]) {
        [self downloadWithProgressAndURLString:[_searchFilenames objectAtIndex:_packageIndex] saveFilename:@"downloaded.deb"];
        return;
    }
    [_depictionWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:depictionString]]];
    if(CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) {
        _depictionWebView.frame = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 200);
        _dismiss.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.width - 100,[UIScreen mainScreen].bounds.size.height,60);
        dismiss.frame = CGRectMake(20,10,[UIScreen mainScreen].bounds.size.height - 40,30);
    }
    else {
        _depictionWebView.frame = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 210);
        _dismiss.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.height - 110,[UIScreen mainScreen].bounds.size.width,50);
        dismiss.frame = CGRectMake(20,10,[UIScreen mainScreen].bounds.size.width - 40,40);
    }
    if([(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] && CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) {
        _depictionWebView.frame = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 200);
        _dismiss.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.height - 110,[UIScreen mainScreen].bounds.size.width,50);
        dismiss.frame = CGRectMake(20,10,[UIScreen mainScreen].bounds.size.width - 40,40);
    }
    progressTextView.frame = _depictionWebView.bounds;
    _depictionWebView.hidden = NO;
    _dismiss.hidden = NO;
    [self.view bringSubviewToFront:_depictionWebView];
    [self.view bringSubviewToFront:viewController.navigationBar];
    [self.view bringSubviewToFront:progressView];
    [self.view bringSubviewToFront:_dismiss];
}

+ (void)dismissDepiction {
    progressTextView.hidden = YES;
    _depictionWebView.hidden = YES;
    _dismiss.hidden = YES;
    [[ViewController getAboutButton] setTitle:@"Install" forState:UIControlStateNormal];
    options = NO;
}

UIAlertView *optionsAlert;
- (void)showPackageOptions {
    optionsAlert = [[UIAlertView alloc] initWithTitle:@"Options" message:@"Select an option to do with the package" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", @"Reinstall", nil];
    [optionsAlert show];
}

BOOL options = NO;
+ (BOOL)getOptions {
    return options;
}

+ (int)getPackageIndex {
    return _packageIndex;
}

+ (NSMutableArray *)getSearchFilenames {
    return _searchFilenames;
}

- (void)messageWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
}

- (void)downloadWithProgressAndURLString:(NSString *)urlString saveFilename:(NSString *)filename {
    progressTextView.hidden = NO;
    progressTextView.text = @"Downloading package...";
    urlString = [[urlString stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    progressView.hidden = NO;
    _filename = filename;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"] forHTTPHeaderField:@"X-Unique-ID"];
    [request setValue:@"Telesphoreo APT-HTTP/1.0.592" forHTTPHeaderField:@"User-Agent"];
    [request setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"X-Firmware"];
    struct utsname systemInfo;
    uname(&systemInfo);
    [request setValue:[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding] forHTTPHeaderField:@"X-Machine"];
    connectionManager = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    progressTextView.text = [progressTextView.text stringByAppendingString:@"\nWriting data to file..."];
    [downloadedMutableData writeToFile:[NSString stringWithFormat:@"/var/mobile/Media/%@",_filename] atomically:YES];
    if([_filename isEqualToString:@"downloaded.deb"]) {
        ViewController *viewController = [[ViewController alloc] init];
        // Install
        progressTextView.text = [progressTextView.text stringByAppendingString:@"\nPreparing to run freeze binary...\n"];
        NSString *out = [viewController runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze"] withArguments:@[@"-i", @"/var/mobile/Media/downloaded.deb"] errors:YES];
        [viewController reload];
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Media/downloaded.deb" error:nil];
        progressTextView.text = [progressTextView.text stringByAppendingString:[@"\n" stringByAppendingString:out]];
        progressTextView.text = [progressTextView.text stringByAppendingString:@"Done. If no errors occured the package is now installed and ready to use."];
        AVPlayer *completion = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Done.caf"]]];
        [completion play];
    }
}

long long length;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    urlResponse = response;
    length = urlResponse.expectedContentLength;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [downloadedMutableData appendData:data];
    progressView.progress = ((100.0/length)*downloadedMutableData.length)/100;
    if (progressView.progress == 1) {
        progressView.hidden = YES;
    } else {
        progressView.hidden = NO;
    }
}

- (BOOL)isPackageInstalled:(NSString *)package {
    ViewController *viewController = [[ViewController alloc] init];
    if([[viewController runCommandWithOutput:@"/usr/bin/dpkg" withArguments:@[@"-s", package] errors:YES] rangeOfString:@"is not installed"].location == NSNotFound) return YES;
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
