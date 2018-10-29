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
#import <sqlite3.h>

@interface HomeViewController ()

@end

// Graceful closuer (by midnightchips)
@interface UIApplication (existing)
- (void)suspend;
- (void)terminateWithSuccess;
@end
@interface UIApplication (close)
- (void)close;
@end
@implementation UIApplication (close)

- (void)close {
    // Check if the current device supports background execution.
    BOOL multitaskingSupported = NO;
    // iOS < 4.0 compatibility check.
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) multitaskingSupported = [UIDevice currentDevice].multitaskingSupported;
    // Good practice, we're using a private method.
    if ([self respondsToSelector:@selector(suspend)]) {
        if (multitaskingSupported) {
            [self beginBackgroundTaskWithExpirationHandler:^{}];
            // Change the delay to your liking. I think 0.4 seconds feels just right (the "close" animation lasts 0.3 seconds).
            [self performSelector:@selector(exit) withObject:nil afterDelay:0.4];
        }
        [self suspend];
    }
    else [self exit];
}

- (void)exit {
    // Again, good practice.
    if ([self respondsToSelector:@selector(terminateWithSuccess)])
        [self terminateWithSuccess];
    else
        exit(EXIT_SUCCESS);
}

@end


@implementation HomeViewController
UIWebView *_welcomeWebView;
- (void)viewDidLoad {
    [super viewDidLoad];
    _welcomeWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100)];
    _welcomeWebView.scrollView.contentInset = UIEdgeInsetsMake(0,0,50,0);
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) _welcomeWebView.backgroundColor = [UIColor blackColor];
    else _welcomeWebView.backgroundColor = [UIColor whiteColor];
    _welcomeWebView.delegate = self;
    [self.view addSubview:_welcomeWebView];
    [self load];
    // The navbar (kinda...)
    UIView *navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) navigationBar.backgroundColor = [UIColor blackColor];
    else navigationBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navigationBar];
    // The button at the right
    UIButton *aboutButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 90,58,75,30)];
    aboutButton.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) [aboutButton setTitle:@"Light" forState:UIControlStateNormal];
    else [aboutButton setTitle:@"Dark" forState:UIControlStateNormal];
    [aboutButton setTitleColor:[UIColor colorWithRed:0.00 green:0.52 blue:1.00 alpha:1.0] forState:UIControlStateNormal];
    [aboutButton addTarget:self action:@selector(doModeStuff) forControlEvents:UIControlEventTouchUpInside];
    aboutButton.layer.masksToBounds = YES;
    aboutButton.layer.cornerRadius = 5;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        aboutButton.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.1];
        [aboutButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    }
    [navigationBar addSubview:aboutButton];
    // The top label
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,50,[UIScreen mainScreen].bounds.size.width - 130,40)];
    nameLabel.backgroundColor = [UIColor clearColor];
    [nameLabel setFont:[UIFont boldSystemFontOfSize:30]];
    nameLabel.text = @"Home";
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) nameLabel.textColor = [UIColor whiteColor];
    [navigationBar addSubview:nameLabel];
    // The less top but still top label
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,30,[UIScreen mainScreen].bounds.size.width,20)];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth fromDate:[NSDate date]];
    NSArray *weekdays = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    NSArray *months = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
    dateLabel.text = [[NSString stringWithFormat:@"%@, %@ %zd",[weekdays objectAtIndex:[components weekday] - 1],[months objectAtIndex:[components month] - 1],(long)[components day]] uppercaseString];
    dateLabel.textColor = [UIColor grayColor];
    [dateLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [navigationBar addSubview:dateLabel];
    
    
    // In theory, this should get the stuff that needs to be updated.
    // But it crashes.
    // What's interesting, if you comment one of the two lines of code in the for loop, it works...
    // But if you leave both uncommented, it crashes.
    // I tried everything.
    // If you ever decide to fix this shit...
    // Good luck.
    // You have been warned.
    // [self updates];
    
    // That was supposed to parse repos into mysql...
    // It does.
    // But very slowly.
    // So, it's commented.
    // Bye :p
    /*
    NSString *databasePath = @"/var/mobile/Media/Icy/repos.sqlite";
    const char *cDatabasePath = [databasePath UTF8String];
    sqlite3 *db = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath] == NO) {
        if (sqlite3_open(cDatabasePath, &db) == SQLITE_OK) {
            const char *sql_statement = "CREATE TABLE IF NOT EXISTS REPO (PACKAGE, NAME, DESCRIPTION, VERSION, FILENAME, DEPICTION)";
            if (sqlite3_exec(db, sql_statement, NULL, NULL, nil) != SQLITE_OK) NSLog(@"Failed to create database");
            sqlite3_close(db);
        } else NSLog(@"Failed to open or create database");
    }
    sqlite3_stmt *statement = nil;
        FILE *file = fopen("/var/mobile/Media/Icy/Repos/BigBoss", "r");
    char str[999];
    NSString *lastPackage = nil;
    NSString *lastName = nil;
    NSString *lastDescription = nil;
    NSString *lastVersion = nil;
    NSString *lastFilename = nil;
    NSString *lastDepiction = nil;
    while(fgets(str, 999, file) != NULL) {
        if(strstr(str, "Package:")) {
            lastPackage = [NSString stringWithCString:str encoding:NSASCIIStringEncoding];
            lastPackage = [lastPackage substringFromIndex:[lastPackage rangeOfString:@" "].location + 1];
        }
        if(strstr(str, "Name:")) {
            lastName = [NSString stringWithCString:str encoding:NSASCIIStringEncoding];
            lastName = [lastName substringFromIndex:[lastName rangeOfString:@" "].location + 1];
        }
        if(strstr(str, "Description:")) {
            lastDescription = [NSString stringWithCString:str encoding:NSASCIIStringEncoding];
            lastDescription = [lastDescription substringFromIndex:[lastDescription rangeOfString:@" "].location + 1];
        }
        if(strstr(str, "Version:")) {
            lastVersion = [NSString stringWithCString:str encoding:NSASCIIStringEncoding];
            lastVersion = [lastVersion substringFromIndex:[lastVersion rangeOfString:@" "].location + 1];
        }
        if(strstr(str, "Filename:")) {
            lastFilename = [NSString stringWithCString:str encoding:NSASCIIStringEncoding];
            lastFilename = [lastFilename substringFromIndex:[lastFilename rangeOfString:@" "].location + 1];
        }
        if(strstr(str, "Depiction:")) {
            lastDepiction = [NSString stringWithCString:str encoding:NSASCIIStringEncoding];
            lastDepiction = [lastDepiction substringFromIndex:[lastDepiction rangeOfString:@" "].location + 1];
        }
        if(strlen(str) < 2) {
            if (sqlite3_open(cDatabasePath, &db) == 0) {
                NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO REPO (PACKAGE, NAME, DESCRIPTION, VERSION, FILENAME, DEPICTION) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")", lastPackage, lastName, lastDescription, lastVersion, lastFilename, lastDepiction];
                NSLog(@"%@",insertSQL);
                const char *insert_stmt = [insertSQL UTF8String];
                sqlite3_prepare_v2(db, insert_stmt, -1, &statement, NULL);
            } else NSLog(@"It doesn't work...");
            if (sqlite3_step(statement) == SQLITE_DONE) NSLog(@"Done");
            else NSLog(@"Error");
            sqlite3_finalize(statement);
            sqlite3_close(db);
        }
    }
    fclose(file);*/
}

- (void)doModeStuff {
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"darkMode"];
    else [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"darkMode"];
    [[UIApplication sharedApplication] close];
    [[UIApplication sharedApplication] terminateWithSuccess];
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
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) [_welcomeWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://artikushg.github.io/Icy.html?mode=dark"] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60]];
    else [_welcomeWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://artikushg.github.io/Icy.html?mode=light"] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60]];
    
}

@end
