//
//  KMCTableViewCell.h
//  KMCGeigerCounter
//
//  Created by Kevin Conner on 10/21/14.
//  Copyright (c) 2014 Kevin Conner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMCTableItem;

@interface KMCTableViewCell : UITableViewCell

+ (CGFloat)cellHeight;

- (void)configureWithItem:(KMCTableItem *)item;

@end
