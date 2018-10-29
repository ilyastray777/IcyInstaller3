//
//  PackageInfoViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 10/16/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import "PackageInfoViewController.h"
#import "NSTask.h"
#import "ManageViewController.h"
#import "DepictionViewController.h"

@interface PackageInfoViewController ()

@end

@implementation PackageInfoViewController

@synthesize infoText;
@synthesize infoView;
@synthesize removeIndex;
BOOL infoPresent = NO;
UINavigationBar *packageInfoNavigationBar;

+ (BOOL)getInfoPresent {
    return infoPresent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // We'll need to allocate another IcyPackageList here
    _packageList = [[IcyPackageList alloc] init];
    // We'll also need an instance of IcyUniversalMethods here
    _icyUniversalMethods = [[IcyUniversalMethods alloc] init];
    // Navbar
    packageInfoNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,64)];
    UINavigationItem *titleNavigationItem = [[UINavigationItem alloc] initWithTitle:@"Info"];
    UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStylePlain target:self action:@selector(removePackageButtonAction)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissInfo)];
    titleNavigationItem.leftBarButtonItem = removeButton;
    titleNavigationItem.rightBarButtonItem = doneButton;
    [packageInfoNavigationBar setItems:@[titleNavigationItem]];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        packageInfoNavigationBar.tintColor = [UIColor orangeColor];
        packageInfoNavigationBar.barTintColor = [UIColor blackColor];
        packageInfoNavigationBar.barStyle = UIBarStyleBlack;
    }
    [self.view addSubview:packageInfoNavigationBar];
}

- (void)packageInfoWithIndexPath:(NSIndexPath *)indexPath {
    if(infoPresent) return;
    infoPresent = YES;
    removeIndex = (int)indexPath.row;
    UIView *infoTextView = [[UIView alloc] init];
    if (CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) infoTextView.frame = CGRectMake(15,10,[UIScreen mainScreen].bounds.size.height - 30,[UIScreen mainScreen].bounds.size.width - 234);
    else infoTextView.frame = CGRectMake(15,10,[UIScreen mainScreen].bounds.size.width - 30,[UIScreen mainScreen].bounds.size.height - 234);
    if([(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"]) infoTextView.frame = CGRectMake(15,10,[UIScreen mainScreen].bounds.size.width - 30,[UIScreen mainScreen].bounds.size.height - 370);
    infoTextView.layer.masksToBounds = YES;
    infoTextView.layer.cornerRadius = 10;
    infoView = [[UIView alloc] initWithFrame:CGRectMake(0,64,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 64)];
    if (CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) infoView.frame = CGRectMake(0,64,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 64);
    [infoView addSubview:infoTextView];
    [self.view addSubview:infoView];
    infoText = [[UITextView alloc] initWithFrame:infoTextView.bounds];
    infoText.editable = NO;
    infoText.scrollEnabled = YES;
    infoText.textColor = [UIColor whiteColor];
    infoText.backgroundColor = [UIColor clearColor];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) {
        infoTextView.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.1];
        infoView.backgroundColor = [UIColor blackColor];
    } else {
        infoTextView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
        infoView.backgroundColor = [UIColor whiteColor];
        infoText.textColor = [UIColor blackColor];
    }
    [infoText setFont:[UIFont boldSystemFontOfSize:15]];
    infoText.layer.masksToBounds = YES;
    infoText.layer.cornerRadius = 10;
    [infoTextView addSubview:infoText];
    UIButton *more = [[UIButton alloc] initWithFrame:CGRectMake(15,infoView.bounds.size.height - 50,[UIScreen mainScreen].bounds.size.width - 30,40)];
    if(CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) more.frame = CGRectMake([UIScreen mainScreen].bounds.size.height / 3 + 10,infoView.bounds.size.height - 340,[UIScreen mainScreen].bounds.size.height / 3 - 20,30);
    if([(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] && CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) more.frame = CGRectMake(15,infoView.bounds.size.height - 150,[UIScreen mainScreen].bounds.size.width - 30,40);
    more.backgroundColor = [UIColor colorWithRed:1.00 green:0.58 blue:0.00 alpha:1.0];
    [more setTitle:@"More info" forState:UIControlStateNormal];
    [more setTitle:@"More info unavailable" forState:UIControlStateDisabled];
    more.layer.masksToBounds = YES;
    more.layer.cornerRadius = 10;
    [more.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [more setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [more setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    more.enabled = NO;
    [more addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:more];
    UIButton *expand = [[UIButton alloc] initWithFrame:CGRectMake(15,infoView.bounds.size.height - 100,[UIScreen mainScreen].bounds.size.width - 30,40)];
    expand.backgroundColor = [UIColor colorWithRed:1.00 green:0.58 blue:0.00 alpha:1.0];
    [expand setTitle:@"Expand" forState:UIControlStateNormal];
    expand.layer.masksToBounds = YES;
    expand.layer.cornerRadius = 10;
    [expand.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [expand setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [expand addTarget:self action:@selector(expand) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:expand];
    UIButton *files = [[UIButton alloc] initWithFrame:CGRectMake(15,infoView.bounds.size.height - 150,[UIScreen mainScreen].bounds.size.width - 30,40)];
    files.backgroundColor = [UIColor colorWithRed:1.00 green:0.58 blue:0.00 alpha:1.0];
    [files setTitle:@"Files" forState:UIControlStateNormal];
    files.layer.masksToBounds = YES;
    files.layer.cornerRadius = 10;
    [files.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [files setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [files addTarget:self action:@selector(files) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:files];
    NSString *info = [self infoAboutPackage:[NSString stringWithFormat:@"Package: %@\n",[_packageList.packageIDs objectAtIndex:indexPath.row]] full:NO];
    if([info rangeOfString:@"hasdepiction"].location != NSNotFound) more.enabled = YES;
    info = [info stringByReplacingOccurrencesOfString:@"hasdepiction" withString:@""];
    infoText.text = info;
    [self.view bringSubviewToFront:packageInfoNavigationBar];
}

- (void)moreInfo {
    if(![IcyUniversalMethods isNetworkAvailable]) {
        [IcyUniversalMethods messageWithTitle:@"Error" message:@"This action requires an internet connection. If you are connected to the internet, but the problem still occurs, try relaunching Icy."];
        return;
    }
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    char search[999];
    snprintf(search, sizeof(search), "Package: %s", [[_packageList.packageIDs objectAtIndex:removeIndex] UTF8String]);
    BOOL shouldReturn = NO;
    while (fgets(str, 999, file) != NULL) {
        if(strstr(str, search)) shouldReturn = YES;
        if(strstr(str, "Depiction:") && shouldReturn) break;
    }
    fclose(file);
    DepictionViewController *depictionViewController = [[DepictionViewController alloc] initWithURLString:[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] substringFromIndex:11] stringByReplacingOccurrencesOfString:@"\n" withString:@""] removeBundleID:nil downloadURLString:nil buttonType:0];
    [self presentViewController:depictionViewController animated:YES completion:nil];
}

- (void)expand {
    infoText.text = [self infoAboutPackage:[NSString stringWithFormat:@"Package: %@\n",[_packageList.packageIDs objectAtIndex:removeIndex]] full:YES];
}

- (NSString *)infoAboutPackage:(NSString *)package full:(BOOL)full {
    NSString *info = @"";
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    BOOL shouldWrite = NO;
    const char *search = [package UTF8String];
    while(fgets(str, 999, file) != NULL) {
        if(strcmp(str, search) == 0) shouldWrite = YES;
        if(strlen(str) < 2 && shouldWrite) break;
        if(shouldWrite && !strstr(str, "Priority:") && !strstr(str, "Status:") && !strstr(str, "Installed-Size:") && !strstr(str, "Maintainer:") && !strstr(str, "Architecture:") && !strstr(str, "Replaces:") && !strstr(str, "Provides:") && !strstr(str, "Homepage:") && !strstr(str, "Depiction:") && !strstr(str, "Depiction:") && !strstr(str, "Sponsor:") && !strstr(str, "dev:") && !strstr(str, "Tag:") && !strstr(str, "Icon:") && !strstr(str, "Website:") && !strstr(str, "Conflicts:") && !strstr(str, "Depends:")) info = [NSString stringWithFormat:@"%@%@",info,[NSString stringWithCString:str encoding:NSASCIIStringEncoding]];
        else if(full && shouldWrite) info = [NSString stringWithFormat:@"%@%@",info,[NSString stringWithCString:str encoding:NSASCIIStringEncoding]];
        if(shouldWrite && !full && strstr(str, "Depiction:")) info = [info stringByAppendingString:@"hasdepiction"];
    }
    fclose(file);
    return info;
}

- (void)files {
    infoText.text = [NSString stringWithContentsOfFile:[[[NSString stringWithFormat:@"/var/lib/dpkg/info/%@.list",[_packageList.packageIDs objectAtIndex:removeIndex]] stringByReplacingOccurrencesOfString:@"Package: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] encoding:NSUTF8StringEncoding error:nil];
}

- (void)dismissInfo {
    infoPresent = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)removePackageButtonAction {
    [self removePackageWithBundleID:[_packageList.packageIDs objectAtIndex:removeIndex]];
}

NSMutableArray *dependencies;
UIAlertView *dependencyAlert;
- (void)removePackageWithBundleID:(NSString *)bundleID {
    NSString *output = nil;
    if(SYSTEM_VERSION_LESS_THAN(@"11.0")) output = [self runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze"] withArguments:@[@"-r", bundleID] errors:YES];
    else [self runCommandWithOutput:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/freeze11"] withArguments:@[@"-r", bundleID] errors:YES];
    // If the command had dependency errors we do some extra stuff to remove dependencies too
    if([output rangeOfString:@"dpkg: dependency problems prevent removal"].location != NSNotFound) {
        output = [output stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"dpkg: dependency problems prevent removal of %@:\n",bundleID] withString:@""];
        dependencies = [[NSMutableArray alloc] init];
        NSMutableArray *dependencyNames = [[NSMutableArray alloc] init];
        for (id object in [output componentsSeparatedByString:@"\n"]) if([object rangeOfString:@"depends"].location != NSNotFound) [dependencies addObject:[[object substringToIndex:[[object substringFromIndex:1] rangeOfString:@" "].location + 1] stringByReplacingOccurrencesOfString:@" " withString:@""]];
        dependencies = [[[NSOrderedSet orderedSetWithArray:dependencies] array] mutableCopy];
        for (id object in dependencies) [dependencyNames addObject:[self packageNameForBundleID:object]];
        NSString *message = @"The following packages depend on the package you're trying to remove:\n";
        for(id object in dependencyNames) message = [message stringByAppendingString:[NSString stringWithFormat:@"- %@\n",object]];
        // Also add the actual pkg to the dependencies array so it gets removed, too
        [dependencies addObject:bundleID];
        message = [message stringByAppendingString:@"Would you also like to remove those packages?"];
        dependencyAlert = [[UIAlertView alloc] initWithTitle:@"Dependency warning" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", nil];
        [dependencyAlert show];
    }
    ManageViewController *manageViewController = [[ManageViewController alloc] init];
    [manageViewController refreshList];
    [_icyUniversalMethods reload];
}

- (NSString *)runCommandWithOutput:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:command];
    [task setCurrentDirectoryPath:@"/"];
    [task setArguments:args];
    NSPipe *out = [NSPipe pipe];
    NSPipe *err = [NSPipe pipe];
    [task setStandardOutput:out];
    [task setStandardError:err];
    [task launch];
    [task waitUntilExit];
    if(errors) return [[NSString alloc] initWithData:[[err fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    else return [[NSString alloc] initWithData:[[out fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(alertView == dependencyAlert && buttonIndex != [alertView cancelButtonIndex]) for(id object in dependencies) [self removePackageWithBundleID:object];
}

- (NSString *)packageNameForBundleID:(NSString *)bundleID {
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    char search[999];
    snprintf(search, sizeof(search), "Package: %s", [bundleID UTF8String]);
    BOOL shouldReturn = NO;
    while (fgets(str, 999, file) != NULL) {
        if(strstr(str, search)) shouldReturn = YES;
        if(strstr(str, "Name:") && shouldReturn) break;
    }
    fclose(file);
    return [[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] substringFromIndex:6] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

@end
