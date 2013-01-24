//
//  baitoViewJobControllerViewController.m
//  Baito
//
//  Created by Matthew Brown on 24/01/2013.
//  Copyright (c) 2013 Matthew Brown. All rights reserved.
//

#import "baitoViewJobControllerViewController.h"

@interface baitoViewJobControllerViewController ()
- (void)configureView;
@end

@implementation baitoViewJobControllerViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)setDetailItem:(id)newDetailItem
{
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
    
    // Update the view.
    [self configureView];
  }
}

- (void)configureView
{
//  UIApplication *application = [UIApplication sharedApplication];
//  
//  if (self.detailItem) {
//    NSString *uuid = self.detailItem;
//    
//    application.networkActivityIndicatorVisible = YES;
//    JobResponse res = job_view([uuid cStringUsingEncoding:NSUTF8StringEncoding]);
//    application.networkActivityIndicatorVisible = NO;
//    
//    if (res.success == 0) {
//      _descriptionLabel.text = @"Loading Failed";
//      return;
//    }
//    
//    _titleLabel.text = [NSString stringWithCString:res.job.title encoding:NSUTF8StringEncoding];
//    _wageLabel.text = [NSString stringWithFormat:@"%G",res.job.wage];
//    _hoursLabel.text = [NSString stringWithFormat:@"%G",res.job.hours];
//    _companyLabel.text = [NSString stringWithCString:res.job.company encoding:NSUTF8StringEncoding];
//    _contactLabel.text = [NSString stringWithCString:res.job.contactName encoding:NSUTF8StringEncoding];
//    _emailLabel.text = [NSString stringWithCString:res.job.contactEmail encoding:NSUTF8StringEncoding];
//    _phoneLabel.text = [NSString stringWithCString:res.job.contactTelephone encoding:NSUTF8StringEncoding];
//    _descriptionLabel.text = [NSString stringWithCString:res.job.description encoding:NSUTF8StringEncoding];
//    
//    //    [_mapView ]
//    
//    
//  }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

@end
