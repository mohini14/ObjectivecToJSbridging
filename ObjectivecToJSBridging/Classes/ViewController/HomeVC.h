//
//  ViewController.h
//  ObjectivecToJSBridging
//
//  Created by Mohini Sindhu  on 21/08/17.
//  Copyright © 2017 Mohini Sindhu . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Webkit/Webkit.h>

@interface HomeVC : UIViewController<WKScriptMessageHandler>

@property (strong, nonatomic)WKWebView* appWebView;

@end

