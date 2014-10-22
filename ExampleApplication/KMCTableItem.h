//
//  KMCTableItem.h
//  KMCGeigerCounter
//
//  Created by Kevin Conner on 10/21/14.
//  Copyright (c) 2014 Kevin Conner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMCTableItem : NSObject

@property (nonatomic, assign, getter = isUnread) BOOL unread;
@property (nonatomic, strong) UIImage *senderPhoto;
@property (nonatomic, copy) NSString *senderEmail;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *body;

@end
