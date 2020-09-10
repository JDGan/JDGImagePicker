//
//  JDGAssetManager.h
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/28.
//

#import <Foundation/Foundation.h>
#import <JDGImagePicker/JDGImagePickerDefines.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface JDGAssetManager : NSObject <JDGSingletonProtocol>

@property (nonatomic, retain, readonly) NSMutableArray<PHAsset *> *libraryAssets;

- (void)setupIfNeeded:(JDGCompletionBlock)completion;

- (nullable UIImage *)getImageForName:(NSString *)name;

- (void)fetchAssetsCompletion:(JDGAssetResultBlock _Nullable)completion;

- (void)asyncResolveAsset:(PHAsset *)asset
                     size:(CGSize)size
             deliveryMode:(PHImageRequestOptionsDeliveryMode)mode
               completion:(JDGImagesResultBlock)completion;

- (NSArray<UIImage *> *)resolveAssets:(NSArray<PHAsset *> *)assets;

@end

NS_ASSUME_NONNULL_END
