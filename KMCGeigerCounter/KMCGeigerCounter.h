//
//  KMCGeigerCounter.h
//  KMCGeigerCounter
//
//  Created by Kevin Conner on 10/21/14.
//  Copyright (c) 2014 Kevin Conner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMCGeigerCounter : NSObject

@property (nonatomic, assign, getter = isRunning) BOOL running;

+ (instancetype)sharedGeigerCounter;

@end
