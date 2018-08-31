//
//  ManageViewController.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/23/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import "ManageViewController.h"
#import "NSTask.h"

@interface ManageViewController ()

@end

@implementation ManageViewController
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

ViewController *_viewController;
UITableView *_manageTableView;
IcyPackageList *_packageList;
UIWebView *_packageWebView;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize view controller and package list
    _packageList = [[IcyPackageList alloc] init];
    _viewController = [[ViewController alloc] init];
    // The package webview
    _packageWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 210)];
    [self.view addSubview:_packageWebView];
    _packageWebView.hidden = YES;
    // Table view
    _manageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100) style:UITableViewStylePlain];
    _manageTableView.delegate = self;
    _manageTableView.dataSource = self;
    _manageTableView.backgroundColor = [UIColor clearColor];
    [_manageTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _manageTableView.contentInset = UIEdgeInsetsMake(0,0,60,0);
    if([(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        if(CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) _manageTableView.contentInset = UIEdgeInsetsMake(0,-160,60,0);
        else _manageTableView.contentInset = UIEdgeInsetsMake(0,-30,60,0);
    }
    [self.view addSubview:_manageTableView];
    [self.view bringSubviewToFront:_manageTableView];
    [_manageTableView reloadData];
}


+ (UITableView *)getManageTableView {
    return _manageTableView;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return _packageList.packageNames.count;
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
    cell.textLabel.text = [_packageList.packageNames objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [_packageList.packageIDs objectAtIndex:indexPath.row];
    UIImage *icon = [UIImage imageWithContentsOfFile:[_packageList.packageIcons objectAtIndex:indexPath.row]];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40,40), NO, [UIScreen mainScreen].scale);
    [icon drawInRect:CGRectMake(0,0,40,40)];
    icon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 10;
    cell.imageView.image = icon;
    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!infoView.isHidden) [self packageInfoWithIndexPath:indexPath];
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

UIView *infoView;
UITextView *infoText;
int removeIndex;
BOOL infoPresent = NO;
- (void)packageInfoWithIndexPath:(NSIndexPath *)indexPath {
    if(infoPresent) return;
    infoPresent = YES;
    removeIndex = (int)indexPath.row;
    _viewController.nameLabel.text = [_manageTableView cellForRowAtIndexPath:indexPath].textLabel.text;
    UIView *infoTextView = [[UIView alloc] init];
    if (CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) infoTextView.frame = CGRectMake(15,10,[UIScreen mainScreen].bounds.size.height - 30,[UIScreen mainScreen].bounds.size.width / 2 - 50 + 1);
    else infoTextView.frame = CGRectMake(15,10,[UIScreen mainScreen].bounds.size.width - 30,[UIScreen mainScreen].bounds.size.height / 2 - 50 + 1);
    if([(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"]) infoTextView.frame = CGRectMake(15,10,[UIScreen mainScreen].bounds.size.width - 30,[UIScreen mainScreen].bounds.size.height - 320);
    [_viewController makeViewRound:infoTextView withRadius:10];
    infoView = [[UIView alloc] initWithFrame:CGRectMake(0,-[UIScreen mainScreen].bounds.size.height - 100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100)];
    if (CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) infoView.frame = CGRectMake(0,-[UIScreen mainScreen].bounds.size.width - 100,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.height - 100);
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
    [_viewController makeViewRound:infoText withRadius:10];
    [infoTextView addSubview:infoText];
    UIButton *remove = [[UIButton alloc] initWithFrame:CGRectMake(20,infoView.bounds.size.height - 200,[UIScreen mainScreen].bounds.size.width - 40,40)];
    if(CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) remove.frame = CGRectMake(20,infoView.bounds.size.height - 340,[UIScreen mainScreen].bounds.size.height / 3 - 20,30);
    if([(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] && CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) remove.frame = CGRectMake(20,infoView.bounds.size.height - 200,[UIScreen mainScreen].bounds.size.width - 40,40);
    remove.backgroundColor = [UIColor colorWithRed:1.00 green:0.58 blue:0.00 alpha:1.0];
    [remove setTitle:@"Remove" forState:UIControlStateNormal];
    [_viewController makeViewRound:remove withRadius:5];
    [remove.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [remove setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [remove addTarget:self action:@selector(removePackageButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:remove];
    UIButton *more = [[UIButton alloc] initWithFrame:CGRectMake(20,infoView.bounds.size.height - 150,[UIScreen mainScreen].bounds.size.width - 40,40)];
    if(CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) more.frame = CGRectMake([UIScreen mainScreen].bounds.size.height / 3 + 10,infoView.bounds.size.height - 340,[UIScreen mainScreen].bounds.size.height / 3 - 20,30);
    if([(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] && CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) more.frame = CGRectMake(20,infoView.bounds.size.height - 150,[UIScreen mainScreen].bounds.size.width - 40,40);
    more.backgroundColor = [UIColor colorWithRed:1.00 green:0.58 blue:0.00 alpha:1.0];
    [more setTitle:@"More info" forState:UIControlStateNormal];
    [more setTitle:@"More info unavailable" forState:UIControlStateDisabled];
    [_viewController makeViewRound:more withRadius:5];
    [more.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [more setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [more setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    more.enabled = NO;
    [more addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:more];
    UIButton *dismiss = [[UIButton alloc] initWithFrame:CGRectMake(20,infoView.bounds.size.height - 100,[UIScreen mainScreen].bounds.size.width - 40,40)];
    if(CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) dismiss.frame = CGRectMake([UIScreen mainScreen].bounds.size.height / 1.5,infoView.bounds.size.height - 340,[UIScreen mainScreen].bounds.size.height / 3 - 20,30);
    if([(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] && CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) dismiss.frame = CGRectMake(20,infoView.bounds.size.height - 100,[UIScreen mainScreen].bounds.size.width - 40,40);
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"]) dismiss.backgroundColor = [UIColor colorWithRed:1.00 green:0.58 blue:0.00 alpha:1.0];
    else dismiss.backgroundColor = [UIColor colorWithRed:0.00 green:0.48 blue:1.00 alpha:1.0];
    [dismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
    [_viewController makeViewRound:dismiss withRadius:5];
    [dismiss.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [dismiss setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [dismiss addTarget:[self class] action:@selector(dismissInfo) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:dismiss];
    NSString *info = [self infoAboutPackage:[NSString stringWithFormat:@"Package: %@\n",[_packageList.packageIDs objectAtIndex:indexPath.row]] full:NO];
    if([info rangeOfString:@"hasdepiction"].location != NSNotFound) more.enabled = YES;
    info = [info stringByReplacingOccurrencesOfString:@"hasdepiction" withString:@""];
    infoText.text = info;
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) infoView.frame = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 100);
        else infoView.frame = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 100);

    } completion:nil];
}

- (void)moreInfo {
    if(![_viewController isNetworkAvailable]) {
        [_viewController messageWithTitle:@"Error" message:@"This action requires an internet connection. If you are connected to the internet, but the problem still occurs, try relaunching Icy."];
        return;
    }
    if(CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) _packageWebView.frame = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width - 200);
    if([(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] && CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) _packageWebView.frame = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 200);
    else _packageWebView.frame = CGRectMake(0,100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 210);
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
    [_packageWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] substringFromIndex:11] stringByReplacingOccurrencesOfString:@"\n" withString:@""]]]];
    _packageWebView.hidden = NO;
    [self.view bringSubviewToFront:_packageWebView];
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

+ (void)dismissInfo {
    _packageWebView.hidden = YES;
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        infoView.frame  = CGRectMake(0,-[UIScreen mainScreen].bounds.size.height - 100,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - 161);
    } completion:nil];
    infoPresent = NO;
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
        message = [message stringByAppendingString:@"Would you also like to remove those packages?"];
        dependencyAlert = [[UIAlertView alloc] initWithTitle:@"Dependency warning" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", nil];
        [dependencyAlert show];
    }
    [_viewController reload];
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
    [task release];
    if(errors) return [[[NSString alloc] initWithData:[[err fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding] autorelease];
    else return [[[NSString alloc] initWithData:[[out fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding] autorelease];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
