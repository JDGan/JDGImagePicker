//
//  JDGImageStack.h
//  JDGImagePicker
//
//  Created by JDGan on 2020/9/2.
//

#import <Foundation/Foundation.h>
#import <JDGImagePicker/JDGImagePickerPhoto.h>
#import <JDGImagePicker/JDGAssetManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface JDGImageStack : NSObject

@property(nonatomic, retain, readonly) NSMutableArray<JDGImagePickerPhoto *> *selectedPhotos;

- (JDGImagePickerPhoto * _Nullable)objectForData:(id)data forType:(JDGImagePickerPhotoType)type;

- (BOOL)containsObject:(id)obj forType:(JDGImagePickerPhotoType)type;

- (void)reset:(NSArray<JDGImagePickerPhoto *> *)photos;

- (void)push:(JDGImagePickerPhoto *)photo;

- (void)pushPhoto:(JDGImagePickerPhoto *)photo atIndex:(NSUInteger)photoIndex;

- (void)pushPhotosInArray:(NSArray<JDGImagePickerPhoto *> *)photos;

- (void)pop:(JDGImagePickerPhoto *)photo;

- (void)popPhotoAtIndex:(NSUInteger)photoIndex;

- (void)popPhotosInArray:(NSArray<JDGImagePickerPhoto *> *)photos;

- (void)insertItem:(JDGImagePickerPhoto *)source beforeDestination:(JDGImagePickerPhoto *)destination;

@end

NS_ASSUME_NONNULL_END
