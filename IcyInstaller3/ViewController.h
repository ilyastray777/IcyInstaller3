//
//  ViewController.h
//  IcyInstaller3
//
//  Created by ArtikusHG on 2/8/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSURLConnectionDataDelegate, UITabBarDelegate>

#define coolerBlueColor [UIColor colorWithRed:0.00 green:0.52 blue:1.00 alpha:1.0];

// Methods
- (BOOL)isPackageInstalled:(NSString *)package;
- (BOOL)isNetworkAvailable;
- (void)makeViewRound:(UIView *)view withRadius:(int)radius;
- (void)messageWithTitle:(NSString *)title message:(NSString *)message;
- (void)homeAction;
- (void)manageAction;
- (void)sourcesAction;
- (void)searchAction;
- (void)reload;
- (NSString *)runCommandWithOutput:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors;

@property (nonatomic) int packageIndex;

// The download variables
@property (strong, nonatomic) NSURLConnection *connectionManager;
@property (strong, nonatomic) NSMutableData *downloadedMutableData;
@property (strong, nonatomic) NSURLResponse *urlResponse;
@property (strong, nonatomic) NSString *filename;

// UI
@property (strong, nonatomic) UIButton *aboutButton;
@property (strong, nonatomic) UIBarButtonItem *rightItem;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UITabBar *tabbar;
@property (strong, nonatomic) UIProgressView *progressView;

// Reload needed arrays
@property (nonatomic) NSUInteger oldApplications;
@property (nonatomic) NSUInteger oldTweaks;

// Device info
@property (nonatomic, assign) NSString *deviceModel;

@end
