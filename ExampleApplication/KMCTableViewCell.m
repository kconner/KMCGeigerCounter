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

        CAShapeLayer *photoOutlineLayer = [CAShapeLayer layer];
        photoOutlineLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.senderPhotoImageView.bounds cornerRadius:8.0].CGPath;
        photoOutlineLayer.strokeColor = [UIColor whiteColor].CGColor;
        photoOutlineLayer.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1].CGColor;
        photoOutlineLayer.lineWidth = 2.0;
        photoOutlineLayer.frame = self.senderPhotoImageView.bounds;
        [self.senderPhotoImageView.layer addSublayer:photoOutlineLayer];

        CAShapeLayer *backgroundOutlineLayer = [CAShapeLayer layer];
        CGRect rect = UIEdgeInsetsInsetRect(self.backgroundImageView.bounds, UIEdgeInsetsMake(8.0, 4.0, 2.0, 4.0));
        backgroundOutlineLayer.path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:12.0].CGPath;
        backgroundOutlineLayer.strokeColor = [UIColor colorWithWhite:1.0 alpha:0.4].CGColor;
        backgroundOutlineLayer.fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.1].CGColor;
        backgroundOutlineLayer.lineWidth = 2.0;
        backgroundOutlineLayer.frame = self.backgroundImageView.bounds;
        [self.backgroundImageView.layer addSublayer:backgroundOutlineLayer];
    }

    if (self.toolbar) {
        self.toolbar.layer.cornerRadius = 4.0;
        self.toolbar.clipsToBounds = YES;
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
