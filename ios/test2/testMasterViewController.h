//
//  testMasterViewController.h
//  test2
//
//  Created by Matthew Brown on 22/01/2013.
//  Copyright (c) 2013 Matthew Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface testMasterViewController : UITableViewController <UISearchBarDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchTerm;
@property (weak, nonatomic) IBOutlet UIView *settingsView;

@end

