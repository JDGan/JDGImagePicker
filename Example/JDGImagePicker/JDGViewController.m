//
//  JDGViewController.m
//  JDGImagePicker
//
//  Created by 甘邻龙01516778 on 08/28/2020.
//  Copyright (c) 2020 甘邻龙01516778. All rights reserved.
//

#import "JDGViewController.h"
#import <JDGImagePicker/JDGImagePicker.h>
#import <JDGImagePicker/JDGImagePreviewViewController.h>

@interface JDGViewController ()
<JDGImagePickerDelegate>
@end

@implementation JDGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)test:(id)sender {
    JDGImagePicker *picker = JDGImagePicker.shared;
    picker.delegate = self;
    JDGImagePickerConfiguration *config = JDGImagePickerConfiguration.shared;
    config.imageSize = UIScreen.mainScreen.bounds.size;// or any other sizes
    config.doneButtonTitle = @"完成";
    config.cancelButtonTitle = @"取消";
//    picker.previewerBlock = ^(NSArray<JDGImagePickerPhoto *> * _Nonnull photos, NSUInteger indexToShow) {
//        return [JDGImagePreviewViewController create];
//    };
    [picker presentFromViewController:self animated:YES completion:^{
        // complete animation
    }];
}
#pragma mark - JDGImagePickerDelegate
- (void)imagePicker:(JDGImagePicker *)imagePicker didFinishWithResultSelection:(JDGImageStack *)resultSelection {
    JDGImagePickerPhoto *photo = resultSelection.selectedPhotos.firstObject;
    [photo getOriginImageInMainQueueCompletion:^(UIImage * _Nullable image, NSDictionary * _Nullable info, NSError * _Nullable error) {
        // origin image here
    }];

    [photo getThumbnailImageInMainQueueCompletion:^(UIImage * _Nullable image, NSDictionary * _Nullable info, NSError * _Nullable error) {
        // thumbnail image here, this run much faster
    }];
    // destroy Shared instance if you need
    [JDGImagePicker destroyShared];
    [JDGImagePickerConfiguration destroyShared];
}

- (void)imagePickerDidCancel:(JDGImagePicker *)imagePicker {
    // destroy Shared instance if you need
    [JDGImagePicker destroyShared];
    [JDGImagePickerConfiguration destroyShared];
}

@end
