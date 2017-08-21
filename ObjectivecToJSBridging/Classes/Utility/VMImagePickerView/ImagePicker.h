//
//  VMImagePicker.h
//  Virtual Mall
//
//  Created by Mohini Sindhu  on 17/04/17.
//  Copyright © 2017 mindfire. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePicker : UIImagePickerController <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong,nonatomic) void (^sendImage)(UIImage* selectedImage,NSString* imagePath);

+(void) getImageFromImagePicker :(UIViewController*)viewController withCompletionHandler:(void (^) (UIImage* selectedImage,NSString* imagePath))callBack;

@end
