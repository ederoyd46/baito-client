//
//  baitoLoginViewController.h
//  Baito
//
//  Created by Matthew Brown on 09/02/2013.
//  Copyright (c) 2013 Matthew Brown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface baitoLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

- (IBAction)loginUser:(id)sender;

@end

