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

// I'd prefer "static NSInteger const kHardwareFramesPerSecond = 60;", but
// that doesn't work for all options of the "C Language Dialect" build setting.
// https://github.com/kconner/KMCGeigerCounter/issues/3
#define kHardwareFramesPerSecond 60

static NSTimeInterval const kNormalFrameDuration = 1.0 / kHardwareFramesPerSecond;

@interface KMCGeigerCounter () {
    CFTimeInterval _recentFrameTimes[kHardwareFramesPerSecond];
}

@property (nonatomic, readwrite, getter = isRunning) BOOL running;

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UILabel *meterLabel;
@property (nonatomic, strong) UIColor *meterPerfectColor;
@property (nonatomic, strong) UIColor *meterGoodColor;
@property (nonatomic, strong) UIColor *meterBadColor;

@property (nonatomic, strong) SKView *sceneView;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) SystemSoundID tickSoundID;

@property (nonatomic, assign) NSInteger frameNumber;

@end

@implementation KMCGeigerCounter

#pragma mark - Helpers

+ (UIColor *)colorWithHex:(uint32_t)hex alpha:(CGFloat)alpha
{
    CGFloat red   = (CGFloat) ((hex & 0xff0000) >> 16) / 255.0f;
    CGFloat green = (CGFloat) ((hex & 0x00ff00) >> 8)  / 255.0f;
    CGFloat blue  = (CGFloat)  (hex & 0x0000ff)        / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (CFTimeInterval)lastFrameTime
{
    return _recentFrameTimes[self.frameNumber % kHardwareFramesPerSecond];
}

- (void)recordFrameTime:(CFTimeInterval)frameTime
{
    ++self.frameNumber;
    _recentFrameTimes[self.frameNumber % kHardwareFramesPerSecond] = frameTime;
}

- (void)clearLastSecondOfFrameTimes
{
    CFTimeInterval initialFrameTime = CACurrentMediaTime();
    for (NSInteger i = 0; i < kHardwareFramesPerSecond; ++i) {
        _recentFrameTimes[i] = initialFrameTime;
    }
    self.frameNumber = 0;
}

- (void)updateMeterLabel
{
    NSInteger droppedFrameCount = self.droppedFrameCountInLastSecond;
    NSInteger drawnFrameCount = self.drawnFrameCountInLastSecond;

    NSString *droppedString;
    NSString *drawnString;

    if (droppedFrameCount <= 0) {
        self.meterLabel.backgroundColor = self.meterPerfectColor;

        droppedString = @"--";
    } else {
        if (droppedFrameCount <= 2) {
            self.meterLabel.backgroundColor = self.meterGoodColor;
        } else {
            self.meterLabel.backgroundColor = self.meterBadColor;
        }

        droppedString = [NSString stringWithFormat:@"%ld", (long) droppedFrameCount];
    }

    if (drawnFrameCount == -1) {
        drawnString = @"--";
    } else {
        drawnString = [NSString stringWithFormat:@"%ld", (long) drawnFrameCount];
    }

    self.meterLabel.text = [NSString stringWithFormat:@"%@   %@", droppedString, drawnString];
}

- (void)displayLinkWillDraw:(CADisplayLink *)displayLink
{
    // printf("%ld \t%f \t%f\n", self.frameNumber % 60, [NSDate date].timeIntervalSince1970 * 60, displayLink.timestamp * 60);

    CFTimeInterval currentFrameTime = displayLink.timestamp;
    CFTimeInterval frameDuration = currentFrameTime - [self lastFrameTime];

    // Frames should be even multiples of kNormalFrameDuration.
    // If a frame takes two frame durations, we dropped at least one, so click.
    if (1.5 < frameDuration / kNormalFrameDuration) {
        AudioServicesPlaySystemSound(self.tickSoundID);
    }

    [self recordFrameTime:currentFrameTime];

    [self updateMeterLabel];
}

#pragma mark -

- (void)start
{
    NSURL *tickSoundURL = [[NSBundle bundleForClass:KMCGeigerCounter.class] URLForResource:@"KMCGeigerCounterTick" withExtension:@"aiff"];
    SystemSoundID tickSoundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) tickSoundURL, &tickSoundID);
    self.tickSoundID = tickSoundID;

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkWillDraw:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self clearLastSecondOfFrameTimes];

    // Low framerates can be caused by CPU activity on the main thread or by long compositing time in (I suppose)
    // the graphics driver. If compositing time is the problem, and it doesn't require a lot of main thread activity
    // between frames, then the framerate can drop without CADisplayLink detecting it.
    // Therefore, put an empty 1pt x 1pt SKView in the window. It shouldn't interfere with the framerate, but
    // should cause the CADisplayLink callbacks to match the timing of drawing.
    // TODO: This should be lightweight but affects the framerate on iOS 9, particularly in the example application.
    // Maybe if I use only the SKView and not the CADisplayLink?
    // No, that doesn't help. The SKView alone is causing the drawing latency. The CADisplayLink does not interfere.
    // SceneKit doens't exist before iOS 8, so I'd prefer not to rely on it.
    // A GLKViewController works on the default run loop, so it doesn't get updates during core animation scrolling.
    // Using a custom view with -drawRect: or -displayLayer:, callbacks happen just as often as CADisplayLink.
    // I need a new way to accurately detect when a frame is drawn to the screen without affecting the framerate.
    SKScene *scene = [[SKScene alloc] initWithSize:CGSizeMake(1.0, 1.0)];
    self.sceneView = [[SKView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 1.0)];
    [self.sceneView presentScene:scene];

    [[UIApplication sharedApplication].keyWindow addSubview:self.sceneView];
}

- (void)stop
{
    [self.sceneView removeFromSuperview];
    self.sceneView = nil;

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
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[UIViewController alloc] init];
    self.window.windowLevel = self.windowLevel;
    self.window.userInteractionEnabled = NO;

    CGFloat const kMeterWidth = 65.0;
    CGFloat xOrigin = 0.0;
    UIViewAutoresizing autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    switch (self.position) {
        case KMCGeigerCounterPositionLeft:
            xOrigin = 0.0;
            autoresizingMask |= UIViewAutoresizingFlexibleRightMargin;
            break;
        case KMCGeigerCounterPositionMiddle:
            xOrigin = (CGRectGetWidth(self.window.bounds) - kMeterWidth) / 2.0;
            autoresizingMask |= UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
            break;
        case KMCGeigerCounterPositionRight:
            xOrigin = (CGRectGetWidth(self.window.bounds) - kMeterWidth);
            autoresizingMask |= UIViewAutoresizingFlexibleLeftMargin;
            break;
    }
    self.meterLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOrigin, 0.0,
                                                                kMeterWidth, 20.0)];
    self.meterLabel.autoresizingMask = autoresizingMask;
    self.meterLabel.font = [UIFont boldSystemFontOfSize:12.0];
    self.meterLabel.backgroundColor = [UIColor grayColor];
    self.meterLabel.textColor = [UIColor whiteColor];
    self.meterLabel.textAlignment = NSTextAlignmentCenter;
    [self.window.rootViewController.view addSubview:self.meterLabel];

    self.window.hidden = NO;

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

    self.meterLabel = nil;
    self.window = nil;
}

#pragma mark - Init/dealloc

- (instancetype)init
{
    self = [super init];
    if (self) {
        _windowLevel = UIWindowLevelStatusBar + 10.0;
        _position = KMCGeigerCounterPositionMiddle;

        _meterPerfectColor = [KMCGeigerCounter colorWithHex:0x999999 alpha:1.0];
        _meterGoodColor = [KMCGeigerCounter colorWithHex:0x66a300 alpha:1.0];
        _meterBadColor = [KMCGeigerCounter colorWithHex:0xff7f0d alpha:1.0];
    }
    return self;
}

- (void)dealloc
{
    [_displayLink invalidate];

    if (_tickSoundID) {
        AudioServicesDisposeSystemSoundID(_tickSoundID);
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public interface

+ (instancetype)sharedGeigerCounter
{
    static KMCGeigerCounter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[KMCGeigerCounter alloc] init];
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

- (void)setWindowLevel:(UIWindowLevel)windowLevel
{
    _windowLevel = windowLevel;
    self.window.windowLevel = windowLevel;
}

- (NSInteger)droppedFrameCountInLastSecond
{
    NSInteger droppedFrameCount = 0;

    CFTimeInterval lastFrameTime = CACurrentMediaTime() - kNormalFrameDuration;
    for (NSInteger i = 0; i < kHardwareFramesPerSecond; ++i) {
        if (1.0 <= lastFrameTime - _recentFrameTimes[i]) {
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
