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
- (void)switchToLightMode;
- (void)switchToDarkMode;
- (BOOL)isNetworkAvailable;
- (void)messageWithTitle:(NSString *)title message:(NSString *)message;
- (void)reload;
- (NSString *)runCommandWithOutput:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors;

// UI
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UITabBar *tabbar;

// Device info
@property (nonatomic, assign) NSString *deviceModel;

@end
