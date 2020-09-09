# JDGImagePicker

[![Version](https://img.shields.io/cocoapods/v/JDGImagePicker.svg?style=flat)](https://cocoapods.org/pods/JDGImagePicker)
[![License](https://img.shields.io/cocoapods/l/JDGImagePicker.svg?style=flat)](https://cocoapods.org/pods/JDGImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/JDGImagePicker.svg?style=flat)](https://cocoapods.org/pods/JDGImagePicker)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

JDGImagePicker is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JDGImagePicker'
```

## Usage

```Objective-C
//...
#import <JDGImagePicker/JDGImagePicker.h>
//...
@interface XXXViewController() <JDGImagePickerDelegate>
//...
@implementation XXXViewController
//...
- (void)actionToShowPicker {
//...
    JDGImagePicker *picker = JDGImagePicker.sharedPicker;
    picker.delegate = self;
    JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
    config.imageSize = UIScreen.mainScreen.bounds.size;// or any other sizes
    config.doneButtonTitle = @"完成";
    config.cancelButtonTitle = @"取消";
    [picker presentFromViewController:self animated:YES completion:^{
        // complete animation
    }];
}
#pragma mark - JDGImagePickerDelegate
- (void)imagePicker:(JDGImagePicker *)imagePicker didFinishWithResultSelection:(JDGImageStack *)resultSelection {
    JDGImagePickerPhoto *photo = resultSelection.selectedPhotos.firstObject;
    [photo getOriginImageInMainQueueCompletion:^(UIImage * _Nullable image, NSError * _Nullable error) {
        // origin image here
    }];
    
    [photo getThumbnailImageInMainQueueCompletion:^(UIImage * _Nullable image, NSError * _Nullable error) {
        // thumbnail image here, this run much faster
    }];
    // destroy Shared instance if you need
    [JDGImagePicker destroyShared];
}

- (void)imagePickerDidCancel:(JDGImagePicker *)imagePicker {
    // destroy Shared instance if you need
    [JDGImagePicker destroyShared];
}
@end
```

## Author

Mr. Gan, jessiegan1987@163.com

## License

JDGImagePicker is available under the MIT license. See the LICENSE file for more info.
