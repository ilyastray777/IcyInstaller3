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

@interface SearchViewController ()

@end

@implementation SearchViewController

static int _packageIndex;
static NSMutableArray *_searchFilenames;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Init download stuff
    _downloadedMutableData = [[NSMutableData alloc] init];
    // Initialize arrays
    _searchPackages = [[NSMutableArray alloc] init];
    _searchNames = [[NSMutableArray alloc] init];
    _searchDescs = [[NSMutableArray alloc] init];
    _searchDepictions = [[NSMutableArray alloc] init];
    _searchFilenames = [[NSMutableArray alloc] init];
    // The depiction webview
    _depictionWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100)];
    _depictionWebView.scrollView.contentInset = UIEdgeInsetsMake(0,0,50,0);
    [self.view addSubview:_depictionWebView];
    _depictionWebView.hidden = YES;
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
    _searchTableView.backgroundColor = [UIColor whiteColor];
    [_searchTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _searchTableView.contentInset = UIEdgeInsetsMake(0,0,60,0);
    [self.view addSubview:_searchTableView];
    // Progress View
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.frame = CGRectMake(0,110,[UIScreen mainScreen].bounds.size.width,10);
    _progressView.progress = 0;
    [self.view addSubview:_progressView];
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
    }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    }
     cell.textLabel.text = [_searchNames objectAtIndex:indexPath.row];
     cell.detailTextLabel.text = [_searchDescs objectAtIndex:indexPath.row];
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
        ViewController *viewController = [[ViewController alloc] init];
        viewController.nameLabel.text = @"Getting...";
        [self downloadWithProgressAndURLString:[_searchFilenames objectAtIndex:_packageIndex] saveFilename:@"downloaded.deb"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.text.length < 4) {
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
        else fullURL = [sourcesViewController.sourceLinks objectAtIndex:[sourcesViewController.sources indexOfObject:repo]];
        if(![[fullURL substringFromIndex:fullURL.length - 1] isEqualToString:@"/"]) fullURL = [fullURL stringByAppendingString:@"/"];
        [self searchForPackage:package inRepo:[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@",repo] withFullURLString:fullURL];
    }
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
    NSString *lastPackage = nil;
    while(fgets(str, 999, file) != NULL) {
        if(strstr(str, [package UTF8String]) && strstr(str, "Name:")) shouldAdd = YES;
        if(strstr(str, "Package:")) lastPackage = [[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Package: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if(strstr(str, "Description:")) lastDesc = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Description: " withString:@""];
        if(strstr(str, "Depiction:")) lastDepiction = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Depiction: " withString:@""];
        if(strstr(str, "Filename:")) lastFilename = [[[NSString stringWithFormat:@"%@%@",fullURL,[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Filename: " withString:@""]] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if(strstr(str, "Name:")) lastName = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Name: " withString:@""];
        if(strlen(str) < 2 && shouldAdd) {
            [_searchNames addObject:lastName];
            [_searchDescs addObject:lastDesc];
            [_searchPackages addObject:lastPackage];
            [_searchDepictions addObject:lastDepiction];
            [_searchFilenames addObject:lastFilename];
            shouldAdd = NO;
        }
    }
    fclose(file);
}

- (void)showDepictionForPackageWithIndexPath:(NSIndexPath *)indexPath {
    ViewController *viewController = [[ViewController alloc] init];
    _packageIndex = (int)indexPath.row;
    if([viewController isPackageInstalled:[_searchPackages objectAtIndex:indexPath.row]]) [viewController.aboutButton setTitle:@"Options" forState:UIControlStateNormal];
    else [viewController.aboutButton setTitle:@"Install" forState:UIControlStateNormal];
    NSString *depictionString = [_searchDepictions objectAtIndex:indexPath.row];
    depictionString = [depictionString stringByReplacingOccurrencesOfString:@" " withString:@""];
    depictionString = [depictionString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [_depictionWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:depictionString]]];
    _depictionWebView.hidden = NO;
    [self.view bringSubviewToFront:_depictionWebView];
    [self.view bringSubviewToFront:viewController.navigationBar];
}

UIAlertView *optionsAlert;
- (void)showPackageOptions {
    optionsAlert = [[UIAlertView alloc] initWithTitle:@"Options" message:@"Select an option to do with the package" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", @"Reinstall", nil];
    [optionsAlert show];
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
    [alert release];
}

- (void)downloadWithProgressAndURLString:(NSString *)urlString saveFilename:(NSString *)filename {
    [self.view bringSubviewToFront:_progressView];
    _filename = filename;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"] forHTTPHeaderField:@"X-Unique-ID"];
    [request setValue:@"Telesphoreo APT-HTTP/1.0.592" forHTTPHeaderField:@"User-Agent"];
    [request setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"X-Firmware"];
    struct utsname systemInfo;
    uname(&systemInfo);
    [request setValue:[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding] forHTTPHeaderField:@"X-Machine"];
    _connectionManager = [[NSURLConnection alloc] initWithRequest:request delegate:self];
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
        ViewController *viewController = [[ViewController alloc] init];
        [viewController runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze"] withArguments:@[@"-i", @"/var/mobile/Media/downloaded.deb"] errors:NO];
        [viewController reload];
        [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Media/downloaded.deb" error:nil];
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
