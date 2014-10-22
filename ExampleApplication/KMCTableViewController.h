//
//  KMCTableViewController.h
//  KMCGeigerCounter
//
//  Created by Kevin Conner on 10/21/14.
//  Copyright (c) 2014 Kevin Conner. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KMCTableViewCellType) {
    KMCTableViewCellTypeSimple,
    KMCTableViewCellTypeComplex,
};

@interface KMCTableViewController : UITableViewController

@property (nonatomic, assign) KMCTableViewCellType cellType;

@end
