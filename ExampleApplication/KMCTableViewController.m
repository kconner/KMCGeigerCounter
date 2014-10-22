//
//  KMCTableViewControllerTableViewController.m
//  KMCGeigerCounter
//
//  Created by Kevin Conner on 10/21/14.
//  Copyright (c) 2014 Kevin Conner. All rights reserved.
//

#import "KMCTableViewController.h"
#import "KMCTableItem.h"
#import "KMCTableViewCell.h"

static NSString * const kCellIdentifier = @"KMCTableViewCell";

@interface KMCTableViewController ()

@property (nonatomic, copy) NSArray *items;

@end

@implementation KMCTableViewController

#pragma mark - Init/dealloc

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSMutableArray *items = [NSMutableArray array];

        NSArray *senderEmails = @[ @"sirrobin@zomgcats.com",
                                   @"splat@caturday.co.uk" ];

        NSArray *subjects = @[ @"Re: The red dot that must die",
                               @"ACHOO" ];

        NSArray *bodies = @[ @"To whom it may concern,\nIf your tiny red dot wanders into my house again, I can't be held responsible for what happens to it.",
                             @"I hope it's OK that I just sneezed on your face while you slept.\n…Are you going to eat that?" ];

        for (NSInteger i = 0; i < 50; i++) {
            KMCTableItem *item = [KMCTableItem new];
            item.unread = i % 3 == 0;
            item.senderPhoto = [UIImage imageNamed:[NSString stringWithFormat:@"cat%ld", (long) (i % 10)]];
            item.senderEmail = senderEmails[i % senderEmails.count];
            item.subject = subjects[i % subjects.count];
            item.body = bodies[i % bodies.count];

            [items addObject:item];
        }

        _items = [items copy];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    switch (self.cellType) {
        case KMCTableViewCellTypeSimple:
            [self.tableView registerNib:[UINib nibWithNibName:@"KMCSimpleTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
            break;
        case KMCTableViewCellTypeComplex:
            [self.tableView registerNib:[UINib nibWithNibName:@"KMCComplexTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
            self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
            break;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [KMCTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KMCTableItem *item = self.items[indexPath.row];

    KMCTableViewCell *cell = (KMCTableViewCell *) [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];

    [cell configureWithItem:item];

    return cell;
}

@end
