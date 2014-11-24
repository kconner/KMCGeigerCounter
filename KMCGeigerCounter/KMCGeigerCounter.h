//
//  KMCGeigerCounter.h
//  KMCGeigerCounter
//
//  Created by Kevin Conner on 10/21/14.
//  Copyright (c) 2014 Kevin Conner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMCGeigerCounter : NSObject

// Set [KMCGeigerCounter sharedGeigerCounter].enabled = YES from -application:didFinishLaunchingWithOptions:
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

// Set [KMCGeigerCounter sharedGeigerCounter].soundActive = NO from -application:didFinishLaunchingWithOptions: to disable sound
@property (nonatomic, assign, getter = isSoundActive) BOOL soundActive;

// Draws over the status bar. Set it manually if your own custom windows obscure it.
@property (nonatomic, assign) UIWindowLevel windowLevel;

@property (nonatomic, readonly, getter = isRunning) BOOL running;
@property (nonatomic, readonly) NSInteger droppedFrameCountInLastSecond;
@property (nonatomic, readonly) NSInteger drawnFrameCountInLastSecond; // -1 until one second of frames have been collected

+ (instancetype)sharedGeigerCounter;

@end
