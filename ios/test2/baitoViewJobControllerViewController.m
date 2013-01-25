//
//  baitoViewJobControllerViewController.m
//  Baito
//
//  Created by Matthew Brown on 24/01/2013.
//  Copyright (c) 2013 Matthew Brown. All rights reserved.
//

#import "baitoViewJobControllerViewController.h"
#import <baito.h>

@interface baitoViewJobControllerViewController () {
  NSDictionary *_jobData;
  MKMapView *_map;
}
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
  UIApplication *application = [UIApplication sharedApplication];
  application.networkActivityIndicatorVisible = YES;

  if (self.detailItem) {
    NSString *uuid = self.detailItem;

    JobResponse res = job_view([uuid cStringUsingEncoding:NSUTF8StringEncoding]);

    if (res.success == 0) {
      return;
    }

    NSDictionary *data = @{
      @"title" : [NSString stringWithCString:res.job.title encoding:NSUTF8StringEncoding],
      @"wage" : [NSString stringWithFormat:@"%G",res.job.wage],
      @"hours" : [NSString stringWithFormat:@"%G",res.job.hours],
      @"company" : [NSString stringWithCString:res.job.company encoding:NSUTF8StringEncoding],
      @"contact" : [NSString stringWithCString:res.job.contactName encoding:NSUTF8StringEncoding],
      @"email" : [NSString stringWithCString:res.job.contactEmail encoding:NSUTF8StringEncoding],
      @"phone" : [NSString stringWithCString:res.job.contactTelephone encoding:NSUTF8StringEncoding],
      @"postCode" : [NSString stringWithCString:res.job.postalCode encoding:NSUTF8StringEncoding],
      @"description" : [NSString stringWithCString:res.job.description encoding:NSUTF8StringEncoding],
      @"latitude" : [NSString stringWithFormat:@"%G",res.job.latitude],
      @"longitude" : [NSString stringWithFormat:@"%G",res.job.longitude],
    };
    _jobData = data;
  }
  
  application.networkActivityIndicatorVisible = NO;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  _titleLabel.text = [_jobData valueForKey:@"title"];
  _hoursLabel.text = [_jobData valueForKey:@"hours"];
  _wageLabel.text = [_jobData valueForKey:@"wage"];
  _companyLabel.text = [_jobData valueForKey:@"company"];
  _contactLabel.text = [_jobData valueForKey:@"contact"];
  _emailLabel.text = [_jobData valueForKey:@"email"];
  _phoneLabel.text = [_jobData valueForKey:@"phone"];
  _postCodeLabel.text = [_jobData valueForKey:@"postCode"];
  _descriptionLabel.text = [_jobData valueForKey:@"description"];

  if (!_map) {
    _map = [[MKMapView alloc] initWithFrame:_mapView.bounds];
    [_map setUserInteractionEnabled:NO];
    [_mapView addSubview:_map];
  }
  
  NSString *latitude = [_jobData valueForKey:@"latitude"];
  NSString *longitude = [_jobData valueForKey:@"longitude"];
  CLLocationCoordinate2D coord = { [latitude floatValue], [longitude floatValue] };
  MKCoordinateSpan span = {0.001, 0.001};
  MKCoordinateRegion region = {coord, span};
  [_map setRegion:region animated:YES];
  
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

//- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
//  NSLog(@"mapViewWillStartLoadingMap called");
//  
//  NSString *latitude = [_jobData valueForKey:@"latitude"];
//  NSString *longitude = [_jobData valueForKey:@"longitude"];
//  
//  
//  CLLocationCoordinate2D coord = { [latitude floatValue], [longitude floatValue] };
//  MKCoordinateSpan span = {0.001, 0.001};
//  MKCoordinateRegion region = {coord, span};
//  
//  [_mapView setRegion:region animated:NO];
//  
//}
//
//
//- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
//  NSLog(@"didChangeUserTrackingMode called");
//}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
  // Return the number of sections.
//  return 2;
//}

@end
