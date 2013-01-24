//
//  testDetailViewController.m
//  test2
//
//  Created by Matthew Brown on 22/01/2013.
//  Copyright (c) 2013 Matthew Brown. All rights reserved.
//

#import "testDetailViewController.h"
#import <baito.h>

@interface testDetailViewController ()
- (void)configureView;
@end

@implementation testDetailViewController

#pragma mark - Managing the detail item

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
  UIApplication *application = [UIApplication sharedApplication];

  if (self.detailItem) {
    NSString *uuid = self.detailItem;

    application.networkActivityIndicatorVisible = YES;
    JobResponse res = job_view([uuid cStringUsingEncoding:NSUTF8StringEncoding]);
    application.networkActivityIndicatorVisible = NO;

    if (res.success == 0) {
      _descriptionLabel.text = @"Loading Failed";
      return;
    }
    
    _titleLabel.text = [NSString stringWithCString:res.job.title encoding:NSUTF8StringEncoding];
    _wageLabel.text = [NSString stringWithFormat:@"%G",res.job.wage];
    _hoursLabel.text = [NSString stringWithFormat:@"%G",res.job.hours];
    _companyLabel.text = [NSString stringWithCString:res.job.company encoding:NSUTF8StringEncoding];
    _contactLabel.text = [NSString stringWithCString:res.job.contactName encoding:NSUTF8StringEncoding];
    _emailLabel.text = [NSString stringWithCString:res.job.contactEmail encoding:NSUTF8StringEncoding];
    _phoneLabel.text = [NSString stringWithCString:res.job.contactTelephone encoding:NSUTF8StringEncoding];
    _descriptionLabel.text = [NSString stringWithCString:res.job.description encoding:NSUTF8StringEncoding];
    
//    [_mapView ]
    
    
    
    
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  [self configureView];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
