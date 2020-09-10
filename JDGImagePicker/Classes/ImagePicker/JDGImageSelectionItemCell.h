//
//  JDGImageSelectionItemCell.h
//  JDGImagePicker
//
//  Created by JDGan on 2020/9/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JDGImageSelectionItemCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (copy, nonatomic) void (^ __nullable deleteBlock)(__nullable id);

- (void)customizeWithData:(__nullable id)data;

+ (CGSize)getItemSize;

@end

NS_ASSUME_NONNULL_END
