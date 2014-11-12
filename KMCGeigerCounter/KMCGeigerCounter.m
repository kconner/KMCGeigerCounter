//
//  KMCGeigerCounter.m
//  KMCGeigerCounter
//
//  Created by Kevin Conner on 10/21/14.
//  Copyright (c) 2014 Kevin Conner. All rights reserved.
//

#import "KMCGeigerCounter.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <SpriteKit/SpriteKit.h>

static NSInteger const kHardwareFramesPerSecond = 60;
static NSTimeInterval const kNormalFrameDuration = 1.0 / kHardwareFramesPerSecond;

@interface KMCGeigerCounter () {
    CFTimeInterval _lastSecondOfFrameTimes[kHardwareFramesPerSecond];
}

@property (nonatomic, readwrite, getter = isRunning) BOOL running;

@property (nonatomic, strong) SKView *view;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) SystemSoundID tickSoundID;

@property (nonatomic, assign) NSInteger frameNumber;

@end

@implementation KMCGeigerCounter

#pragma mark - Helpers

- (CFTimeInterval)lastFrameTime
{
    return _lastSecondOfFrameTimes[self.frameNumber % kHardwareFramesPerSecond];
}

- (void)recordFrameTime:(CFTimeInterval)frameTime
{
    ++self.frameNumber;
    _lastSecondOfFrameTimes[self.frameNumber % kHardwareFramesPerSecond] = frameTime;
}

- (void)clearLastSecondOfFrameTimes
{
    CFTimeInterval initialFrameTime = CACurrentMediaTime();
    for (NSInteger i = 0; i < kHardwareFramesPerSecond; ++i) {
        _lastSecondOfFrameTimes[i] = initialFrameTime;
    }
    self.frameNumber = 0;
}

- (void)displayLinkWillDraw:(CADisplayLink *)displayLink
{
    CFTimeInterval currentFrameTime = displayLink.timestamp;
    CFTimeInterval frameDuration = currentFrameTime - [self lastFrameTime];

    // Frames should be even multiples of kNormalFrameDuration.
    // If a frame takes two frame durations, we dropped at least one, so click.
    if (1.5 < frameDuration / kNormalFrameDuration) {
        AudioServicesPlaySystemSound(self.tickSoundID);
    }

    [self recordFrameTime:currentFrameTime];
}

#pragma mark -

- (void)start
{
    NSURL *tickSoundURL = [[NSBundle mainBundle] URLForResource:@"KMCGeigerCounterTick" withExtension:@"aiff"];
    SystemSoundID tickSoundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) tickSoundURL, &tickSoundID);
    self.tickSoundID = tickSoundID;

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkWillDraw:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self clearLastSecondOfFrameTimes];

    // Low framerates can be caused by CPU activity on the main thread or by long compositing time in (I suppose)
    // the graphics driver. If compositing time is the problem, and it doesn't require on any main thread activity
    // between frames, then the framerate can drop without CADisplayLink detecting it.
    // Therefore, put an empty 1pt x 1pt SKView in the window. It shouldn't interfere with the framerate, but
    // should cause the CADisplayLink callbacks to match the timing of drawing.
    SKScene *scene = [SKScene new];
    self.view = [[SKView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 1.0)];
    [self.view presentScene:scene];

    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
}

- (void)stop
{
    [self.view removeFromSuperview];
    self.view = nil;

    [self.displayLink invalidate];
    self.displayLink = nil;

    AudioServicesDisposeSystemSoundID(self.tickSoundID);
    self.tickSoundID = 0;
}

- (void)setRunning:(BOOL)running
{
    if (_running != running) {
        if (running) {
            [self start];
        } else {
            [self stop];
        }

        _running = running;
    }
}

#pragma mark -

- (void)applicationDidBecomeActive
{
    self.running = self.enabled;
}

- (void)applicationWillResignActive
{
    self.running = NO;
}

#pragma mark -

- (void)enable
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        self.running = YES;
    }
}

- (void)disable
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.running = NO;
}

#pragma mark - Init/dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public interface

+ (instancetype)sharedGeigerCounter
{
    static KMCGeigerCounter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [KMCGeigerCounter new];
    });
    return instance;
}

- (void)setEnabled:(BOOL)enabled
{
    if (_enabled != enabled) {
        if (enabled) {
            [self enable];
        } else {
            [self disable];
        }

        _enabled = enabled;
    }
}

- (NSInteger)droppedFrameCountInLastSecond
{
    NSInteger droppedFrameCount = 0;

    CFTimeInterval lastFrameTime = CACurrentMediaTime() - kNormalFrameDuration;
    for (NSInteger i = 0; i < kHardwareFramesPerSecond; ++i) {
        if (1.0 <= lastFrameTime - _lastSecondOfFrameTimes[i]) {
            ++droppedFrameCount;
        }
    }

    return droppedFrameCount;
}

- (NSInteger)drawnFrameCountInLastSecond
{
    if (!self.running || self.frameNumber < kHardwareFramesPerSecond) {
        return -1;
    }

    return kHardwareFramesPerSecond - self.droppedFrameCountInLastSecond;
}

@end
