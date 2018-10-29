//
//  IcyDPKGViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 10/26/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import "IcyDPKGViewController.h"
#import "IcyUniversalMethods.h"
@import AVFoundation;

@interface IcyDPKGViewController ()

@end

@implementation IcyDPKGViewController

UITextView *progressTextView;

- (void)viewDidLoad {
    [super viewDidLoad];
    progressTextView = [[UITextView alloc] initWithFrame:CGRectMake(0,64,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 64)];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        progressTextView.backgroundColor = [UIColor blackColor];
        progressTextView.textColor = [UIColor whiteColor];
    }
    else progressTextView.backgroundColor = [UIColor whiteColor];
    progressTextView.font = [UIFont boldSystemFontOfSize:15];
    progressTextView.editable = NO;
    progressTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.view addSubview:progressTextView];
    // Navbar
    UINavigationBar *DPKGNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,64)];
    UINavigationItem *titleNavigationItem = [[UINavigationItem alloc] initWithTitle:@"Installing..."];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    titleNavigationItem.rightBarButtonItem = doneButton;
    [DPKGNavigationBar setItems:@[titleNavigationItem]];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        DPKGNavigationBar.tintColor = [UIColor orangeColor];
        DPKGNavigationBar.barTintColor = [UIColor blackColor];
        DPKGNavigationBar.barStyle = UIBarStyleBlack;
    }
    [self.view addSubview:DPKGNavigationBar];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setDPKGArguments:(NSArray *)args {
    IcyUniversalMethods *icyUniversalMethods = [[IcyUniversalMethods alloc] init];
    progressTextView.text = [progressTextView.text stringByAppendingString:@"Preparing to run freeze binary...\n"];
    if(SYSTEM_VERSION_LESS_THAN(@"11.0")) progressTextView.text = [progressTextView.text stringByAppendingString:[IcyUniversalMethods runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze11"] withArguments:args errors:NO]];
    else progressTextView.text = [progressTextView.text stringByAppendingString:[IcyUniversalMethods runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze"] withArguments:args errors:NO]];
    [icyUniversalMethods reload];
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Media/downloaded.deb" error:nil];
    AVPlayer *completion = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Done.caf"]]];
    [completion play];
}

@end
