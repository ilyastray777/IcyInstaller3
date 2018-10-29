//
//  IcyPackageList.h
//  IcyInstaller3
//
//  Created by ArtikusHG on 7/25/18.
//  Copyright © 2018 ArtikusHG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IcyPackageList : NSObject

// Variables

@property (strong, nonatomic) NSMutableArray *packageIDs;
@property (strong, nonatomic) NSMutableArray *packageNames;
@property (strong, nonatomic) NSMutableArray *packageIcons;
@property (strong, nonatomic) NSMutableArray *packageDescs;

// Methods

- (void)load;

@end
