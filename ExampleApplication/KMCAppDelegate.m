//
//  KMCAppDelegate.m
//  KMCGeigerCounter
//
//  Created by Kevin Conner on 10/21/14.
//  Copyright (c) 2014 Kevin Conner. All rights reserved.
//

#import "KMCAppDelegate.h"
#import "KMCGeigerCounter.h"
#import "KMCTableViewController.h"

@implementation KMCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    KMCTableViewController *complexViewController = [KMCTableViewController new];
    complexViewController.title = @"Complex view";
    complexViewController.cellType = KMCTableViewCellTypeComplex;
    UINavigationController *complexNavigationController = [[UINavigationController alloc] initWithRootViewController:complexViewController];

    KMCTableViewController *simpleViewController = [KMCTableViewController new];
    simpleViewController.title = @"Simple view";
    simpleViewController.cellType = KMCTableViewCellTypeSimple;
    UINavigationController *simpleNavigationController = [[UINavigationController alloc] initWithRootViewController:simpleViewController];

    UITabBarController *tabBarController = [UITabBarController new];
    tabBarController.viewControllers = @[ complexNavigationController, simpleNavigationController ];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = tabBarController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [KMCGeigerCounter sharedGeigerCounter].running = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [KMCGeigerCounter sharedGeigerCounter].running = YES;
}

@end
