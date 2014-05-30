//
//  SecondViewController.m
//  TraceShare
//
//  Created by Huang Jiun-Tang on 4/17/14.
//  Copyright (c) 2014 JT Huang. All rights reserved.
//

#import "SecondViewController.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"

@interface SecondViewController ()<UIWebViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSString *callback; // 定义变量用于保存返回函数
}
@property (nonatomic, strong) ALAssetsLibrary *specialLibrary;

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    // Do any additional setup after loading the view, typically from a nib.
    [super viewDidLoad];
    self.traceWeb.delegate = self;
    NSString *fullURL = @"http://traceshare.herokuapp.com/mytrace";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_traceWeb loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    NSString *protocol = @"js-call://"; //协议名称
    if ([requestString hasPrefix:protocol]) {
        NSString *requestContent = [requestString substringFromIndex:[protocol length]];
        NSArray *vals = [requestContent componentsSeparatedByString:@"/"];
        if([[vals objectAtIndex:0] isEqualToString:@"photolibrary"]) { // 图库
            callback = [vals objectAtIndex:1];
            [self doAction:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        else {
            [webView stringByEvaluatingJavaScriptFromString:@"alert('未定义/lwme.cnblogs.com');"];
        }
        return NO;
    }
    return YES;
}


- (void)doAction:(UIImagePickerControllerSourceType)sourceType
{
    //UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    //imagePicker.delegate = self;
    ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] initImagePicker];
    imagePicker.maximumImagesCount = 4;
    imagePicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
	imagePicker.imagePickerDelegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        //        imagePicker.sourceType = sourceType;
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Failed to Access Picture" message:@"No Available Source" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    // iPad设备做额外处理
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [popover presentPopoverFromRect:CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 3, 10, 10) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        //        [self presentModalViewController:imagePicker animated:YES];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}


- (void)doCallback:(NSString *)data
{
    [self.traceWeb stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@');", callback, data]];
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Processing..." message:@"\n\n"
                                                delegate:self
                                       cancelButtonTitle:nil
                                       otherButtonTitles:nil, nil];
    
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loading.center = CGPointMake(139.5, 75.5);
    [av addSubview:loading];
    [loading startAnimating];
    [av show];
	[av dismissWithClickedButtonIndex:0 animated:YES]; // 关闭动画
	for (NSDictionary *dict in info) {
        // 返回图片
        UIImage *originalImage = [dict objectForKey:UIImagePickerControllerOriginalImage];
        // 设置并显示加载动画
        
        // 在后台线程处理图片
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            // 这里可以对图片做一些处理，如调整大小等，否则图片过大显示在网页上时会造成内存警告
            double compressionRatio=1;
            NSData *imgData=UIImageJPEGRepresentation(originalImage,compressionRatio);
            while ([imgData length]>500000) {
                compressionRatio=compressionRatio*0.5;
                imgData=UIImageJPEGRepresentation(originalImage,compressionRatio);
            }
            NSString *base64 = [imgData base64Encoding]; // 图片转换成base64字符串
            //NSString *base64 = [UIImagePNGRepresentation(originalImage) base64Encoding]; // 图片转换成base64字符串
            [self performSelectorOnMainThread:@selector(doCallback:) withObject:base64 waitUntilDone:YES]; // 把结果显示在网页上
        });
	}
    
    self.chosenImages = images;
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end