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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
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
	
	// checking if camera is supported by our device or not
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		// adding camera action to your actionsheet
		UIAlertAction* camera = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
								 {
									 picker.sourceType = UIImagePickerControllerSourceTypeCamera;
									 [viewController presentViewController:picker animated:YES completion:nil];
								 }];
		
		[actionSheet addAction:camera];
		
	}
	
	//checking if gallery is supported by our device or not
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		// adding gallery action to your actionsheet
		UIAlertAction* gallery = [UIAlertAction actionWithTitle:NSLocalizedString(@"Gallery", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
								  {
									  picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
									  [viewController presentViewController:picker animated:YES completion:nil];
								  }];
		[actionSheet addAction:gallery];
	}
	
	// adding cancel action to your actionsheet
	UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
	[actionSheet addAction:cancel];
	
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
//		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//		NSString *documentsDirectory = [paths objectAtIndex:0];
//		NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"latest_photo.png"];
		UIImage* image = info[UIImagePickerControllerOriginalImage];
//		NSData* imageData = UIImagePNGRepresentation(image);
		NSError* error = nil;
//		[imageData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
		
		NSData *imageData = UIImagePNGRepresentation(image); //convert image into .png format.
		
		NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
		
		NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
		
		NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", @"latest_photo"]]; //add our image to the path
		
		[fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
		
		NSURL* imageURL = [NSURL fileURLWithPath:fullPath];

		if (error) {
			NSLog(@"%@", [error localizedDescription]);
		}
		
		
		
		self.sendImage(info[UIImagePickerControllerOriginalImage],imageURL.absoluteString);
		
		[picker dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
