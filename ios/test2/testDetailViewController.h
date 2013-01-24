//
//  testDetailViewController.h
//  test2
//
//  Created by Matthew Brown on 22/01/2013.
//  Copyright (c) 2013 Matthew Brown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface testDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
