//
//  KMCGeigerCounter.m
//  FramerateDemo
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
@property (nonatomic, strong) KMCGeigerCounterScene *scene;

//@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) SystemSoundID tickSoundID;

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, assign) NSTimeInterval expectedFrameTimeRangeEnd;

- (void)processFrameWithTime:(NSTimeInterval)updateTime;

@end

@implementation KMCGeigerCounterScene

- (void)update:(NSTimeInterval)currentTime
{
    [self.geigerCounter processFrameWithTime:currentTime];
}

@end

#pragma mark -

@implementation KMCGeigerCounter

#pragma mark - Helpers

- (void)playTicks:(NSInteger)tickCount
{
    NSTimeInterval intervalBetweenTicks = kNormalFrameDuration / (tickCount - 1);

    // Play the first tick now.
    if (0 < tickCount) {
        AudioServicesPlaySystemSound(self.tickSoundID);
    }

    // Spread the rest of the ticks out over the duration of one frame.
    for (NSInteger tick = 1; tick < tickCount; tick++) {
        NSTimeInterval delay = intervalBetweenTicks * tick;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AudioServicesPlaySystemSound(self.tickSoundID);
        });
    }
}

- (void)processFrameWithTime:(NSTimeInterval)updateTime
//- (void)displayLinkWillDraw:(CADisplayLink *)displayLink
{
    if (!self.startTime) {
        self.startTime = [NSDate dateWithTimeIntervalSinceNow:-updateTime];
        self.expectedFrameTimeRangeEnd = updateTime + kNormalFrameDuration;
    }

    NSTimeInterval actualFrameTime = [[NSDate date] timeIntervalSinceDate:self.startTime];

    NSInteger tickCount = 0;
    while (self.expectedFrameTimeRangeEnd < actualFrameTime) {
        // The actual frame time was after the expected time. We dropped a frame. Play a tick.
        tickCount++;

        self.expectedFrameTimeRangeEnd += kNormalFrameDuration;
    }
    [self playTicks:tickCount];

    NSLog(@"%f\t%ld", updateTime, (long) tickCount);

    self.expectedFrameTimeRangeEnd += kNormalFrameDuration;
}

- (void)start
{
    NSURL *tickSoundURL = [[NSBundle mainBundle] URLForResource:@"KMCGeigerCounterTick" withExtension:@"aiff"];
    SystemSoundID tickSoundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) tickSoundURL, &tickSoundID);
    self.tickSoundID = tickSoundID;

//    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkWillDraw:)];
//    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

    self.scene = [KMCGeigerCounterScene new];
    self.scene.geigerCounter = self;
    self.view = [[SKView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 1.0)];
    [self.view presentScene:self.scene];

    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
}

- (void)stop
{
    [self.view removeFromSuperview];
    self.view = nil;
    self.scene = nil;

//    [self.displayLink invalidate];
//    self.displayLink = nil;
    self.startTime = nil;

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
