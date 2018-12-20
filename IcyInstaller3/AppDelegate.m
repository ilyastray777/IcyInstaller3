//
//  AppDelegate.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 2/8/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "SourcesViewController.h"
#import "SearchViewController.h"
#import "ManageViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // This used to be in the ViewController when I didn't know how to do shit properly. I'm just dumb.
    // Now, luckily I removed it...
    // So, it's now in the AppDelegate. This is probably not the place to put it in, but I don't know a better place to do it, really.
    // Check for needed directories
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy" isDirectory:nil]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy" withIntermediateDirectories:NO attributes:nil error:nil];
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/Repos" isDirectory:nil]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" withIntermediateDirectories:NO attributes:nil error:nil];
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/Repos/updates" isDirectory:nil]) [[NSFileManager defaultManager] createDirectoryAtPath:@"/var/mobile/Media/Icy/Repos/updates" withIntermediateDirectories:NO attributes:nil error:nil];
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/sources.list" isDirectory:nil]) [[NSFileManager defaultManager] createFileAtPath:@"/var/mobile/Media/Icy/sources.list" contents:nil attributes:nil];
    // Redirect log to a file
    freopen([@"/var/mobile/Media/Icy/log.txt" cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    // Clean user defaults stuff
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"queryPackages"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"queryNames"];
    // UI code
    [[SourcesViewController getSourcesTableView] reloadData];
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.backgroundColor = [UIColor whiteColor];
    HomeViewController *homeViewController = [[HomeViewController alloc] init];
    SourcesViewController *sourcesViewController = [[SourcesViewController alloc] init];
    ManageViewController *manageViewController = [[ManageViewController alloc] init];
    SearchViewController *searchViewController = [[SearchViewController alloc] init];
    homeViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@"icons/Home.png"] tag:0];
    sourcesViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Sources" image:[UIImage imageNamed:@"icons/Sources.png"] tag:1];
    manageViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Manage" image:[UIImage imageNamed:@"icons/Installed.png"] tag:2];
    searchViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Search" image:[UIImage imageNamed:@"icons/Search.png"] tag:3];
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = [NSArray arrayWithObjects:homeViewController, sourcesViewController, manageViewController, searchViewController, nil];
    tabBarController.delegate = self;
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10]} forState:UIControlStateNormal];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        tabBarController.tabBar.tintColor = [UIColor orangeColor];
        tabBarController.tabBar.barTintColor = [UIColor blackColor];
    }
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    else [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    _window.rootViewController = tabBarController;
    [_window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
