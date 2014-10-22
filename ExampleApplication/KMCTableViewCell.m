//
//  KMCTableViewCell.m
//  KMCGeigerCounter
//
//  Created by Kevin Conner on 10/21/14.
//  Copyright (c) 2014 Kevin Conner. All rights reserved.
//

#import "KMCTableViewCell.h"
#import "KMCTableItem.h"

@interface KMCTableViewCell ()

@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;

@property (nonatomic, weak) IBOutlet UIImageView *unreadDotImageView;
@property (nonatomic, weak) IBOutlet UIImageView *senderPhotoImageView;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *senderEmailLabel;
@property (nonatomic, weak) IBOutlet UILabel *subjectLabel;
@property (nonatomic, weak) IBOutlet UILabel *bodyLabel;

@end

@implementation KMCTableViewCell

#pragma mark - UINibLoadingAdditions

- (void)awakeFromNib
{
    if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.preservesSuperviewLayoutMargins = NO;
    }

    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        self.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    }

    if (self.backgroundImageView != nil) {
        self.senderPhotoImageView.layer.cornerRadius = 8.0;

        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.senderPhotoImageView.bounds cornerRadius:8.0].CGPath;
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1].CGColor;
        shapeLayer.lineWidth = 2.0;
        shapeLayer.frame = self.senderPhotoImageView.bounds;
        [self.senderPhotoImageView.layer addSublayer:shapeLayer];
    }
}

#pragma mark - Public interface

+ (CGFloat)cellHeight
{
    return 100.0;
}

- (void)configureWithItem:(KMCTableItem *)item
{
    self.unreadDotImageView.hidden = !item.unread; // Don't you love double-negatives?
    self.senderPhotoImageView.image = item.senderPhoto;
    self.backgroundImageView.image = item.senderPhoto;
    self.senderEmailLabel.text = item.senderEmail;
    self.subjectLabel.text = item.subject;
    self.bodyLabel.text = item.body;
}

@end
