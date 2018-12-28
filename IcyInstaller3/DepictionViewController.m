//
//  DepictionViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 10/17/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

// Code not commented as it's pretty clear

#import "DepictionViewController.h"
@import AVFoundation;

@interface DepictionViewController ()

@end

@implementation DepictionViewController

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

NSURLConnection *connectionManager;
NSMutableData *downloadedMutableData;
UIWebView *depictionWebView;
NSURLResponse *urlResponse;
NSString *toDownloadURL;
NSString *filename;
NSString *packageName;
NSString *removeID;
NSMutableArray *packageQueryArray;
NSMutableArray *packageQueryNamesArray;

@synthesize progressView;

- (id)initWithURLString:(NSString *)urlString removeBundleID:(NSString *)removeBundleID downloadURLString:(NSString *)downloadURLString buttonType:(int)buttonType packageName:(NSString *)name {
    self = [super init];
    self.title = @"Depiction";
    packageQueryArray = [[NSMutableArray alloc] init];
    packageQueryNamesArray = [[NSMutableArray alloc] init];
    packageName = name;
    removeID = removeBundleID;
    toDownloadURL = downloadURLString;
    if([urlString isEqualToString:@"ITHASNODEPICTION"]) urlString = @"http://artikushg.github.io/nodepiction.html";
    // button types
    // 0 - no left button
    // 1 - install
    // 2 - options
    downloadedMutableData = [[NSMutableData alloc] init];
    _icyUniversalMethods = [[IcyUniversalMethods alloc] init];
    NSString *leftButtonTitle = @"";
    if(buttonType == 1) leftButtonTitle = @"Install";
    else if(buttonType == 2) leftButtonTitle = @"Options";
    depictionWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];
    [self.view addSubview:depictionWebView];
    [depictionWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    if(buttonType != 0) self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:leftButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonAction:)];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        UINavigationBar.appearance.tintColor = [UIColor orangeColor];
        UINavigationBar.appearance.barTintColor = [UIColor blackColor];
        UINavigationBar.appearance.barStyle = UIBarStyleBlack;
        self.view.backgroundColor = [UIColor blackColor];
    }
    // Progress View
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progressView.frame = CGRectMake(0,64,self.view.bounds.size.width,10);
    progressView.progress = 0;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) progressView.progressTintColor = [UIColor colorWithRed:1.00 green:0.58 blue:0.00 alpha:1.0];
    progressView.hidden = NO;
    [self.view addSubview:progressView];
    [self resetFrames];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resetFrames];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self resetFrames];
}

- (void)resetFrames {
    depictionWebView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    progressView.frame = CGRectMake(0,64,self.view.bounds.size.width,10);
}

UIAlertView *optionsAlert;
- (void)leftButtonAction:(UIBarButtonItem *)sender {
    if([sender.title isEqualToString:@"Install"]) [self downloadWithProgressAndURLString:toDownloadURL];
    else {
        optionsAlert = [[UIAlertView alloc] initWithTitle:@"Options" message:@"Choose what to do with the package." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", @"Reinstall", nil];
        optionsAlert.delegate = self;
        [optionsAlert show];
    }
}

- (void)downloadWithProgressAndURLString:(NSString *)urlString {
    filename = [urlString substringFromIndex:[urlString rangeOfString:@"/" options:NSBackwardsSearch].location + 1];
    if(![IcyUniversalMethods isNetworkAvailable]) {
        [IcyUniversalMethods messageWithTitle:@"Error" message:@"This action requires an internet connection. If you are connected to the internet, but the problem still occurs, try relaunching Icy."];
        return;
    }
    urlString = [[urlString stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    progressView.hidden = NO;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"] forHTTPHeaderField:@"X-Unique-ID"];
    [request setValue:@"Telesphoreo APT-HTTP/1.0.592" forHTTPHeaderField:@"User-Agent"];
    [request setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"X-Firmware"];
    [request setValue:[NSString stringWithCString:[_icyUniversalMethods.deviceModel UTF8String] encoding:NSUTF8StringEncoding] forHTTPHeaderField:@"X-Machine"];
    connectionManager = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [downloadedMutableData writeToFile:[NSString stringWithFormat:@"/var/mobile/Media/%@",filename] atomically:YES];
    // Install
    IcyDPKGViewController *dpkgViewController = [[IcyDPKGViewController alloc] init];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"queryNames"] != nil) packageQueryNamesArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"queryNames"] mutableCopy];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"queryPackages"] != nil) packageQueryArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"queryPackages"] mutableCopy];
    [packageQueryArray addObject:filename];
    [packageQueryNamesArray addObject:packageName];
    packageQueryArray = [[[NSOrderedSet orderedSetWithArray:packageQueryArray] array] mutableCopy];
    packageQueryNamesArray = [[[NSOrderedSet orderedSetWithArray:packageQueryNamesArray] array] mutableCopy];
    [[NSUserDefaults standardUserDefaults] setObject:packageQueryNamesArray forKey:@"queryNames"];
    [[NSUserDefaults standardUserDefaults] setObject:packageQueryArray forKey:@"queryPackages"];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:dpkgViewController] animated:YES completion:^ {
        for(NSString *object in [[NSUserDefaults standardUserDefaults] objectForKey:@"queryPackages"]) [dpkgViewController addItemToQuery:object];
        for(NSString *object in [[NSUserDefaults standardUserDefaults] objectForKey:@"queryNames"]) [dpkgViewController addNameToQuery:object];
    }];
}

long long length;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    urlResponse = response;
    length = urlResponse.expectedContentLength;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [downloadedMutableData appendData:data];
    progressView.progress = ((100.0/length)*downloadedMutableData.length)/100;
    if (progressView.progress == 1) progressView.hidden = YES;
    else progressView.hidden = NO;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    PackageInfoViewController *packageInfoViewController = [[PackageInfoViewController alloc] init];
    if(alertView == optionsAlert && buttonIndex == 1) {
        [packageInfoViewController removePackageWithBundleID:removeID];
        [_icyUniversalMethods reload];
    }
    else if(alertView == optionsAlert && buttonIndex == 2) [self downloadWithProgressAndURLString:toDownloadURL];
}

@end
