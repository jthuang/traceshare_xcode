//
//  CaptureViewController.m
//  TraceShare
//
//  Created by Huang Jiun-Tang on 5/4/14.
//  Copyright (c) 2014 JT Huang. All rights reserved.
//

#import "CaptureViewController.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"

@interface CaptureViewController ()<UIWebViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSString *callback; // 定义变量用于保存返回函数
}
@property (nonatomic, strong) ALAssetsLibrary *specialLibrary;

@end

@implementation CaptureViewController

- (void)viewDidLoad
{
    // Do any additional setup after loading the view, typically from a nib.
    [super viewDidLoad];
    self.captureWeb.delegate = self;
    NSString *fullURL = @"http://traceshare.herokuapp.com/capture";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_captureWeb loadRequest:requestObj];
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
        if ([[vals objectAtIndex:0] isEqualToString:@"camera"]) { // 摄像头
            callback = [vals objectAtIndex:1];
            [self doAction:UIImagePickerControllerSourceTypeCamera];
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
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        imagePicker.sourceType = sourceType;
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        // 返回图片
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        // 设置并显示加载动画
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
        // 在后台线程处理图片
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [av dismissWithClickedButtonIndex:0 animated:YES]; // 关闭动画
            // 这里可以对图片做一些处理，如调整大小等，否则图片过大显示在网页上时会造成内存警告
            double compressionRatio=1;
            NSData *imgData=UIImageJPEGRepresentation(originalImage,compressionRatio);
            while ([imgData length]>500000) {
                compressionRatio=compressionRatio*0.5;
                imgData=UIImageJPEGRepresentation(originalImage,compressionRatio);
            }
            NSString *base64 = [imgData base64Encoding]; // 图片转换成base64字符串
            [self performSelectorOnMainThread:@selector(doCallback:) withObject:base64 waitUntilDone:YES]; // 把结果显示在网页上

        });
    }
    
    [picker dismissModalViewControllerAnimated:YES];
}



- (void)doCallback:(NSString *)data
{
    [self.captureWeb stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@');", callback, data]];
}



@end


