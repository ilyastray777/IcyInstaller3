//
//  IcyPackageList.m
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/25/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import "IcyPackageList.h"

@implementation IcyPackageList

- (id)init {
    self.packageIDs = [[NSMutableArray alloc] init];
    self.packageIcons = [[NSMutableArray alloc] init];
    self.packageNames = [[NSMutableArray alloc] init];
    // This array is created on this class and than assigned to self.packageNames
    // You'll ask why?
    // The shit is, I simply can NOT addObject on packageNames after removing a package. This bug occurs ONLY in self.packageNames and not any other arrays.
    // I, however, can assign the value of self.packageNames to names. That's what I'm doing, and that's what surprisingly works :P
    NSMutableArray *names = [[NSMutableArray alloc] init];
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    NSString *icon = nil;
    NSString *lastID = nil;
    while(fgets(str, 999, file) != NULL) {
        if(strstr(str, "Package:")) lastID = [[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Package: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if(strstr(str, "Name:")) [names addObject:[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Name: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
        if(strstr(str, "Section:")) {
            icon = [NSString stringWithFormat:@"/Applications/IcyInstaller3.app/icons/%@.png",[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Section: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
            if([icon rangeOfString:@" "].location != NSNotFound) icon = [NSString stringWithFormat:@"%@.png",[icon substringToIndex:[icon rangeOfString:@" "].location]];
        }
        if(strstr(str, "Icon:")) icon = [[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Icon: file://" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if(![[NSFileManager defaultManager] fileExistsAtPath:icon]) icon = @"/Applications/IcyInstaller3.app/icons/Unknown.png";
        if(strlen(str) < 2 && names.count > 0) {
            NSString *lastObject = [names lastObject];
            [names sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            if(self.packageIDs.count < names.count) {
                [self.packageIDs insertObject:lastID atIndex:[names indexOfObject:lastObject]];
                [self.packageIcons insertObject:icon atIndex:[names indexOfObject:lastObject]];
            }
        }
    }
    self.packageNames = names;
    fclose(file);
    return self;
}

@end
