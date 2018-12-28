//
//  IcyDPKGViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 10/26/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import "IcyDPKGViewController.h"
#import "IcyUniversalMethods.h"
#import <spawn.h>
#import <signal.h>

@import AVFoundation;

@interface IcyDPKGViewController ()

@end

@implementation IcyDPKGViewController

UITextView *progressTextView;
NSMutableArray *packageQuery;
NSMutableArray *packageQueryNames;
UITableView *queryTableView;
UIBarButtonItem *doneButton;

- (void)viewDidLoad {
    self.title = @"Installing...";
    packageQuery = [[NSMutableArray alloc] init];
    packageQueryNames = [[NSMutableArray alloc] init];
    [super viewDidLoad];
    progressTextView = [[UITextView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];
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
    queryTableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    queryTableView.delegate = self;
    queryTableView.dataSource = self;
    [queryTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    queryTableView.backgroundColor = [UIColor clearColor];
    queryTableView.allowsSelection = NO;
    queryTableView.hidden = NO;
    [self.view addSubview:queryTableView];
    // Navbar
    doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStyleDone target:self action:@selector(actuallyRunDPKG)];
    self.navigationItem.rightBarButtonItem = doneButton;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        UINavigationBar.appearance.tintColor = [UIColor orangeColor];
        UINavigationBar.appearance.barTintColor = [UIColor blackColor];
        UINavigationBar.appearance.barStyle = UIBarStyleBlack;
        self.view.backgroundColor = [UIColor blackColor];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];;
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
    queryTableView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    progressTextView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
    if([IcyUniversalMethods hasTopNotch]) progressTextView.textContainerInset = UIEdgeInsetsMake(10, 60, 10, 60);
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
        progressTextView.text = [progressTextView.text stringByAppendingString:[IcyUniversalMethods runCommandWithOutput:@"/usr/bin/freeze" withArguments:@[@"-i", [NSString stringWithFormat:@"/var/mobile/Media/%@",package]] errors:NO]];
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"/var/mobile/Media/%@",package] error:nil];
    }
    progressTextView.text = [progressTextView.text stringByAppendingString:@"\nFinished running DPKG."];
    [icyUniversalMethods reload];
}

// Yes + cuz alert called from + method
+ (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex != [alertView cancelButtonIndex]) {
        pid_t pid;
        int status;
        const char *argv[] = {"killall", "-9", "SpringBoard", NULL};
        posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char**)argv, NULL);
        waitpid(pid, &status, 0);
    }
}

UIAlertView *respringAlert;
+ (void)respring {
    respringAlert = [[UIAlertView alloc] initWithTitle:@"Respring needed" message:@"Would you like to respring now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    respringAlert.delegate = self;
    [respringAlert show];
}

@end
