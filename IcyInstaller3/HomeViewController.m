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
UIView *navigationBar;
UIButton *aboutButton;
UILabel *nameLabel;
UILabel *dateLabel;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resetFrames];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Home";
    _welcomeWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,100,self.view.bounds.size.width,self.view.bounds.size.height - 100)];
    _welcomeWebView.scrollView.contentInset = UIEdgeInsetsMake(0,0,50,0);
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) _welcomeWebView.backgroundColor = [UIColor blackColor];
    else _welcomeWebView.backgroundColor = [UIColor whiteColor];
    _welcomeWebView.delegate = self;
    [self.view addSubview:_welcomeWebView];
    [self load];
    // The navbar (kinda...)
    navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) navigationBar.backgroundColor = [UIColor blackColor];
    else navigationBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navigationBar];
    // The button at the right
    aboutButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 90,58,75,30)];
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
        self.view.backgroundColor = [UIColor blackColor];
    }
    [navigationBar addSubview:aboutButton];
    // The top label
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,50,self.view.bounds.size.width - 130,40)];
    nameLabel.backgroundColor = [UIColor clearColor];
    [nameLabel setFont:[UIFont boldSystemFontOfSize:30]];
    nameLabel.text = @"Home";
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) nameLabel.textColor = [UIColor whiteColor];
    [navigationBar addSubview:nameLabel];
    // The less top but still top label
    dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,30,self.view.bounds.size.width,20)];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth fromDate:[NSDate date]];
    NSArray *weekdays = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    NSArray *months = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
    dateLabel.text = [[NSString stringWithFormat:@"%@, %@ %zd",[weekdays objectAtIndex:[components weekday] - 1],[months objectAtIndex:[components month] - 1],(long)[components day]] uppercaseString];
    dateLabel.textColor = [UIColor grayColor];
    [dateLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [navigationBar addSubview:dateLabel];
    /*IcyPackageList *packageList = [[IcyPackageList alloc] init];
    NSMutableArray *packagesToUpdate = [[NSMutableArray alloc] init];
    int i = 0;
    NSString *object = nil;
    // Compare versions and add to array if need update
    //[self updates];
    @autoreleasepool {
        while(i != packageList.packageIDs.count) {
            object = [packageList.packageIDs objectAtIndex:i];
            if([self returnOfCommand:@"/usr/bin/dpkg" withArguments:@[@"--compare-versions", [self currentVersionOfPackage:object], @"lt", [self versionOfPackage:object]]] == 0) [packagesToUpdate addObject:object];0
            i++;
        }
    }*/
    //[IcyUniversalMethods messageWithTitle:@"updates" message:[NSString stringWithFormat:@"%@",packagesToUpdate]];
    [self resetFrames];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self resetFrames];
}

- (void)resetFrames {
    _welcomeWebView.frame = CGRectMake(0,100,self.view.bounds.size.width,self.view.bounds.size.height - 100);
    navigationBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 100);
    aboutButton.frame = CGRectMake(self.view.bounds.size.width - 90,58,75,30);
    if([IcyUniversalMethods hasTopNotch]) {
        if(UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            navigationBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 150);
            _welcomeWebView.frame = CGRectMake(0,150,self.view.bounds.size.width,self.view.bounds.size.height - 150);
            aboutButton.frame = CGRectMake(self.view.bounds.size.width - 130,108,75,30);
            nameLabel.frame = CGRectMake(55,100,self.view.bounds.size.width - 130,40);
            dateLabel.frame = CGRectMake(55,70,self.view.bounds.size.width,20);
        } else {
            navigationBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 150);
            _welcomeWebView.frame = CGRectMake(0,150,self.view.bounds.size.width,self.view.bounds.size.height - 150);
            aboutButton.frame = CGRectMake(self.view.bounds.size.width - 90,108,75,30);
            nameLabel.frame = CGRectMake(15,100,self.view.bounds.size.width - 130,40);
            dateLabel.frame = CGRectMake(15,70,self.view.bounds.size.width,20);
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self resetFrames];
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
        if([object isEqualToString:@"updates"] || [object rangeOfString:@".bz2"].location != NSNotFound) continue;
        FILE *input = fopen([[@"/var/mobile/Media/Icy/Repos/" stringByAppendingString:object] UTF8String], "r");
        FILE *output = fopen([[@"/var/mobile/Media/Icy/Repos/updates/" stringByAppendingString:object] UTF8String], "a");
        char str[256];
        while(fgets(str, 256, input) != NULL) {
            if(strstr(str, "Package:") || strstr(str, "Version:")) fprintf(output, "%s", str);
        }
        fclose(input);
        fclose(output);
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
    NSMutableString *thing = [[NSMutableString alloc] initWithString:[[IcyUniversalMethods runCommandWithOutput:@"/bin/grep" withArguments:@[[NSMutableString stringWithFormat:@"\\Package: %@$",package], @"-A", @"1", @"-w", @"-r", @"-h", @"/var/mobile/Media/Icy/Repos/updates/"] errors:NO] stringByReplacingOccurrencesOfString:[NSMutableString stringWithFormat:@"Package: %@\nVersion: ",package] withString:@""]];
    NSMutableArray *array = [[thing componentsSeparatedByString:@"\n"] mutableCopy];
    for (NSMutableString *object in array) if(object.length == 0) [array removeObject:object];
    while(array.count != 1) {
        if (array.count == 0) break;
        if(array.count >= 2 && [self returnOfCommand:@"/usr/bin/dpkg" withArguments:@[@"--compare-versions", [array objectAtIndex:0], @"gt", [array objectAtIndex:1]]] == 0) [array removeObjectAtIndex:1];
        else [array removeObjectAtIndex:0];
    }
    if(array.count > 0) return [array firstObject];
    return @"";
}

- (NSString *)currentVersionOfPackage:(NSString *)package {
    @autoreleasepool {
        FILE *file = fopen("/var/lib/dpkg/status", "r");
        char str[128];
        BOOL shouldReturn = NO;
        while(fgets(str, 128, file) != NULL) {
            if (strcmp(str, [[NSString stringWithFormat:@"Package: %@\n",package] UTF8String]) == 0) shouldReturn = YES;
            if(shouldReturn && strstr(str, "Version:")) break;
        }
        fclose(file);
        return [[[NSString stringWithCString:str encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"Version: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
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
