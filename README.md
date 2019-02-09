# KMCGeigerCounter

This tool is a framerate meter that clicks like a Geiger counter when your animation drops a frame.

A Geiger counter detects invisible particles and alerts you to what you can't see. Dropped frames aren't invisible, but it can be hard to tell the difference between 55 and 60 fps. KMCGeigerCounter makes each dropped frame obvious.

- If you're not consistently animating smoothly, you'll hear a rough, staticky noise.
- If your app runs at a smooth 60 fps, you'll hear the occasional drops to 59 and 58.
- You will hear dropped frames from occasional CPU spikes, like when custom table view cells enter the screen and require layout.

The meter shows two numbers:

- The number of frames dropped in the past second
- The number of frames drawn in the past second

The meter will be orange when you've dropped at least three frames in the past second.

## Installation

`pod 'KMCGeigerCounter'`

Or copy these files into your project:

- KMCGeigerCounter.h
- KMCGeigerCounter.m
- KMCGeigerCounter.aiff

If you're not using CocoaPods, you may need to add this framework to your Link Binary With Libraries build phase:

- AudioToolbox.framework

## Usage

In your `UIApplicationDelegate`, enable the tool:

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // …
    [self.window makeKeyAndVisible];

    [KMCGeigerCounter sharedGeigerCounter].enabled = YES;
}
```

Build and run your app. Navigate through your app and listen for clicks.

## Known issue

Dropped frames on iOS can be divided into two types, which I'll call CPU and GPU drops. CPU drops happen when main thread activity delays the preparation of your layer tree, like when Auto Layout evaluates a complex set of constraints. CPU drops are easy to measure by observing the delivery timing of regularly scheduled events on the main thread. GPU drops happen when the layer tree is expensive to draw, such as when there are too many blended layers. Due to the nature of iOS, GPU drops happen in a system process responsible for drawing. I haven't found a way to measure them without adversely affecting the app's framerate. The upshot is that only CPU drops can be detected by this library today. Fortunately, more powerful iOS devices have made GPU drops much less common than they used to be, and you can always use the Core Animation instrument to measure them faithfully.

## Notes

Remember to turn off Silent mode, or you won't hear anything. 

You should remove KMCGeigerCounter before shipping to the App Store. It can't be good for battery life.

The iOS Simulator doesn't simulate device performance, so consider enabling the tool only for device builds:

```objc
#if !TARGET_IPHONE_SIMULATOR
[KMCGeigerCounter sharedGeigerCounter].enabled = YES;
#endif
```
