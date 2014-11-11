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
@property (nonatomic, readonly) NSInteger droppedFrameCountInLastSecond;
@property (nonatomic, readonly) NSInteger drawnFrameCountInLastSecond; // -1 until one second of frames have been collected

+ (instancetype)sharedGeigerCounter;

@end
