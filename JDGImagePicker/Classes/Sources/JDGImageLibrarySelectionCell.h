//
//  JDGImageLibrarySelectionCell.h
//  JDGImagePicker
//
//  Created by JDGan on 2020/9/3.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface JDGImageLibrarySelectionCell : UICollectionViewCell

@property (weak, nonatomic) PHAsset *asset;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;

- (void)customizeWithData:(PHAsset *)asset isSelected:(BOOL)isSelected;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
