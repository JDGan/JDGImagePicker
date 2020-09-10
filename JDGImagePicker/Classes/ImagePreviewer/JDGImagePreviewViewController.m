//
//  JDGImagePreviewViewController.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/31.
//

#import "JDGImagePreviewViewController.h"

@interface JDGImagePreviewViewController () 

@end

@implementation JDGImagePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    JDGImagePickerConfiguration *config = JDGImagePickerConfiguration.shared;
    self.title = config.previewViewTitle;
}

@end
