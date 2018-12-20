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
NSMutableArray *packageQuery;
NSMutableArray *packageQueryNames;
UITableView *queryTableView;
UIBarButtonItem *doneButton;
UINavigationBar *DPKGNavigationBar;

- (void)viewDidLoad {
    packageQuery = [[NSMutableArray alloc] init];
    packageQueryNames = [[NSMutableArray alloc] init];
    [super viewDidLoad];
    progressTextView = [[UITextView alloc] initWithFrame:CGRectMake(0,64,self.view.bounds.size.width,self.view.bounds.size.height - 64)];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        progressTextView.backgroundColor = [UIColor blackColor];
        progressTextView.textColor = [UIColor whiteColor];
        self.view.backgroundColor = [UIColor blackColor];
    }
    else progressTextView.backgroundColor = [UIColor whiteColor];
    progressTextView.font = [UIFont boldSystemFontOfSize:15];
    progressTextView.editable = NO;
    progressTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.view addSubview:progressTextView];
    progressTextView.hidden = YES;
    // TableView with packages in query
    queryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height) style:UITableViewStylePlain];
    queryTableView.delegate = self;
    queryTableView.dataSource = self;
    [queryTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    queryTableView.backgroundColor = [UIColor clearColor];
    queryTableView.allowsSelection = NO;
    queryTableView.contentInset = UIEdgeInsetsMake(64,0,0,0);
    queryTableView.hidden = NO;
    [self.view addSubview:queryTableView];
    // Navbar
    DPKGNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,64)];
    UINavigationItem *titleNavigationItem = [[UINavigationItem alloc] initWithTitle:@"Installing..."];
    doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStyleDone target:self action:@selector(actuallyRunDPKG)];
    titleNavigationItem.rightBarButtonItem = doneButton;
    [DPKGNavigationBar setItems:@[titleNavigationItem]];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        DPKGNavigationBar.tintColor = [UIColor orangeColor];
        DPKGNavigationBar.barTintColor = [UIColor blackColor];
        DPKGNavigationBar.barStyle = UIBarStyleBlack;
        self.view.backgroundColor = [UIColor blackColor];
    }
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    titleNavigationItem.leftBarButtonItem = leftButton;
    [self.view addSubview:DPKGNavigationBar];
    [self resetFrames];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resetFrames];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self resetFrames];
}

- (void)resetFrames {
    DPKGNavigationBar.frame = CGRectMake(0,0,self.view.bounds.size.width,64);
    queryTableView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    progressTextView.frame = CGRectMake(0,64,self.view.bounds.size.width,self.view.bounds.size.height - 64);
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// TableView stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return packageQueryNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = (UITableViewCell *) [theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.backgroundColor = [UIColor clearColor];
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    cell.textLabel.text = [packageQueryNames objectAtIndex:indexPath.row];
    return cell;
}

- (void)addItemToQuery:(NSString *)item {
    [packageQuery addObject:item];
}

- (void)addNameToQuery:(NSString *)name {
    [packageQueryNames addObject:name];
    [queryTableView reloadData];
}

- (void)actuallyRunDPKG {
    IcyUniversalMethods *icyUniversalMethods = [[IcyUniversalMethods alloc] init];
    progressTextView.text = [progressTextView.text stringByAppendingString:@"Preparing to run freeze binary...\n"];
    progressTextView.hidden = NO;
    queryTableView.hidden = YES;
    doneButton.enabled = NO;
    for (NSString *package in packageQuery) {
        if(SYSTEM_VERSION_LESS_THAN(@"11.0")) progressTextView.text = [progressTextView.text stringByAppendingString:[IcyUniversalMethods runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze"] withArguments:@[@"-i", [NSString stringWithFormat:@"/var/mobile/Media/%@",package]] errors:NO]];
        else progressTextView.text = [progressTextView.text stringByAppendingString:[IcyUniversalMethods runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze11"] withArguments:@[@"-i", [NSString stringWithFormat:@"/var/mobile/Media/%@",package]] errors:NO]];
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"/var/mobile/Media/%@",package] error:nil];
    }
    progressTextView.text = [progressTextView.text stringByAppendingString:@"\nFinished running DPKG."];
    [icyUniversalMethods reload];
    AVPlayer *completion = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/Done.caf"]]];
    [completion play];
}

@end
