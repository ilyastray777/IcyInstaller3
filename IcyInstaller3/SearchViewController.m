//
//  SearchViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/20/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import "SearchViewController.h"
#import "SourcesViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize arrays
    _searchPackages = [[NSMutableArray alloc] init];
    _searchNames = [[NSMutableArray alloc] init];
    _searchDescs = [[NSMutableArray alloc] init];
    _searchDepictions = [[NSMutableArray alloc] init];
    _searchFilenames = [[NSMutableArray alloc] init];
    // The depiction webview
    _depictionWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100)];
    _depictionWebView.scrollView.contentInset = UIEdgeInsetsMake(0,0,50,0);
    [self.view addSubview:_depictionWebView];
    _depictionWebView.hidden = YES;
    // Search texfield
    _searchField = [[UITextField alloc] initWithFrame:CGRectMake(15,110,[UIScreen mainScreen].bounds.size.width - 30,40)];
    _searchField.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    UIView *searchImageView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 27, 17)];
    UIImageView *searchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/Search.png"]];
    searchImage.frame = CGRectMake(5, 0, 17, 17);
    searchImage.image = [searchImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    searchImage.tintColor = [UIColor grayColor];
    [searchImageView addSubview:searchImage];
    _searchField.leftViewMode = UITextFieldViewModeAlways;
    _searchField.leftView = searchImageView;
    _searchField.returnKeyType = UIReturnKeySearch;
    _searchField.delegate = self;
    _searchField.layer.masksToBounds = YES;
    _searchField.layer.cornerRadius = 5;
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) _searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
    else _searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: [UIColor orangeColor]}];
    [self.view addSubview:_searchField];
    _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(10,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100) style:UITableViewStylePlain];
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    _searchTableView.backgroundColor = [UIColor whiteColor];
    [_searchTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _searchTableView.contentInset = UIEdgeInsetsMake(0,0,60,0);
    [self.view addSubview:_searchTableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return _searchNames.count;
}
 
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     static NSString *cellIdentifier = @"cell";
     UITableViewCell *cell = (UITableViewCell *)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
     if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        cell.backgroundColor = [UIColor clearColor];
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    }
     cell.textLabel.text = [_searchNames objectAtIndex:indexPath.row];
     cell.detailTextLabel.text = [_searchDescs objectAtIndex:indexPath.row];
     return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showDepictionForPackageWithIndexPath:indexPath];
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.text.length < 4) {
        [self.view endEditing:YES];
        [self messageWithTitle:@"Sorry" message:@"This is too short for Icy to search. Please enter three or more symbols."];
        return YES;
    }
    [self searchForPackageInAllRepos:_searchField.text];
    [_searchTableView reloadData];
    [self.view endEditing:YES];
    return YES;
}

- (void)searchForPackageInAllRepos:(NSString *)package {
    // Clean up arrays
    [_searchPackages removeAllObjects];
    [_searchNames removeAllObjects];
    [_searchDescs removeAllObjects];
    [_searchFilenames removeAllObjects];
    [_searchDepictions removeAllObjects];
    // For loop to search in all repos
    for (id repo in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" error:NULL]) {
        SourcesViewController *sourcesViewController = [[SourcesViewController alloc] init];
        NSString *fullURL = nil;
        if([repo rangeOfString:@".bz2"].location != NSNotFound) continue;
        if([repo isEqualToString:@"ModMyi"]) fullURL = @"http://modmyi.saurik.com/";
        else if ([repo isEqualToString:@"Zodttd"]) fullURL = @"http://cydia.zodttd.com/repo/cydia/";
        else if([repo isEqualToString:@"Saurik"]) fullURL = @"http://apt.saurik.com/";
        else if([repo isEqualToString:@"BigBoss"]) fullURL = @"http://apt.thebigboss.org/repofiles/cydia/";
        else fullURL = [sourcesViewController.sourceLinks objectAtIndex:[sourcesViewController.sources indexOfObject:repo]];
        if(![[fullURL substringFromIndex:fullURL.length - 1] isEqualToString:@"/"]) fullURL = [fullURL stringByAppendingString:@"/"];
        [self searchForPackage:package inRepo:[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@",repo] withFullURLString:fullURL];
    }
}

- (void)searchForPackage:(NSString *)package inRepo:(NSString *)repo withFullURLString:(NSString *)fullURL {
    char str[999];
    const char *filename = [repo UTF8String];
    FILE *file = fopen(filename, "r");
    BOOL shouldAdd = NO;
    NSString *lastDesc = nil;
    NSString *lastDepiction = nil;
    NSString *lastFilename = nil;
    NSString *lastName = nil;
    NSString *lastPackage = nil;
    while(fgets(str, 999, file) != NULL) {
        if(strstr(str, [package UTF8String]) && strstr(str, "Name:")) shouldAdd = YES;
        if(strstr(str, "Package:")) lastPackage = [[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Package: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if(strstr(str, "Description:")) lastDesc = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Description: " withString:@""];
        if(strstr(str, "Depiction:")) lastDepiction = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Depiction: " withString:@""];
        if(strstr(str, "Filename:")) lastFilename = [[[NSString stringWithFormat:@"%@%@",fullURL,[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Filename: " withString:@""]] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if(strstr(str, "Name:")) lastName = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Name: " withString:@""];
        if(strlen(str) < 2 && shouldAdd) {
            [_searchNames addObject:lastName];
            [_searchDescs addObject:lastDesc];
            [_searchPackages addObject:lastPackage];
            [_searchDepictions addObject:lastDepiction];
            [_searchFilenames addObject:lastFilename];
            shouldAdd = NO;
        }
    }
    fclose(file);
}

- (void)showDepictionForPackageWithIndexPath:(NSIndexPath *)indexPath {
    ViewController *viewController = [[ViewController alloc] init];
    viewController.packageIndex = (int)indexPath.row;
    if([viewController isPackageInstalled:[_searchPackages objectAtIndex:indexPath.row]]) [viewController.aboutButton setTitle:@"Options" forState:UIControlStateNormal];
    else [viewController.aboutButton setTitle:@"Install" forState:UIControlStateNormal];
    NSString *depictionString = [_searchDepictions objectAtIndex:indexPath.row];
    depictionString = [depictionString stringByReplacingOccurrencesOfString:@" " withString:@""];
    depictionString = [depictionString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [_depictionWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:depictionString]]];
    _depictionWebView.hidden = NO;
    [self.view bringSubviewToFront:_depictionWebView];
    [self.view bringSubviewToFront:viewController.navigationBar];
}

UIAlertView *optionsAlert;
- (void)showPackageOptions {
    optionsAlert = [[UIAlertView alloc] initWithTitle:@"Options" message:@"Select an option to do with the package" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", @"Reinstall", nil];
    [optionsAlert show];
}

- (void)messageWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
