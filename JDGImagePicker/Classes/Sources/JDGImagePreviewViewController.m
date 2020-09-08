//
//  JDGImagePreviewViewController.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/31.
//

#import "JDGImagePreviewViewController.h"
#import "JDGImagePicker.h"

@interface JDGImagePreviewViewController () 

@end

@implementation JDGImagePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
    self.title = config.previewViewTitle;
}

@end
