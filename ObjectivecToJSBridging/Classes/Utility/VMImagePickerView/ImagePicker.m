//
//  VMImagePicker.m
//  Virtual Mall
//
//  Created by Mohini Sindhu  on 17/04/17.
//  Copyright © 2017 mindfire. All rights reserved.
//

#import "ImagePicker.h"

@interface ImagePicker ()

@end

@implementation ImagePicker

#pragma mark - View Life Cycle methods
- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark - ImagePicker custom methods
// method to get shared instance of VMImagePicker Class
+(instancetype) getImagePickerInstance
{
	static dispatch_once_t once;
	static ImagePicker* sinstance = nil;
	if(sinstance == nil)
	{
		dispatch_once(&once, ^
					  {
						  sinstance = [[ImagePicker alloc]init];
                          sinstance.allowsEditing = YES;
					  });
	}
	return  sinstance;
}

// method takes the refrence of the vc on which action sheet needs to be displayed and displays the actionsheet
+(void) getImageFromImagePicker:(UIViewController *)viewController withCompletionHandler:(void (^)(UIImage *,NSString* ))callBack
{
	ImagePicker* picker = [ImagePicker getImagePickerInstance];
    
	picker.delegate = picker;
	picker.sendImage = callBack;
	
	UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"choose Image", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	
    // add three options to image picker (CAmera, Gallery, Cancel)
    [ImagePicker addCameraOption:picker onViewController:viewController withActionSheet:actionSheet];
    [ImagePicker addgalleryOption:picker onViewController:viewController withActionSheet:actionSheet];
    [ImagePicker addCancelButton:actionSheet];
	
    // adding action sheet to the desired VC
	[viewController presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - UIImagePickerDelegates
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated:YES completion:nil];
	
	if(self.sendImage)
		self.sendImage(nil,nil);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	if(self.sendImage)
	{
        UIImage* image = info[UIImagePickerControllerOriginalImage];
				
        self.sendImage(info[UIImagePickerControllerOriginalImage],[self saveImageToDirectory:image]);
		
		[picker dismissViewControllerAnimated:YES completion:nil];
	}
}

#pragma mark- Private methods
// method saves imge to directory and returns its path
-(NSString* ) saveImageToDirectory:(UIImage* )image
{
    NSError* error = nil;
    
    NSData* imageData = UIImagePNGRepresentation(image);
    
    //create an array and store result of our search for the documents directory in it
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //create NSString object, that holds our exact path to the documents directory
    NSString* documentsDirectory = [paths objectAtIndex:kconstintZero];
    
    NSString* fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",kDefaultFileName]];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
    if(fileExists)
    {
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
        [imageData writeToFile:fullPath atomically:NO];
    }
    else
        [[NSFileManager defaultManager] createFileAtPath:fullPath contents:imageData attributes:nil];
    
    if (error)
        NSLog(@"%@",[error localizedDescription]);
    
    return fullPath;
}

// method adds camra option to alert sheet
+(void)addCameraOption : (ImagePicker* )picker onViewController:(UIViewController* )controller withActionSheet:(UIAlertController* )actionSheet
{
    // checking if camera is supported by our device or not
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // adding camera action to your actionsheet
        UIAlertAction* camera = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                 {
                                     picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                     [controller presentViewController:picker animated:YES completion:nil];
                                 }];
        [actionSheet addAction:camera];
    }
}

// adding gallery action to your actionsheet
+(void)addgalleryOption: (ImagePicker* )picker onViewController:(UIViewController* )controller withActionSheet:(UIAlertController* )actionSheet
{
    //checking if gallery is supported by our device or not
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIAlertAction* gallery = [UIAlertAction actionWithTitle:NSLocalizedString(@"Gallery", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                  {
                                      picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                      [controller presentViewController:picker animated:YES completion:nil];
                                  }];
        [actionSheet addAction:gallery];
    }
}

// adding cancel action to your actionsheet
+(void) addCancelButton : (UIAlertController* )actionSheet
{
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [actionSheet addAction:cancel];
}

@end
