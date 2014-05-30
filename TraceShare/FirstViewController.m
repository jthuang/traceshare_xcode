//
//  FirstViewController.m
//  TraceShare
//
//  Created by Huang Jiun-Tang on 4/17/14.
//  Copyright (c) 2014 JT Huang. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [super viewDidLoad];
    NSString *fullURL = @"http://traceshare.herokuapp.com/explore";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_exploreWeb loadRequest:requestObj];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
