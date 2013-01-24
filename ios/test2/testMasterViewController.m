//
//  testMasterViewController.m
//  test2
//
//  Created by Matthew Brown on 22/01/2013.
//  Copyright (c) 2013 Matthew Brown. All rights reserved.
//

#import "testMasterViewController.h"

#import "testDetailViewController.h"
#import <baito.h>

@interface testMasterViewController () {
  NSMutableArray *_objects;
}
@end

@implementation testMasterViewController

- (void)awakeFromNib
{
  [super awakeFromNib];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  //    self.navigationItem.leftBarButtonItem = self.editButtonItem;
  
  //    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
  //    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  UIApplication *application = [UIApplication sharedApplication];
  application.networkActivityIndicatorVisible = YES;
  
  if (!_objects) {
    _objects = [[NSMutableArray alloc] init];
  }
  
  [_objects removeAllObjects];

  if (_searchTerm.text.length > 0) {
    
    const char *term = [_searchTerm.text cStringUsingEncoding:NSUTF8StringEncoding];
    
    SearchResultsResponse res = jobs_search((char *)term);
    int i;
    for (i = 0; i < res.count; i++) {
      NSString *uuid = [NSString stringWithCString:res.results[i].uuid encoding:NSUTF8StringEncoding];
      NSString *title = [NSString stringWithCString:res.results[i].title encoding:NSUTF8StringEncoding];
      NSDictionary *entry = @{@"uuid": uuid, @"title": title};
      [_objects addObject:entry];
    }
    
    clear_job_search(res);
    
  }
  
  [self.tableView reloadData];
  [searchBar resignFirstResponder];
  application.networkActivityIndicatorVisible = NO;

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
