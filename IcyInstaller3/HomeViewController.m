//
//  HomeViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/20/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // The homepage webview, temporair and to replace with something native like the AppStore homepage
    _welcomeWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100)];
    [_welcomeWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://artikus.pe.hu/Icy.html"]]];
    _welcomeWebView.scrollView.contentInset = UIEdgeInsetsMake(0,0,50,0);
    _welcomeWebView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_welcomeWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
