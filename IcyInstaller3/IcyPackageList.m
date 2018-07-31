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
    FILE *file = fopen("/var/lib/dpkg/status", "r");
    char str[999];
    NSString *icon = nil;
    NSString *lastID = nil;
    while(fgets(str, 999, file) != NULL) {
        if(strstr(str, "Package:"))  [self.packageIDs addObject:[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Package: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
        if(strstr(str, "Name:")) [self.packageNames addObject:[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Name: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
        if(strstr(str, "Section:")) {
            icon = [NSString stringWithFormat:@"/Applications/IcyInstaller3.app/icons/%@.png",[[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Section: " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
            if([icon rangeOfString:@" "].location != NSNotFound) icon = [NSString stringWithFormat:@"%@.png",[icon substringToIndex:[icon rangeOfString:@" "].location]];
        }
        if(strstr(str, "Icon:")) icon = [[[NSString stringWithCString:str encoding:NSASCIIStringEncoding] stringByReplacingOccurrencesOfString:@"Icon: file://" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if(![[NSFileManager defaultManager] fileExistsAtPath:icon]) icon = @"/Applications/IcyInstaller3.app/icons/Unknown.png";
        if(strlen(str) < 2) {
            if(self.packageIDs.count > self.packageNames.count) [self.packageIDs removeLastObject];
            lastID = [self.packageIDs lastObject];
            NSString *lastObject = [self.packageNames lastObject];
            [self.packageNames sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [self.packageIDs removeLastObject];
            [self.packageIDs insertObject:lastID atIndex:[self.packageNames indexOfObject:lastObject]];
            [self.packageIcons insertObject:icon atIndex:[self.packageNames indexOfObject:lastObject]];
        }
    }
    fclose(file);
    return self;
}

@end
