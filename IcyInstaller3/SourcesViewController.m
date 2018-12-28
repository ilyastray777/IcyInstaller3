//
//  SourcesViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/20/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import "SourcesViewController.h"
#import "IcyUniversalMethods.h"

@interface SourcesViewController ()
@end

@implementation SourcesViewController
UITableView *_sourcesTableView;
UIRefreshControl *sourcesRefreshControl;

- (id)init {
    if(self = [super init]) {
        // Get third party source list
        // 11 - shortest link that can ever exist: http://a.co, if it's less that this - it's not a valid sources.list file
        if([[[NSFileManager defaultManager] attributesOfItemAtPath:@"/var/mobile/Media/Icy/sources.list" error:nil] fileSize] >= 11) {
            NSString *sources = [NSString stringWithContentsOfFile:@"/var/mobile/Media/Icy/sources.list" encoding:NSUTF8StringEncoding error:nil];
            sources = [sources substringToIndex:sources.length - 1];
            self.sourceLinks = [[NSMutableArray alloc] initWithArray:[sources componentsSeparatedByString:@"\n"]];
        }
        self.sources = [[NSMutableArray alloc] init];
        for(id object in [[NSUserDefaults standardUserDefaults] objectForKey:@"sourceNames"]) [self.sources addObject:object];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Sources";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Manage" style:UIBarButtonItemStylePlain target:self action:@selector(manage)];
    // Get device model
    struct utsname systemInfo;
    uname(&systemInfo);
    _deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    // This line of code won't make any sense to you at first...
    // But it actually manages to do something...
    // If you try to remove this line, the statusCodeOfFileAtURL method won't work anymore.
    // So if in over a decade you'll try to do something here and remove it...
    // You have been warned.
    [self statusCodeOfFileAtURL:@"http://artikushg.yourepo.com/Release"];
    // Get third party source list
    if([[[NSFileManager defaultManager] attributesOfItemAtPath:@"/var/mobile/Media/Icy/sources.list" error:nil] fileSize] >= 11) {
        NSString *sources = [NSString stringWithContentsOfFile:@"/var/mobile/Media/Icy/sources.list" encoding:NSUTF8StringEncoding error:nil];
        sources = [sources substringToIndex:sources.length - 1];
        // 11 - shortest link that can ever exist: http://a.co, if it's less that this - it's not a valid sources.list file
        self.sourceLinks = [[NSMutableArray alloc] initWithArray:[sources componentsSeparatedByString:@"\n"]];
    }
    self.sources = [[NSMutableArray alloc] init];
    for(id object in [[NSUserDefaults standardUserDefaults] objectForKey:@"sourceNames"]) [self.sources addObject:object];
    // The tableview
    _sourcesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height) style:UITableViewStylePlain];
    _sourcesTableView.delegate = self;
    _sourcesTableView.dataSource = self;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) _sourcesTableView.backgroundColor = [UIColor blackColor];
    [_sourcesTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    sourcesRefreshControl = [[UIRefreshControl alloc] init];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) [sourcesRefreshControl setTintColor:[UIColor whiteColor]];
    [_sourcesTableView addSubview:sourcesRefreshControl];
    [sourcesRefreshControl addTarget:self action:@selector(refreshSources) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_sourcesTableView];
    // Navbar
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
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
}

- (void)resetFrames {
    _sourcesTableView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return _sources.count;
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
    cell.textLabel.text = [[_sources objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self removeRepoAtIndexPath:indexPath];
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    [self.view endEditing:YES];
}

+ (UITableView *)getSourcesTableView {
    return _sourcesTableView;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView == manageAlert && buttonIndex == 1) NSLog(@"ETA SON"); //[self updates];
    else if(alertView == manageAlert && buttonIndex == 2) [self addSource];
    else if(alertView == addSourceAlert && buttonIndex != alertView.cancelButtonIndex) {
        long releaseStatusCode = [self statusCodeOfFileAtURL:[NSString stringWithFormat:@"%@/Release",[alertView textFieldAtIndex:0].text]];
        if(releaseStatusCode != 200) {
            [self messageWithTitle:@"Error" message:[NSString stringWithFormat:@"Requesting the \"Release\" file of the repository returned the error code %ld or another error. This means a readable third-party source no longer exists at this URL (or it actually never did), has been moved or temporairly taken down. You can try contacting the repository owner or the developer of Icy Installer by sending the contents of the /var/mobile/Media/Icy/log.txt file.",releaseStatusCode]];
            NSLog(@"Response code: %ld",releaseStatusCode);
            return;
        }
        long packagesStatusCode = [self statusCodeOfFileAtURL:[NSString stringWithFormat:@"%@/Packages.bz2",[alertView textFieldAtIndex:0].text]];
        if(packagesStatusCode != 200) {
            [self messageWithTitle:@"Error" message:[NSString stringWithFormat:@"Requesting the \"Packages.bz2\" file of the repository returned the error code %ld or another error. This means a readable third-party source no longer exists at this URL (or it actually never did), has been moved or temporairly taken down. You can try contacting the repository owner or the developer of Icy Installer by sending the contents of the /var/mobile/Media/Icy/log.txt file.",packagesStatusCode]];
            NSLog(@"Response code: %ld",packagesStatusCode);
            return;
        }
        if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/sources.list" isDirectory:nil]) [[NSFileManager defaultManager] createFileAtPath:@"/var/mobile/Media/Icy/sources.list" contents:nil attributes:nil];
        if([[NSString stringWithContentsOfFile:@"/var/mobile/Media/Icy/sources.list" encoding:NSUTF8StringEncoding error:nil] rangeOfString:[alertView textFieldAtIndex:0].text].location != NSNotFound) {
            [self messageWithTitle:@"Error" message:@"This source is already added to Icy Installer's source list."];
            return;
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:@"/var/mobile/Media/Icy/sources.list"];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[[NSString stringWithFormat:@"%@\n",[alertView textFieldAtIndex:0].text] dataUsingEncoding:NSUTF8StringEncoding]];
        // 11 - shortest link that can ever exist: http://a.co, if it's less that this - it's not a valid sources.list file
        if([[[NSFileManager defaultManager] attributesOfItemAtPath:@"/var/mobile/Media/Icy/sources.list" error:nil] fileSize] >= 11) {
            NSString *sources = [NSString stringWithContentsOfFile:@"/var/mobile/Media/Icy/sources.list" encoding:NSUTF8StringEncoding error:nil];
            // Remove last \n (newline character)
            sources = [sources substringToIndex:sources.length - 1];
            _sourceLinks = [[NSMutableArray alloc] initWithArray:[sources componentsSeparatedByString:@"\n"]];
            [_sources addObject:[[[[[[NSString stringWithContentsOfURL:[NSURL URLWithString:[[_sourceLinks lastObject] stringByAppendingString:@"/Release"]] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"Origin: " withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
            [self downloadFileFromURLString:[[_sourceLinks lastObject] stringByAppendingString:@"/Packages.bz2"] saveFilename:[NSString stringWithFormat:@"Repos/%@.bz2",[_sources lastObject]]];
            NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:_sources];
            _sources = [[NSMutableArray alloc] initWithArray:[orderedSet array]];
            [[NSUserDefaults standardUserDefaults] setObject:_sources forKey:@"sourceNames"];
            [_sourcesTableView reloadData];
            //  SSS    TTTTTTT    OOOOOO    PPPP
            //  S         T       O    O    P  P
            //   S        T       O    O    PPPP
            // SSS        T       OOOOOO    P
            // If you're reading this because of the ugly ASCII art I made, you're either an artikus or someone else. If you aren't an artikus, stop reading because this is just a message I left to myself to return here and optimize this thing.
            [self messageWithTitle:@"Done" message:@"The source was added to your list."];
        }
    } else if(alertView == removeRepoAlert && buttonIndex != alertView.cancelButtonIndex) {
        [[NSFileManager defaultManager] removeItemAtPath:[@"/var/mobile/Media/Icy/Repos/" stringByAppendingString:[_sources objectAtIndex:repoRemoveIndex]] error:nil];
        [_sources removeObjectAtIndex:repoRemoveIndex];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sourceNames"];
        [[NSUserDefaults standardUserDefaults] setObject:_sources forKey:@"sourceNames"];
        [_sourcesTableView reloadData];
        [[[NSString stringWithContentsOfFile:@"/var/mobile/Media/Icy/sources.list" encoding:NSUTF8StringEncoding error:nil] stringByReplacingOccurrencesOfString:[[_sourceLinks objectAtIndex:repoRemoveIndex] stringByAppendingString:@"\n"] withString:@""] writeToFile:@"/var/mobile/Media/Icy/sources.list" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

- (void)updates {
    // TODO
}

UIAlertView *manageAlert;
- (void)manage {
    manageAlert = [[UIAlertView alloc] initWithTitle:@"Manage" message:nil delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Scan updates", @"Add source", nil];
    [manageAlert show];
}

UIAlertView *removeRepoAlert;
int repoRemoveIndex;
- (void)removeRepoAtIndexPath:(NSIndexPath *)indexPath {
    repoRemoveIndex = (int)indexPath.row;
    removeRepoAlert = [[UIAlertView alloc] initWithTitle:@"Confirm action" message:[NSString stringWithFormat:@"Please confirm that you really want to remove \"%@\" from the list of your sources.",[_sourcesTableView cellForRowAtIndexPath:indexPath].textLabel.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", nil];
    [removeRepoAlert show];
}

UIAlertView *addSourceAlert;
- (void)addSource {
    addSourceAlert = [[UIAlertView alloc] initWithTitle:@"Add source" message:@"Please enter the URL of the source NOT INCLUDING \"www\", but INCLUDING \"http:// or https://\"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    addSourceAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [addSourceAlert show];
}

- (void)refreshSources {
    if(![IcyUniversalMethods isNetworkAvailable]) {
        [sourcesRefreshControl endRefreshing];
        [self messageWithTitle:@"No internet..." message:@"Please connect to the internet and try again later."];
        return;
    }
    // Yoo wassup
    // This is the old block of code that used to download repos one-by-one, taking 30+ seconds to reload just the default ones.
    // The new one takes like 10 seconds to refresh ALL my repos :P
    // That's here for historical purposes (c) stackoverflow people
    /*NSError *err = nil;
    for(id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" error:nil]) {
        if([object isEqualToString:@"updates"]) continue;
        [[NSFileManager defaultManager] removeItemAtPath:[@"/var/mobile/Media/Icy/Repos/" stringByAppendingString:object] error:&err];
    }
    if(err) {
        [self messageWithTitle:@"Error" message:[err localizedDescription]];
        return;
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/sources.list"]) [[NSFileManager defaultManager] createFileAtPath:@"/var/mobile/Media/Icy/sources.list" contents:nil attributes:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        // BigBoss
        [[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://apt.thebigboss.org/repofiles/cydia/dists/stable/main/binary-iphoneos-arm/Packages.bz2"]] writeToFile:@"/var/mobile/Media/Icy/Repos/BigBoss.bz2" atomically:YES];
        // ModMyi
        if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/Repos/ModMyi" isDirectory:nil]) [[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://apt.modmyi.com/dists/stable/main/binary-iphoneos-arm/Packages.bz2"]] writeToFile:@"/var/mobile/Media/Icy/Repos/ModMyi.bz2" atomically:YES];
        // Zodttd and MacCiti
        if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/Repos/Zodttd" isDirectory:nil]) [[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://zodttd.saurik.com/repo/cydia/dists/stable/main/binary-iphoneos-arm/Packages.bz2"]] writeToFile:@"/var/mobile/Media/Icy/Repos/Zodttd.bz2" atomically:YES];
        // Saurik's repo
        [[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://apt.saurik.com/cydia/Packages.bz2"]] writeToFile:@"/var/mobile/Media/Icy/Repos/Saurik.bz2" atomically:YES];
        for(id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos/" error:nil]) bunzip_one([[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@",object] UTF8String], [[[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@",object] stringByReplacingOccurrencesOfString:@".bz2" withString:@""] UTF8String]);
        // Third party repos
        for(id object in self->_sourceLinks) {
            long releaseResponse = [self statusCodeOfFileAtURL:[object stringByAppendingString:@"/Release"]];
            if(releaseResponse != 200) {
                NSLog(@"Request returned code not equal to 200 (%ld)",releaseResponse);
                [self messageWithTitle:@"Error" message:[NSString stringWithFormat:@"Consider removing the  \"%@\" source from your list because it does not seem to respond.",object]];
            } else {
                [self->_sources addObject:[[[[[[NSString stringWithContentsOfURL:[NSURL URLWithString:[object stringByAppendingString:@"/Release"]] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"Origin: " withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
                [self downloadFileFromURLString:[object stringByAppendingString:@"/Packages.bz2"] saveFilename:[NSString stringWithFormat:@"Repos/%@.bz2",[self->_sources lastObject]]];
            }
        }
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:self->_sources];
        self->_sources = [[NSMutableArray alloc] initWithArray:[orderedSet array]];
        [[NSUserDefaults standardUserDefaults] setObject:self->_sources forKey:@"sourceNames"];
        [self stripSources];
        [_sourcesTableView reloadData];
        [self messageWithTitle:@"Done" message:@"Sources refreshed."];
        [sourcesRefreshControl endRefreshing];
    });*/
    for(id object in self->_sourceLinks) {
        long releaseResponse = [self statusCodeOfFileAtURL:[object stringByAppendingString:@"/Release"]];
        if(releaseResponse != 200) {
            NSLog(@"Request returned code not equal to 200 (%ld)",releaseResponse);
            [self messageWithTitle:@"Error" message:[NSString stringWithFormat:@"Consider removing the  \"%@\" source from your list because it does not seem to respond correctly.",object]];
        } else {
            [self->_sources addObject:[[[[[[NSString stringWithContentsOfURL:[NSURL URLWithString:[object stringByAppendingString:@"/Release"]] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"Origin: " withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
            //[self downloadFileFromURLString:[object stringByAppendingString:@"/Packages.bz2"] saveFilename:[NSString stringWithFormat:@"Repos/%@.bz2",[self->_sources lastObject]]];
        }
    }
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:self->_sources];
    self->_sources = [[NSMutableArray alloc] initWithArray:[orderedSet array]];
    [[NSUserDefaults standardUserDefaults] setObject:self->_sources forKey:@"sourceNames"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"User-Agent": @"Telesphoreo APT-HTTP/1.0.592", @"X-Firmware": [[UIDevice currentDevice] systemVersion], @"X-Machine": _deviceModel, @"X-Unique-ID":[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"]};
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *filenames = [NSMutableArray arrayWithObjects:@"BigBoss.bz2", @"ModMyi.bz2", @"Zodttd.bz2", @"Saurik.bz2", nil];
    NSMutableArray *urls = [NSMutableArray arrayWithObjects:@"http://apt.thebigboss.org/repofiles/cydia/dists/stable/main/binary-iphoneos-arm/Packages.bz2", @"http://apt.modmyi.com/dists/stable/main/binary-iphoneos-arm/Packages.bz2", @"http://zodttd.saurik.com/repo/cydia/dists/stable/main/binary-iphoneos-arm/Packages.bz2", @"http://apt.saurik.com/cydia/Packages.bz2", nil];
    for (id object in _sourceLinks) [urls addObject:[object stringByAppendingString:@"/Packages.bz2"]];
    for (id object in _sources) [filenames addObject:[object stringByAppendingString:@".bz2"]];
    __block unsigned long finished = 0;
    // I know I'm supposed to write my own code reading the documentation and stuff, but this is just a stackoverflow copypasta that I edited a bit to save to the correct directories. It works though
    for (NSString *filename in filenames) {
        NSURL *url = [NSURL URLWithString:[urls objectAtIndex:[filenames indexOfObject:filename]]];
        NSURLSessionTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            NSString *finalPath = [@"/var/mobile/Media/Icy/Repos" stringByAppendingPathComponent:filename];
            BOOL success;
            NSError *fileManagerError;
            if ([fileManager fileExistsAtPath:finalPath]) {
                success = [fileManager removeItemAtPath:finalPath error:&fileManagerError];
                NSAssert(success, @"removeItemAtPath error: %@", fileManagerError);
            }
            success = [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:finalPath] error:&fileManagerError];
            NSAssert(success, @"moveItemAtURL error: %@", fileManagerError);
            bunzip_one([finalPath UTF8String], [[finalPath stringByReplacingOccurrencesOfString:@".bz2" withString:@""] UTF8String]);
            NSLog(@"finished %@", filename);
            [self stripSource:[filename stringByReplacingOccurrencesOfString:@".bz2" withString:@""]];
            finished = finished + 1;
            if(finished == filenames.count) {
                //[self messageWithTitle:@"Done" message:@"Sources refreshed."];
                [sourcesRefreshControl endRefreshing];
            }
        }];
        [downloadTask resume];
    }
}

int bunzip_one(const char file[999], const char output[999]) {
    FILE *f = fopen(file, "r+b");
    FILE *outfile = fopen(output, "w");
    fprintf(outfile, "");
    outfile = fopen(output, "a");
    int bzError;
    BZFILE *bzf;
    char buf[4096];
    bzf = BZ2_bzReadOpen(&bzError, f, 0, 0, NULL, 0);
    if (bzError != BZ_OK) {
        printf("E: BZ2_bzReadOpen: %d\n", bzError);
        return -1;
    }
    while (bzError == BZ_OK) {
        int nread = BZ2_bzRead(&bzError, bzf, buf, sizeof buf);
        if (bzError == BZ_OK || bzError == BZ_STREAM_END) {
            size_t nwritten = fwrite(buf, 1, nread, stdout);
            fprintf(outfile, "%s", buf);
            if (nwritten != (size_t) nread) {
                printf("E: short write\n");
                return -1;
            }
        }
    }
    if (bzError != BZ_STREAM_END) {
        printf("E: bzip error after read: %d\n", bzError);
        return -1;
    }
    BZ2_bzReadClose(&bzError, bzf);
    fclose(outfile);
    fclose(f);
    return 0;
}

- (void)stripSource:(NSString *)object {
    if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@_stripped",object]]) [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@_stripped",object] error:nil];
    FILE *input = fopen([[@"/var/mobile/Media/Icy/Repos/" stringByAppendingString:object] UTF8String], "r");
        FILE *output = fopen([[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@_stripped",object] UTF8String], "a");
    char str[999];
    BOOL hadDepiction = NO;
    while(fgets(str, 999, input) != NULL) {
        if(strstr(str, "Package:") || strstr(str, "Name:") || strstr(str, "Filename:") || strstr(str, "Description:") || strstr(str, "Version:" ) || strstr(str, "Depends:") || strstr(str, "Conflicts:")) fprintf(output, "%s", str);
        if(strstr(str, "Depiction:")) {
            fprintf(output, "%s", str);
            hadDepiction = YES;
        }
        if(strlen(str) < 3) {
            if(!hadDepiction) {
                // Workaround for packages that don't have depictions. Was lazy to implement a proper search algorithm for this bug so just did it like this
                fprintf(output, "%s", "Depiction: ITHASNODEPICTION");
            }
            fprintf(output, "%s", "\n\n");
            hadDepiction = NO;
        }
    }
    fclose(input);
    fclose(output);
    unlink([[@"/var/mobile/Media/Icy/Repos/" stringByAppendingString:object] UTF8String]);
    unlink([[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@.bz2",object] UTF8String]);
    rename([[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@_stripped",object] UTF8String], [[@"/var/mobile/Media/Icy/Repos/" stringByAppendingString:object] UTF8String]);
}

- (long)statusCodeOfFileAtURL:(NSString *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
        [mutableRequest setValue:@"Telesphoreo APT-HTTP/1.0.592" forHTTPHeaderField:@"User-Agent"];
        [mutableRequest setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"X-Firmware"];
        [mutableRequest setValue:_deviceModel forHTTPHeaderField:@"X-Machine"];
        [mutableRequest setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"] forHTTPHeaderField:@"X-Unique-ID"];
    [NSURLConnection sendSynchronousRequest:mutableRequest returningResponse:&response error:&error];
    if(error) NSLog(@"Status code: %ld\nError: %@",(long)response.statusCode,[error localizedDescription]);
    return (long)response.statusCode;
}

- (void)downloadFileFromURLString:(NSString *)urlString saveFilename:(NSString *)filename {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"User-Agent": @"Telesphoreo APT-HTTP/1.0.592", @"X-Firmware": [[UIDevice currentDevice] systemVersion], @"X-Machine": _deviceModel, @"X-Unique-ID":[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"]};
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            return;
        }
        [data writeToFile:[NSString stringWithFormat:@"/var/mobile/Media/Icy/%@",filename] atomically:YES];
        // Fallback: sometimes the above code does not seem to work, so we use the simplest way of downloading files
        if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/var/mobile/Media/Icy/%@",filename]]) {
            NSData *fallbackData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            if(fallbackData) [fallbackData writeToFile:[NSString stringWithFormat:@"/var/mobile/Media/Icy/%@",filename] atomically:YES];
        }
        char cfilename[999];
        snprintf(cfilename, sizeof(cfilename), "/var/mobile/Media/Icy/%s", [filename UTF8String]);
        char coutname[999];
        snprintf(coutname, sizeof(coutname), "/var/mobile/Media/Icy/%s", [[filename stringByReplacingOccurrencesOfString:@".bz2" withString:@""] UTF8String]);
        bunzip_one(cfilename, coutname);
        [self stripSource:[[filename stringByReplacingOccurrencesOfString:@"Repos/" withString:@""] stringByReplacingOccurrencesOfString:@".bz2" withString:@""]];
    }];
    [task resume];
}

- (void)messageWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
