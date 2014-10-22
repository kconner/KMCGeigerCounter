//
//  KMCGeigerCounter.m
//  KMCGeigerCounter
//
//  Created by Kevin Conner on 10/21/14.
//  Copyright (c) 2014 Two Toasters. All rights reserved.
//

#import "KMCGeigerCounter.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <SpriteKit/SpriteKit.h>

static NSTimeInterval const kNormalFrameDuration = 1.0 / 60.0;

@interface KMCGeigerCounterScene : SKScene

@property (nonatomic, weak) KMCGeigerCounter *geigerCounter;

@end

@interface KMCGeigerCounter ()

@property (nonatomic, strong) SKView *view;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) SystemSoundID tickSoundID;

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, assign) NSTimeInterval expectedFrameTimeRangeEnd;
@property (nonatomic, strong) NSDate *lastFrameTime;

@end

#pragma mark -

@implementation KMCGeigerCounterScene

- (void)update:(NSTimeInterval)currentTime
{
    self.geigerCounter.lastFrameTime = [NSDate date];
}

@end

@implementation KMCGeigerCounter

#pragma mark - Helpers

- (void)displayLinkWillDraw:(CADisplayLink *)displayLink
{
    if (!self.startTime) {
        self.startTime = [NSDate date];
        self.expectedFrameTimeRangeEnd = kNormalFrameDuration;
    }

    if (self.lastFrameTime) {
        NSTimeInterval actualFrameTime = [self.lastFrameTime timeIntervalSinceDate:self.startTime];
        
        NSInteger droppedFrameCount = 0;
        while (self.expectedFrameTimeRangeEnd < actualFrameTime) {
            // The actual frame time was after the expected time. We dropped a frame.
            droppedFrameCount++;
            
            self.expectedFrameTimeRangeEnd += kNormalFrameDuration;
        }

        if (0 < droppedFrameCount) {
            AudioServicesPlaySystemSound(self.tickSoundID);
        }
    }

    self.expectedFrameTimeRangeEnd += kNormalFrameDuration;
    self.lastFrameTime = nil;
}

- (void)start
{
    NSURL *tickSoundURL = [[NSBundle mainBundle] URLForResource:@"KMCGeigerCounterTick" withExtension:@"aiff"];
    SystemSoundID tickSoundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) tickSoundURL, &tickSoundID);
    self.tickSoundID = tickSoundID;

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkWillDraw:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

    KMCGeigerCounterScene *scene = [KMCGeigerCounterScene new];
    scene.geigerCounter = self;
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

    self.startTime = nil;
    self.lastFrameTime = nil;

    AudioServicesDisposeSystemSoundID(self.tickSoundID);
    self.tickSoundID = 0;
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

- (void)setRunning:(BOOL)running
{
    if (_running != running) {
        if (running) {
            [self start];
        }

        if (!running) {
            [self stop];
        }

        _running = running;
    }
}

@end
