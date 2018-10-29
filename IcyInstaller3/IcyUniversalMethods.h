//
//  IcyUniversalMethods.h
//  IcyInstaller3
//
//  Created by ArtikusHG on 10/23/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IcyUniversalMethods : NSObject

@property (strong, nonatomic) NSString *deviceModel;
@property (nonatomic) NSUInteger oldApplications;
@property (nonatomic) NSUInteger oldTweaks;

+ (void)messageWithTitle:(NSString *)title message:(NSString *)message;
+ (BOOL)isNetworkAvailable;
- (void)reload;
+ (NSString *)runCommandWithOutput:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors;

@end
