//
//  JDGImagePicker.h
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/28.
//

#import <Foundation/Foundation.h>
#import <JDGImagePicker/JDGImagePickerConfiguration.h>
#import <JDGImagePicker/JDGImageStack.h>
#import <JDGImagePicker/JDGImagePickerDefines.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JDGImagePickerDelegate;
@interface JDGImagePicker : NSObject

@property(nonatomic, weak) id <JDGImagePickerDelegate> delegate;

@property(nonatomic, retain) JDGImagePickerConfiguration *configuration;

@property(nonatomic, retain, readonly) JDGImageStack *photoStack;

+ (instancetype)sharedPicker;

+ (void)destroyShared;

@end

@interface JDGImagePicker (UI)

- (void)presentFromViewController:(UIViewController *)viewCtrl animated: (BOOL)flag completion:(void (^ __nullable)(void))completion;

- (void)dismiss;

@end

@protocol JDGImagePickerDelegate <NSObject>

@optional
- (void)imagePickerWillDismiss:(JDGImagePicker *)imagePicker;

- (void)imagePicker:(JDGImagePicker *)imagePicker didFinishWithResultSelection:(JDGImageStack *)resultSelection;

- (void)imagePickerDidCancel:(JDGImagePicker *)imagePicker;

@end

NS_ASSUME_NONNULL_END
