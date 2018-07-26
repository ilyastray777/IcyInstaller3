//
//  SourcesViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/20/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import "SourcesViewController.h"

@interface SourcesViewController ()
@end

@implementation SourcesViewController

BOOL darkMode = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Get device model
    struct utsname systemInfo;
    uname(&systemInfo);
    _deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    // Get value of darkMode
    darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"];
    // The tableview
    _sourcesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100) style:UITableViewStylePlain];
    _sourcesTableView.delegate = self;
    _sourcesTableView.dataSource = self;
    _sourcesTableView.backgroundColor = [UIColor whiteColor];
    [_sourcesTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _sourcesTableView.contentInset = UIEdgeInsetsMake(0,0,60,0);
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
        if(darkMode) {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
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

UIAlertView *manageAlert;
- (void)manage {
    manageAlert = [[UIAlertView alloc] initWithTitle:@"Manage" message:nil delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Reload sources", @"Scan updates", @"Add source", nil];
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
    for(id object in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/Icy/Repos" error:nil]) [[NSFileManager defaultManager] removeItemAtPath:[@"/var/mobile/Media/Icy/Repos/" stringByAppendingString:object] error:&err];
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

- (long)statusCodeOfFileAtURL:(NSString *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    if([url rangeOfString:@"yourepo"].location != NSNotFound) {
        [mutableRequest setValue:@"Telesphoreo APT-HTTP/1.0.592" forHTTPHeaderField:@"User-Agent"];
        [mutableRequest setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"X-Firmware"];
        [mutableRequest setValue:_deviceModel forHTTPHeaderField:@"X-Machine"];
        [mutableRequest setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"] forHTTPHeaderField:@"X-Unique-ID"];
    }
    [NSURLConnection sendSynchronousRequest:mutableRequest returningResponse:&response error:&error];
    if(error) NSLog(@"Status code: %ld\nError: %@",(long)response.statusCode,[error localizedDescription]);
    return (long)response.statusCode;
}

- (void)downloadFileFromURLString:(NSString *)urlString saveFilename:(NSString *)filename {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    if([urlString rangeOfString:@"yourepo"].location != NSNotFound) config.HTTPAdditionalHeaders = @{@"User-Agent": @"Telesphoreo APT-HTTP/1.0.592", @"X-Firmware": [[UIDevice currentDevice] systemVersion], @"X-Machine": _deviceModel, @"X-Unique-ID":[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"]};
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
    [alert release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
