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

// This WAS the ViewController when I was dumb and didn't know how to create a TabBarController :/
// Now, it's just something that contains universal methods
// I'll probably remove it later when I have time and energy to do it :P

@interface ViewController ()

@end


@implementation ViewController

#pragma mark - Reload method



#pragma mark - Dark/light modes

- (void)switchToDarkMode {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"darkMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_toolbar setBarTintColor:[UIColor blackColor]];
    _tabbar.tintColor = [UIColor orangeColor];
    _tabbar.barTintColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor blackColor];
    [HomeViewController getWelcomeWebView].backgroundColor = [UIColor blackColor];
    [SearchViewController getDismiss].backgroundColor = [UIColor blackColor];
    [SearchViewController getSearchField].textColor = [UIColor whiteColor];
    [SearchViewController getSearchField].keyboardAppearance = UIKeyboardAppearanceDark;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)switchToLightMode {
    NSLog(@"l");
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"darkMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _tabbar.tintColor = [UIColor colorWithRed:0.00 green:0.48 blue:1.00 alpha:1.0];
    _tabbar.barTintColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    _manageViewController.view.backgroundColor = [UIColor whiteColor];
    _searchViewController.view.backgroundColor = [UIColor whiteColor];
    [SearchViewController getDismiss].backgroundColor = [UIColor whiteColor];
    [SearchViewController getSearchField].textColor = [UIColor blackColor];
    [SearchViewController getSearchField].keyboardAppearance = UIKeyboardAppearanceLight;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - Small but useful bits of code



#pragma mark - UI Orientation methods

// Buggy. Way too buggy.
/*- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) [self changeToPortrait];
    else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) [self changeToLandscape];
}*/

- (void)changeToPortrait {
    if([SearchViewController getProgressTextView].text.length > 2) return;
    else [SearchViewController dismissDepiction];
    _tabbar.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 49, [UIScreen mainScreen].bounds.size.width, 50);
    if([(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"]) _tabbar.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.width - 49, [UIScreen mainScreen].bounds.size.height, 50);
    //navigationBar.frame = CGRectMake(navigationBar.frame.origin.x, navigationBar.frame.origin.y, [UIScreen mainScreen].bounds.size.width, 100);
    [HomeViewController getWelcomeWebView].frame = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100);
    [SourcesViewController getSourcesTableView].frame = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100);
    [ManageViewController getManageTableView].frame = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100);
    [SearchViewController getSearchField].frame = CGRectMake(15,100,[UIScreen mainScreen].bounds.size.width - 30,35);
    [SearchViewController getSearchTableView].frame = CGRectMake(0,150,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100);
}

- (void)changeToLandscape {
    if([SearchViewController getProgressTextView].text.length > 2) return;
    else [SearchViewController dismissDepiction];
    _tabbar.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.width - 49, [UIScreen mainScreen].bounds.size.height, 50);
    //navigationBar.frame = CGRectMake(navigationBar.frame.origin.x, navigationBar.frame.origin.y, [UIScreen mainScreen].bounds.size.height, 100);
    [HomeViewController getWelcomeWebView].frame = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 100);
    [SourcesViewController getSourcesTableView].frame = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 100);
    [ManageViewController getManageTableView].frame = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 100);
    [SearchViewController getSearchField].frame = CGRectMake(15,100,[UIScreen mainScreen].bounds.size.height - 30,35);
    [SearchViewController getSearchTableView].frame = CGRectMake(0,150,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 100);
}

@end
