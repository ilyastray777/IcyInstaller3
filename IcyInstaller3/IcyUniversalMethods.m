//
//  IcyUniversalMethods.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 10/23/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

@import UIKit;
#import "IcyUniversalMethods.h"
#import <sys/utsname.h>
#import <spawn.h>
#import <signal.h>
#import <netdb.h>
#import "NSTask.h"
#import "IcyDPKGViewController.h"

@implementation IcyUniversalMethods

- (id)init {
    self = [super init];
    // Get device model and UDID
    struct utsname systemInfo;
    uname(&systemInfo);
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"udid"] == nil) [[NSUserDefaults standardUserDefaults] setObject:[self uniqueDeviceID] forKey:@"udid"];
    self.deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    // Get arrays needed for reload
    _oldApplications = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Applications/" error:nil].count;
    _oldTweaks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/MobileSubstrate/DynamicLibraries/" error:nil].count;
    return self;
}

+ (BOOL)hasTopNotch {
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        if (@available(iOS 8.0, *)) {
            switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
                case 2436:
                    // iPhone X and Xs
                    return YES;
                case 2688:
                    // iPhone Xs Max
                    return YES;
                case 1792:
                    // iPhone Xr
                    return YES;
                default:
                    // unknown device, in case an apple employe decides to test icy on a prototype lol
                    return NO;
            }
        } else {
            return NO;
        }
    }
    return NO;
}

- (void)respring {
    [IcyDPKGViewController respring];
}

- (void)uicache {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reloading caches..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    alert.delegate = self;
    [alert show];
    // Run uicache
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        pid_t pid;
        int status;
        const char *argv[] = {"uicache", NULL};
        posix_spawn(&pid, "/usr/bin/uicache", NULL, NULL, (char* const*)argv, NULL);
        waitpid(pid, &status, 0);
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
}

- (void)reload {
    NSArray *newApplications = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Applications/" error:nil];
    NSArray *newTweaks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/MobileSubstrate/DynamicLibraries/" error:nil];
    if(newApplications.count != _oldApplications) {
        _oldApplications = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Applications/" error:nil].count;
        [self uicache];
    }
    if(newTweaks.count != _oldTweaks) {
        _oldTweaks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Library/MobileSubstrate/DynamicLibraries/" error:nil].count;
        [self respring];
    }
}

+ (void)messageWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
}

+ (BOOL)isNetworkAvailable {
    char *hostname;
    struct hostent *hostinfo;
    hostname = "google.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL) return NO;
    else return YES;
}

OBJC_EXTERN CFStringRef MGCopyAnswer(CFStringRef key) WEAK_IMPORT_ATTRIBUTE;
- (NSString *)uniqueDeviceID {
    CFStringRef udid = MGCopyAnswer(CFSTR("UniqueDeviceID"));
    return (NSString *)CFBridgingRelease(udid);
}

+ (NSString *)runCommandWithOutput:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:command];
    [task setCurrentDirectoryPath:@"/"];
    [task setArguments:args];
    NSPipe *out = [NSPipe pipe];
    [task setStandardOutput:out];
    if(errors) [task setStandardError:out];
    [task launch];
    [task waitUntilExit];
    return [[NSMutableString alloc] initWithData:[[out fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
}

@end
