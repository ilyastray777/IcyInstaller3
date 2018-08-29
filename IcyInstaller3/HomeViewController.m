//
//  HomeViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/20/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import "HomeViewController.h"
#import "IcyPackageList.h"
#import "NSTask.h"

@interface HomeViewController ()

@end

@implementation HomeViewController
UIWebView *_welcomeWebView;
- (void)viewDidLoad {
    [super viewDidLoad];
    _welcomeWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100)];
    [self load];
    _welcomeWebView.scrollView.contentInset = UIEdgeInsetsMake(0,0,50,0);
    _welcomeWebView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_welcomeWebView];
    // In theory, this should get the stuff that needs to be updated.
    // But it crashes.
    // What's interesting, if you comment one of the two lines of code in the for loop, it works...
    // But if you leave both uncommented, it crashes.
    // I tried everything.
    // If you ever decide to fix this shit...
    // Good luck.
    // You have been warned.
    // [self updates];
}

- (void)updates {
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/Repos/updates" isDirectory:nil]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy/Repos/updates" withIntermediateDirectories:NO attributes:nil error:nil];
    for (id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos/updates/" error:nil]) [[NSFileManager defaultManager] removeItemAtPath:[@"/var/mobile/Media/Icy/Repos/updates/" stringByAppendingString:object] error:nil];
    for (id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos/" error:nil]) {
        if([object isEqualToString:@"updates"]) continue;
        FILE *input = fopen([[@"/var/mobile/Media/Icy/Repos/" stringByAppendingString:object] UTF8String], "r");
        FILE *output = fopen([[@"/var/mobile/Media/Icy/Repos/updates/" stringByAppendingString:object] UTF8String], "a");
        char str[256];
        while(fgets(str, 256, input) != NULL) {
            if(strstr(str, "Package:") || strstr(str, "Version:") || strlen(str) < 2) fprintf(output, "%s", str);
        }
        fclose(input);
        fclose(output);
    }
    NSMutableArray *currentVersions = [[NSMutableArray alloc] init];
    NSMutableArray *latestVersions = [[NSMutableArray alloc] init];
    IcyPackageList *packageList = [[IcyPackageList alloc] init];
    for (id object in packageList.packageIDs) {
        [latestVersions addObject:[self versionOfPackageInAllRepos:object]];
        [currentVersions addObject:[self versionOfPackage:object]];
    }
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

- (NSString *)versionOfPackage:(NSString *)package {
    NSString *toReturn = @"No such package";
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[50];
    const char *pkgsearch = [[NSString stringWithFormat:@"Package: %@\n",package] UTF8String];
    BOOL shouldReturn = NO;
    while(fgets(str, 50, file) != NULL) {
        if(strcmp(str, pkgsearch) == 0) shouldReturn = YES;
        if(shouldReturn && strstr(str, "Version:")) {
            toReturn = [[[NSString stringWithCString:str encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"Version: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            fclose(file);
            break;
        }
    }
    return toReturn;
}

- (NSString *)versionOfPackageInAllRepos:(NSString *)package {
    NSString *toReturn = @"No such package";
    for (id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos/updates/" error:nil]) {
        if([object rangeOfString:@".bz2"].location != NSNotFound) continue;
        NSString *repo = [NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/updates/%@",object];
        FILE *file = fopen([repo UTF8String], "r");
        char str[50];
        const char *pkgsearch = [[NSString stringWithFormat:@"Package: %@\n",package] UTF8String];
        BOOL shouldReturn = NO;
        while(fgets(str, 50, file) != NULL) {
            if(strcmp(str, pkgsearch) == 0) shouldReturn = YES;
            if(shouldReturn && strstr(str, "Version:")) {
                toReturn = [[[NSString stringWithCString:str encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"Version: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                fclose(file);
                break;
            }
        }
    }
    return toReturn;
}

+ (UIWebView *)getWelcomeWebView {
    return _welcomeWebView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)load {
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) [_welcomeWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://artikushg.github.io/Icy.html?mode=dark"]]];
    else [_welcomeWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://artikushg.github.io/Icy.html?mode=light"]]];
}

@end
