# KMCGeigerCounter

KMCGeigerCounter is a performance testing tool that clicks like a Geiger counter when your animation drops a frame.

A Geiger counter detects invisible radiation particles and alerts you to what you can't see. Dropped frames aren't invisible, but it can be hard to tell the difference between 55 and 60 fps. KMCGeigerCounter makes those five dropped frames obvious.

- If you're not consistently animating smoothly, you'll hear a rough, staticky noise.
- If your app runs at a smooth 60 fps, you'll hear the occasional drops to 59 and 58.
- You can even hear dropped frames from CPU spikes, like when custom table view cells enter the screen and require layout.

## Installation

`pod 'KMCGeigerCounter'`

Or copy KMCGeigerCounter.h, KMCGeigerCounter.m, and KMCGeigerCounterTick.aiff into your project.

## Usage

In your `UIApplicationDelegate`, enable the tool:

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        // …
        [self.window makeKeyAndVisible];

        [KMCGeigerCounter sharedGeigerCounter].enabled = YES;
    }

Then, build and run your app. Navigate through your app and listen for clicks.

## Dumb things you probably thought of, but seriously

Remember to turn off Silent mode, or you won't hear anything. 

You should remove KMCGeigerCounter before shipping to the App Store.
