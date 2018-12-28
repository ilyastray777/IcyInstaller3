//
//  SearchViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/20/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import "SearchViewController.h"
#import "SourcesViewController.h"
#import "ManageViewController.h"
#import "IcyUniversalMethods.h"
#import "NSTask.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

UITableView *_searchTableView;
static int _packageIndex;
static NSMutableArray *_searchFilenames;
NSString *_filename;
UITextField *_searchField;
UIProgressView *searchProgress;
UILabel *searchLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Initialize arrays
    _searchPackages = [[NSMutableArray alloc] init];
    _searchNames = [[NSMutableArray alloc] init];
    _searchDescs = [[NSMutableArray alloc] init];
    _searchDepictions = [[NSMutableArray alloc] init];
    _searchFilenames = [[NSMutableArray alloc] init];
    
    // Label saying "Search"
    searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,50,self.view.bounds.size.width - 130,40)];
    searchLabel.backgroundColor = [UIColor clearColor];
    [searchLabel setFont:[UIFont boldSystemFontOfSize:30]];
    searchLabel.text = @"Search";
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) searchLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:searchLabel];
    // Search texfield
    _searchField = [[UITextField alloc] initWithFrame:CGRectMake(15,100,self.view.bounds.size.width - 30,35)];
    _searchField.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    UIView *searchImageView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 27, 17)];
    UIImageView *searchImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons/Search.png"]];
    searchImage.frame = CGRectMake(5, 0, 17, 17);
    searchImage.image = [searchImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) searchImage.tintColor = [UIColor orangeColor];
    else searchImage.tintColor = [UIColor grayColor];
    [searchImageView addSubview:searchImage];
    _searchField.leftViewMode = UITextFieldViewModeAlways;
    _searchField.leftView = searchImageView;
    _searchField.returnKeyType = UIReturnKeySearch;
    _searchField.delegate = self;
    _searchField.layer.masksToBounds = YES;
    _searchField.layer.cornerRadius = 5;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) _searchField.textColor = [UIColor whiteColor];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) _searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
    else _searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: [UIColor orangeColor]}];
    [self.view addSubview:_searchField];
    _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,150,self.view.bounds.size.width,self.view.bounds.size.height - 100) style:UITableViewStylePlain];
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    [_searchTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _searchTableView.contentInset = UIEdgeInsetsMake(0,0,100,0);
    _searchTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_searchTableView];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        self.view.backgroundColor = [UIColor blackColor];
        _searchTableView.backgroundColor = [UIColor blackColor];
        _searchField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.view.backgroundColor = [UIColor blackColor];
    }
    [self resetFrames];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resetFrames];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self resetFrames];
    PackageInfoViewController *infoViewController = [[PackageInfoViewController alloc] init];
    [infoViewController packageInfoWithIndexPath:[NSIndexPath indexPathWithIndex:1]];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:infoViewController] animated:YES completion:nil];
}

- (void)resetFrames {
    _searchField.frame = CGRectMake(15,100,self.view.bounds.size.width - 30,35);
    _searchTableView.frame = CGRectMake(0,150,self.view.bounds.size.width,self.view.bounds.size.height - 100);
    searchLabel.frame = CGRectMake(15,50,self.view.bounds.size.width - 130,40);
    if([IcyUniversalMethods hasTopNotch] && UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        _searchField.frame = CGRectMake(55,100,self.view.bounds.size.width - 100,35);
        searchLabel.frame = CGRectMake(55,50,self.view.bounds.size.width - 135,40);
    }
}

+ (UITextField *)getSearchField {
    return _searchField;
}

+ (UITableView *)getSearchTableView {
    return _searchTableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return _searchNames.count;
}
 
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     static NSString *cellIdentifier = @"cell";
     UITableViewCell *cell = (UITableViewCell *) [theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
     if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
    }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    }
     if(_searchNames.count > indexPath.row) cell.textLabel.text = [_searchNames objectAtIndex:indexPath.row];
     if(_searchDescs.count > indexPath.row) cell.detailTextLabel.text = [_searchDescs objectAtIndex:indexPath.row];
     return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showDepictionForPackageWithIndexPath:indexPath];
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.text.length < 3) {
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
    UIActivityIndicatorView *wheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    wheel.center = self.view.center;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) wheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [self.view addSubview:wheel];
    [wheel startAnimating];
    // For loop to search in all repos
    NSArray *repos = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos/" error:NULL];
    __block int i = 0;
    for (id repo in repos) {
        SourcesViewController *sourcesViewController = [[SourcesViewController alloc] init];
        NSString *fullURL = nil;
        if([repo rangeOfString:@".bz2"].location != NSNotFound) continue;
        if([repo isEqualToString:@"ModMyi"]) fullURL = @"http://modmyi.saurik.com/";
        else if ([repo isEqualToString:@"Zodttd"]) fullURL = @"http://cydia.zodttd.com/repo/cydia/";
        else if([repo isEqualToString:@"Saurik"]) fullURL = @"http://apt.saurik.com/";
        else if([repo isEqualToString:@"BigBoss"]) fullURL = @"http://apt.thebigboss.org/repofiles/cydia/";
        else if([repo isEqualToString:@"updates"]) continue;
        else fullURL = [sourcesViewController.sourceLinks objectAtIndex:[sourcesViewController.sources indexOfObject:repo]];
        if(![[fullURL substringFromIndex:fullURL.length - 1] isEqualToString:@"/"]) fullURL = [fullURL stringByAppendingString:@"/"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            i++;
            [self searchForPackage:package inRepo:[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@",repo] withFullURLString:fullURL];
            if(i == repos.count - 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wheel stopAnimating];
                    wheel.hidden = YES;
                    [_searchTableView reloadData];
                });
            }
        });
    }
}

- (void)searchForPackage:(NSString *)package inRepo:(NSString *)repo withFullURLString:(NSString *)fullURL {
    char str[999];
    const char *filename = [repo UTF8String];
    NSString *whatToSearch = [NSString stringWithFormat:@"Name: %@", package];
    NSString *strictSearch = [NSString stringWithFormat:@"Package: %@\n",package];
    FILE *file = fopen(filename, "r");
    BOOL shouldAdd = NO;
    BOOL shouldDoWeirdStuffWithName = NO;
    NSString *lastDesc = nil;
    NSString *lastDepiction = @"ITHASNODEPICTION";
    NSString *lastFilename = nil;
    NSString *lastName = nil;
    NSString *lastPackage = nil;
    NSString *lastVersion = nil;
    while(fgets(str, 999, file) != NULL) {
        if(strcasestr(str, [whatToSearch UTF8String])) shouldAdd = YES;
        if(strcmp(str, [strictSearch UTF8String]) == 0) {
            shouldAdd = YES;
            shouldDoWeirdStuffWithName = YES;
        }
        if(strstr(str, "Package:")) {
            lastPackage = [[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Package: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            if(shouldDoWeirdStuffWithName) lastName = lastPackage;
        }
        if(strstr(str, "Description:")) lastDesc = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Description: " withString:@""];
        if(strstr(str, "Depiction:")) lastDepiction = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Depiction: " withString:@""];
        if(strstr(str, "Filename:")) lastFilename = [[[NSString stringWithFormat:@"%@%@",fullURL,[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Filename: " withString:@""]] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if(strstr(str, "Version:")) lastVersion = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Version: " withString:@""];
        if(strstr(str, "Name:")) lastName = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Name: " withString:@""];
        if(strlen(str) < 2 && shouldAdd) {
            if(shouldDoWeirdStuffWithName) lastName = lastPackage;
            NSString *add = @"";
            if(lastVersion != nil) add = [[lastName stringByAppendingString:lastVersion] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            else add = lastName;
            if(add != nil) [_searchNames addObject:add];
            if(lastDesc != nil) [_searchDescs addObject:lastDesc];
            if(lastPackage != nil) [_searchPackages addObject:lastPackage];
            [_searchDepictions addObject:lastDepiction];
            if(lastFilename != nil) [_searchFilenames addObject:lastFilename];
            if(_searchPackages.count > _searchNames.count) [_searchNames addObject:[_searchPackages lastObject]];
            shouldAdd = NO;
            lastDesc = nil;
            lastDepiction = @"ITHASNODEPICTION";
            lastFilename = nil;
            lastName = nil;
            lastPackage = nil;
            lastVersion = nil;
        }
    }
    fclose(file);
}

- (NSString *)filenameOfPackage:(NSString *)package fromRepo:(NSString *)repo withFullURL:(NSString *)fullURL {
    BOOL shouldReturn = NO;
    FILE *file = fopen([[@"/var/mobile/Media/Icy/Repos/" stringByAppendingString:repo] UTF8String], "r");
    char str[999];
    const char *search = [[NSString stringWithFormat:@"Package: %@\n",package] UTF8String];
    while (fgets(str, 999, file) != NULL) {
        if(strcmp(str, search) == 0) shouldReturn = YES;
        if(strstr(str, "Filename:") && shouldReturn) {
            NSString *filename = [[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Filename: " withString:@""];
            return [NSString stringWithFormat:@"%@%@",fullURL,filename];
        }
    }
    fclose(file);
    return @"NONE";
}

- (void)showDepictionForPackageWithIndexPath:(NSIndexPath *)indexPath {
    if(![IcyUniversalMethods isNetworkAvailable]) {
        [IcyUniversalMethods messageWithTitle:@"Error" message:@"This action requires an internet connection. If you are connected to the internet, but the problem still occurs, try relaunching Icy."];
        return;
    }
    _packageIndex = (int)indexPath.row;
    int buttonType = 1;
    if([self isPackageInstalled:[_searchPackages objectAtIndex:indexPath.row]]) buttonType = 2;
    NSString *depictionString = [_searchDepictions objectAtIndex:indexPath.row];
    depictionString = [depictionString stringByReplacingOccurrencesOfString:@" " withString:@""];
    depictionString = [depictionString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    DepictionViewController *depictionViewController = [[DepictionViewController alloc] initWithURLString:depictionString removeBundleID:[_searchPackages objectAtIndex:indexPath.row] downloadURLString:[_searchFilenames objectAtIndex:indexPath.row] buttonType:buttonType packageName:[_searchNames objectAtIndex:indexPath.row]];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:depictionViewController] animated:YES completion:nil];
}

+ (int)getPackageIndex {
    return _packageIndex;
}

+ (NSMutableArray *)getSearchFilenames {
    return _searchFilenames;
}

- (void)messageWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
}

- (BOOL)isPackageInstalled:(NSString *)package {
    if([[IcyUniversalMethods runCommandWithOutput:@"/usr/bin/dpkg" withArguments:@[@"-s", package] errors:YES] rangeOfString:@"is not installed"].location == NSNotFound) return YES;
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
