//
//  ViewController.m
//  ObjectivecToJSBridging
//
//  Created by Mohini Sindhu  on 21/08/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import "HomeVC.h"
#import <ObjectivecToJSBridging-Swift.h>

@interface HomeVC ()

@end

@implementation HomeVC

#pragma mark- View life cycle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addWebViewToVC];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark-  Private methods

// method adds HTML code to VC
-(void) addWebViewToVC
{
    NSError *moveError = nil;
    
    //modify the array of file types to fit the web file types your app uses.
    NSString *indexHTMLPath = [WebMover moveDirectoriesAndWebFilesOfType:@[kJSExtension,kCSSExtension,kHTMLExtension,kPNGExtension,kJPEGExtension,kGIFExtension] error:&moveError];
    
    if (moveError != nil)
        NSLog(@"%@",moveError.description);
    
    [self manageJaveScriptMesssageHandler];
    
    // load HTML code on VC's view
    NSURL *url = [NSURL fileURLWithPath:indexHTMLPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.appWebView  loadRequest:request];
    [self.view addSubview:self.appWebView ];
}

//manage java script message handler
-(void) manageJaveScriptMesssageHandler
{
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    
    // add message handler to the java script
    [theConfiguration.userContentController addScriptMessageHandler:self name:kJavaScriptmessageHandler];
    self.appWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:theConfiguration];
}

// method is used to handle calls of JavaScript messages
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    __weak typeof(self) weakSelf = self;
    
    [ImagePicker getImagePathFromImagePicker:self withCompletionHandler:^(UIImage *selectedImage, NSString* imagePath)
     {
         // method is used to send data back to Java script
         [self.appWebView evaluateJavaScript:[NSString stringWithFormat:@"showImage('%@')",imagePath] completionHandler:^(id _Nullable JSReturnValue, NSError * _Nullable error)
          {
              [weakSelf logJavaScriptReturnedValues:JSReturnValue withError:error];
          }];
     }];
}

// method logs js returned value
-(void) logJavaScriptReturnedValues : (id) JSReturnValue withError:(NSError* )  error
{
    if (error)
    {
        NSLog(@"error: %@", error.description);
    }
    else if (JSReturnValue != nil)
    {
        NSLog(@"returned value: %@",JSReturnValue);
    }
    else
    {
        NSLog(@"no return from JS");
    }
}

@end
