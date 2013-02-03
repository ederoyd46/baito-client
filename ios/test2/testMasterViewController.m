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
SearchResultsResponse lastSearchResultResponse;
BOOL searchRunning = NO;

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
  [_searchTerm resignFirstResponder];
  [self runSearch:YES isSearchMore:NO];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  for (CLLocation *location in locations) {
    _currentLocation = location;
    self.navigationItem.rightBarButtonItem.enabled = YES;
  }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  [searchBar resignFirstResponder];
  [self runSearch:NO isSearchMore:NO];
}

- (void) runSearch:(BOOL)isByLocation isSearchMore:(BOOL)searchMore
{
  if (!searchRunning) {
    
    if (searchMore && lastSearchResultResponse.morePossible == 0) {
      return;
    }
    
    searchRunning = YES;
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;

    __block NSMutableArray *results = [[NSMutableArray alloc] init];
    
    NSString *term = _searchTerm.text;
    const CLLocation *location = _currentLocation;
    
    dispatch_queue_t searchQueue = dispatch_queue_create("Baito Search Queue", NULL);
    
    dispatch_async(searchQueue, ^{
      SearchResultsResponse res;
      if (searchMore) {
          res = jobs_search_for_more(lastSearchResultResponse);
      } else {
        clear_job_search(lastSearchResultResponse);
        if (isByLocation) {
          res = jobs_direct_search(location.coordinate.latitude, location.coordinate.longitude);
        } else {
          res = jobs_search([term cStringUsingEncoding:NSUTF8StringEncoding]);
        }
      }

      lastSearchResultResponse = res;
      int i;
      for (i = 0; i < res.count; i++) {
        NSString *uuid = [NSString stringWithCString:res.results[i].uuid encoding:NSUTF8StringEncoding];
        NSString *title = [NSString stringWithCString:res.results[i].title encoding:NSUTF8StringEncoding];
        NSString *distance = [[NSNumber numberWithDouble:res.results[i].distance] stringValue];
        NSString *disStr = [distance stringByAppendingString:@" mi"];
        NSDictionary *entry = @{@"uuid": uuid, @"title": title, @"distance": disStr};
        [results addObject:entry];
      }

      dispatch_async(dispatch_get_main_queue(), ^{
        _objects = results;
        [self.tableView reloadData];
        application.networkActivityIndicatorVisible = NO;
        searchRunning = NO;
      });
    });
  }
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
  cell.detailTextLabel.text = [object valueForKey: @"distance"];

  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  float row = indexPath.row+1;
  float total = _objects.count;
  
  float percent = (row/total)*100;
  
  if (percent >= 95) {
    [self runSearch:NO isSearchMore:YES];
//    NSLog(@"trigger search");
  }
  
//  NSLog(@"showing cell %i of %i = %f", indexPath.row, _objects.count, percent);
  
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
