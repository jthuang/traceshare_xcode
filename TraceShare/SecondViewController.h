//
//  SecondViewController.h
//  TraceShare
//
//  Created by Huang Jiun-Tang on 4/17/14.
//  Copyright (c) 2014 JT Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerController.h"

@interface SecondViewController : UIViewController <ELCImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *traceWeb;
@property (nonatomic, copy) NSArray *chosenImages;

@end
