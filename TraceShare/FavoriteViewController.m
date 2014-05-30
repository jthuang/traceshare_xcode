//
//  FavoriteViewController.m
//  TraceShare
//
//  Created by Huang Jiun-Tang on 4/17/14.
//  Copyright (c) 2014 JT Huang. All rights reserved.
//

#import "FavoriteViewController.h"

@interface FavoriteViewController ()

@end

@implementation FavoriteViewController

- (void)viewDidLoad
{
    // Do any additional setup after loading the view, typically from a nib.
    [super viewDidLoad];
    NSString *fullURL = @"http://traceshare.herokuapp.com/favorite";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_favoriteWeb loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
