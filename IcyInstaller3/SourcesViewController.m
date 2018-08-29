//
//  SourcesViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/20/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import "SourcesViewController.h"
#import "ViewController.h"

@interface SourcesViewController ()
@end

@implementation SourcesViewController
UITableView *_sourcesTableView;

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
    _sourcesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100) style:UITableViewStylePlain];
    _sourcesTableView.delegate = self;
    _sourcesTableView.dataSource = self;
    _sourcesTableView.backgroundColor = [UIColor clearColor];
    [_sourcesTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _sourcesTableView.contentInset = UIEdgeInsetsMake(0,0,60,0);
    if([(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        if(CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) _sourcesTableView.contentInset = UIEdgeInsetsMake(0,-160,60,0);
        else _sourcesTableView.contentInset = UIEdgeInsetsMake(0,-30,60,0);
    }
    [self.view addSubview:_sourcesTableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return _sources.count;
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
    if(alertView == manageAlert && buttonIndex == 1) [self refreshSources];
    else if(alertView == manageAlert && buttonIndex == 2) [self addSource];
    else if(alertView == addSourceAlert && buttonIndex != alertView.cancelButtonIndex) {
        long releaseStatusCode = [self statusCodeOfFileAtURL:[NSString stringWithFormat:@"http://%@/Release",[alertView textFieldAtIndex:0].text]];
        if(releaseStatusCode != 200) {
            [self messageWithTitle:@"Error" message:[NSString stringWithFormat:@"Requesting the \"Release\" file of the repository returned the error code %ld or another error. This means a readable third-party source no longer exists at this URL (or it actually never did), has been moved or temporairly taken down. You can try contacting the repository owner or the developer of Icy Installer by sending the contents of the /var/mobile/Media/Icy/log.txt file.",releaseStatusCode]];
            NSLog(@"Response code: %ld",releaseStatusCode);
            return;
        }
        long packagesStatusCode = [self statusCodeOfFileAtURL:[NSString stringWithFormat:@"http://%@/Packages.bz2",[alertView textFieldAtIndex:0].text]];
        if(packagesStatusCode != 200) {
            [self messageWithTitle:@"Error" message:[NSString stringWithFormat:@"Requesting the \"Packages.bz2\" file of the repository returned the error code %ld or another error. This means a readable third-party source no longer exists at this URL (or it actually never did), has been moved or temporairly taken down. You can try contacting the repository owner or the developer of Icy Installer by sending the contents of the /var/mobile/Media/Icy/log.txt file.",packagesStatusCode]];
            NSLog(@"Response code: %ld",packagesStatusCode);
            return;
        }
        if(![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Media/Icy/sources.list" isDirectory:nil]) [[NSFileManager defaultManager] createFileAtPath:@"/var/mobile/Media/Icy/sources.list" contents:nil attributes:nil];
        if([[NSString stringWithContentsOfFile:@"/var/mobile/Media/Icy/sources.list" encoding:NSUTF8StringEncoding error:nil] rangeOfString:[@"http://" stringByAppendingString:[alertView textFieldAtIndex:0].text]].location != NSNotFound) {
            [self messageWithTitle:@"Error" message:@"This source is already added to Icy Installer's source list."];
            return;
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:@"/var/mobile/Media/Icy/sources.list"];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[[NSString stringWithFormat:@"http://%@\n",[alertView textFieldAtIndex:0].text] dataUsingEncoding:NSUTF8StringEncoding]];
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
            [self stripSources];
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

UIAlertView *manageAlert;
- (void)manage {
    manageAlert = [[UIAlertView alloc] initWithTitle:@"Manage" message:nil delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Reload sources", @"Add source", nil];
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
    addSourceAlert = [[UIAlertView alloc] initWithTitle:@"Add source" message:@"Please enter the URL of the source WITHOUT including \"http(s)://\" or \"www\"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    addSourceAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [addSourceAlert show];
}

- (void)refreshSources {
    NSError *err = nil;
    for(id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" error:nil]) {
        if([object isEqualToString:@"updates"]) continue;
        [[NSFileManager defaultManager] removeItemAtPath:[@"/var/mobile/Media/Icy/Repos/" stringByAppendingString:object] error:&err];
    }
    if(err) {
        [self messageWithTitle:@"Error" message:[err localizedDescription]];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reloading sources..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
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
        for(id object in _sourceLinks) {
            long releaseResponse = [self statusCodeOfFileAtURL:[object stringByAppendingString:@"/Release"]];
            if(releaseResponse != 200) {
                NSLog(@"Request returned code not equal to 200 (%ld)",releaseResponse);
                [self messageWithTitle:@"Error" message:[NSString stringWithFormat:@"Consider removing the  \"%@\" source from yout list because it does not seem to respond.",object]];
            } else {
                [_sources addObject:[[[[[[NSString stringWithContentsOfURL:[NSURL URLWithString:[object stringByAppendingString:@"/Release"]] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"Origin: " withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
                [self downloadFileFromURLString:[object stringByAppendingString:@"/Packages.bz2"] saveFilename:[NSString stringWithFormat:@"Repos/%@.bz2",[_sources lastObject]]];
            }
        }
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:_sources];
        _sources = [[NSMutableArray alloc] initWithArray:[orderedSet array]];
        [[NSUserDefaults standardUserDefaults] setObject:_sources forKey:@"sourceNames"];
        [self stripSources];
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        [_sourcesTableView reloadData];
    });
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

- (void)stripSources {
    for(id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" error:nil]) {
        if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@_stripped",object]]) [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@_stripped",object] error:nil];
        if([object rangeOfString:@".bz2"].location != NSNotFound) {
            [[NSFileManager defaultManager] removeItemAtPath:[@"/var/mobile/Media/Icy/Repos/" stringByAppendingString:object] error:nil];
            continue;
        }
        if([object isEqualToString:@"updates"]) continue;
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
        rename([[NSString stringWithFormat:@"/var/mobile/Media/Icy/Repos/%@_stripped",object] UTF8String], [[@"/var/mobile/Media/Icy/Repos/" stringByAppendingString:object] UTF8String]);
    }
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
