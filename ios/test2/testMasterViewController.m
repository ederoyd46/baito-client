//
//  testMasterViewController.m
//  test2
//
//  Created by Matthew Brown on 22/01/2013.
//  Copyright (c) 2013 Matthew Brown. All rights reserved.
//

#import "testMasterViewController.h"
#import "baitoViewJobControllerViewController.h"
#import <baito.h>

@implementation testMasterViewController

NSMutableArray *_objects;
CLLocationManager *_locationManager;
CLLocation *_currentLocation;

- (void)awakeFromNib
{
  [super awakeFromNib];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  UIBarButtonItem *currentButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(currentLocationSearchButtonClicked:)];
  
  if (_searchTerm.text.length == 0 && _currentLocation == NULL) {
    currentButton.enabled = NO;
  }
  
  self.navigationItem.rightBarButtonItem = currentButton;
}

- (void)viewDidAppear:(BOOL)animated
{
  if (!_locationManager) {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager setPausesLocationUpdatesAutomatically:YES];
  }
  
  [_locationManager startUpdatingLocation];
}

-(void) viewWillDisappear:(BOOL)animated {
  if (_locationManager) {
    [_locationManager stopUpdatingLocation];
    [_locationManager stopMonitoringSignificantLocationChanges];
  }
}


- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

-(void)currentLocationSearchButtonClicked:(UIBarButtonItem *)currentSearchButton
{
  [self runSearch:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  for (CLLocation *location in locations) {
    _currentLocation = location;
    self.navigationItem.rightBarButtonItem.enabled = YES;
//    NSLog(@"async lat: %f lon: %f", location.coordinate.latitude, location.coordinate.longitude);
  }
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [self runSearch:NO];
  [searchBar resignFirstResponder];
}


- (void) runSearch:(BOOL)isByLocation
{
  UIApplication *application = [UIApplication sharedApplication];
  application.networkActivityIndicatorVisible = YES;
  
  if (!_objects) {
    _objects = [[NSMutableArray alloc] init];
  }
  
  //  __block NSMutableArray *newresults = [[NSMutableArray alloc] init];
  [_objects removeAllObjects];
  
  const char *term = [_searchTerm.text cStringUsingEncoding:NSUTF8StringEncoding];
  const CLLocation *location = _currentLocation;
  
  dispatch_queue_t searchQueue = dispatch_queue_create("Baito Search Queue", NULL);
  
  dispatch_async(searchQueue, ^{
    SearchResultsResponse res;
    if (isByLocation) {
      res = jobs_direct_search(location.coordinate.latitude, location.coordinate.longitude);
    } else {
      res = jobs_search((char *)term);
    }
    
    int i;
    for (i = 0; i < res.count; i++) {
      NSString *uuid = [NSString stringWithCString:res.results[i].uuid encoding:NSUTF8StringEncoding];
      NSString *title = [NSString stringWithCString:res.results[i].title encoding:NSUTF8StringEncoding];
      NSDictionary *entry = @{@"uuid": uuid, @"title": title};
      [_objects addObject:entry];
    }
    
    clear_job_search(res);
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.tableView reloadData];
      application.networkActivityIndicatorVisible = NO;
    });
  });
}



#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  NSDictionary *object = _objects[indexPath.row];
  cell.textLabel.text = [object valueForKey: @"title"];
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSDictionary *object = _objects[indexPath.row];
    [[segue destinationViewController] setDetailItem: [object valueForKey:@"uuid"]];
  }
}

@end
