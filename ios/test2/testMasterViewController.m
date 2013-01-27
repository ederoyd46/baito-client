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
  //    self.navigationItem.leftBarButtonItem = self.editButtonItem;
  
  UIBarButtonItem *currentButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(currentLocationSearchButtonClicked:)];
      self.navigationItem.rightBarButtonItem = currentButton;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

-(void)currentLocationSearchButtonClicked:(UIBarButtonItem *)currentSearchButton
{
  if (!_locationManager) {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
  }

  [_locationManager startMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  for (CLLocation *location in locations) {
    _currentLocation = location;
    NSLog(@"async lat: %f lon: %f", location.coordinate.latitude, location.coordinate.longitude);
  }
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  UIApplication *application = [UIApplication sharedApplication];
  application.networkActivityIndicatorVisible = YES;

  if (!_objects) {
    _objects = [[NSMutableArray alloc] init];
  }

//  __block NSMutableArray *newresults = [[NSMutableArray alloc] init];
  [_objects removeAllObjects];
  
  const char *term = [_searchTerm.text cStringUsingEncoding:NSUTF8StringEncoding];
  dispatch_queue_t searchQueue = dispatch_queue_create("Baito Search Queue", NULL);

  dispatch_async(searchQueue, ^{
    SearchResultsResponse res = jobs_search((char *)term);
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
      [searchBar resignFirstResponder];
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
