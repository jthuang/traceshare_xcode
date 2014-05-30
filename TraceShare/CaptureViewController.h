//
//  CaptureViewController.h
//  TraceShare
//
//  Created by Huang Jiun-Tang on 5/4/14.
//  Copyright (c) 2014 JT Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerController.h"

//@interface CaptureViewController : UIViewController
@interface CaptureViewController : UIViewController <ELCImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *captureWeb;
@property (nonatomic, copy) NSArray *chosenImages;

@end
