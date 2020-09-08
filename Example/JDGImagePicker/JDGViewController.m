//
//  JDGViewController.m
//  JDGImagePicker
//
//  Created by 甘邻龙01516778 on 08/28/2020.
//  Copyright (c) 2020 甘邻龙01516778. All rights reserved.
//

#import "JDGViewController.h"
#import <JDGImagePicker/JDGImagePicker.h>

@interface JDGViewController () <JDGImagePickerDelegate>
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
    
    JDGImagePicker.sharedPicker.delegate = self;
    [JDGImagePicker.sharedPicker presentFromViewController:self animated:YES completion:nil];
}

- (void)imagePicker:(JDGImagePicker *)imagePicker didFinishWithResultSelection:(JDGImageStack *)resultSelection {
    NSLog(@"%@",resultSelection.selectedPhotos);
}

@end
