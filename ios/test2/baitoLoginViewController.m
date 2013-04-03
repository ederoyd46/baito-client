//
//  baitoLoginViewController.m
//  Baito
//
//  Created by Matthew Brown on 09/02/2013.
//  Copyright (c) 2013 Matthew Brown. All rights reserved.
//

#import "baitoLoginViewController.h"
#import <baito/baito.h>

@implementation baitoLoginViewController


-(void) loginUser:(id)sender {
  
  NSString *username = _username.text;
  NSString *password = _password.text;
  
  const char *sessionId = user_login([username cStringUsingEncoding:NSUTF8StringEncoding], [password cStringUsingEncoding:NSUTF8StringEncoding]);
  
  NSLog(@"session id: %s", sessionId);
}

//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






@end
