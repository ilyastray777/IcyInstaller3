//
//  ViewController.h
//  IcyInstaller3
//
//  Created by ArtikusHG on 2/8/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITabBarDelegate>

#define coolerBlueColor [UIColor colorWithRed:0.00 green:0.52 blue:1.00 alpha:1.0];

// Methods
+ (UIButton *)getAboutButton;
- (BOOL)isNetworkAvailable;
- (void)makeViewRound:(UIView *)view withRadius:(int)radius;
- (void)messageWithTitle:(NSString *)title message:(NSString *)message;
- (void)homeAction;
- (void)manageAction;
- (void)sourcesAction;
- (void)searchAction;
- (void)reload;
- (NSString *)runCommandWithOutput:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors;

// UI
@property (strong, nonatomic) UIBarButtonItem *rightItem;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UINavigationBar *navigationBar;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UITabBar *tabbar;

// Device info
@property (nonatomic, assign) NSString *deviceModel;

@end
