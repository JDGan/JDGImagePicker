//
//  JDGImageLibraryLiteViewController.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/9/3.
//

#import "JDGImageLibraryLiteViewController.h"
#import "JDGImageLibrarySelectionCell.h"
#import "JDGImagePicker.h"

@interface JDGImageLibraryLiteFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CGAffineTransform transform;

@end

@implementation JDGImageLibraryLiteFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transform = CGAffineTransformIdentity;
    }
    return self;
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attrs = [super layoutAttributesForElementsInRect:rect];
    [attrs enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.transform = self.transform;
    }];
    return attrs;
}

@end

@interface JDGImageLibraryLiteViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *dragIndicatorView;

@property (weak, nonatomic) IBOutlet UIView *noImageView;
@end

@implementation JDGImageLibraryLiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
    self.collectionView.backgroundView = nil;
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.layer.anchorPoint = CGPointZero;
    CGRect screenBounds = UIScreen.mainScreen.bounds;
    self.collectionView.frame = CGRectMake(0, config.libraryLiteHeaderHeight, screenBounds.size.width, config.libraryLiteHeightMin - config.libraryLiteHeaderHeight);
    
    JDGImageLibraryLiteFlowLayout *layout = [[JDGImageLibraryLiteFlowLayout alloc] init];
    CGFloat h = config.libraryLiteHeightMin - config.libraryLiteHeaderHeight;
    layout.itemSize = CGSizeMake(h, h);
    layout.estimatedItemSize = CGSizeMake(h, h);
    layout.minimumLineSpacing = config.libraryLiteItemGap;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.collectionViewLayout = layout;
    
    self.dragIndicatorView.backgroundColor = config.cameraButtonColor;
    self.dragIndicatorView.layer.cornerRadius = self.dragIndicatorView.frame.size.height/2;
    self.dragIndicatorView.layer.masksToBounds = YES;
    
    [JDGAssetManager.shared fetchAssetsCompletion:^(NSArray<PHAsset *> * _Nullable arr, NSError * _Nullable error) {
        dispatch_main_async_jdg_safe(^{
            [self.collectionView reloadData];
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return JDGAssetManager.shared.libraryAssets.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"JDGImageLibrarySelectionCell" forIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)aCell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![aCell isKindOfClass:[JDGImageLibrarySelectionCell class]]) {return;}
    JDGImageLibrarySelectionCell *cell = (JDGImageLibrarySelectionCell *)aCell;
    PHAsset *asset = JDGAssetManager.shared.libraryAssets[indexPath.row];
    BOOL isSelected = [JDGImagePicker.sharedPicker.photoStack containsObject:asset forType:JDGImagePickerPhotoTypePHAsset];
    [cell customizeWithData:asset isSelected:isSelected];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    JDGImageLibrarySelectionCell *cell = (JDGImageLibrarySelectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    JDGImagePickerPhoto *photo = [JDGImagePicker.sharedPicker.photoStack objectForData:cell.asset forType:JDGImagePickerPhotoTypePHAsset];
    BOOL isSelected = photo != nil;
    if (!isSelected) {
        photo = [JDGImagePickerPhoto photoWithPHAsset:JDGAssetManager.shared.libraryAssets[indexPath.row]];
        [JDGImagePicker.sharedPicker.photoStack push:photo];
    } else {
        [JDGImagePicker.sharedPicker.photoStack pop:photo];
    }
    
    [cell setSelected:!isSelected animated:YES];
}

- (void)rotateUIForOrientation:(UIDeviceOrientation)orientation {
    CGAffineTransform transform;
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
        {
            transform = CGAffineTransformMakeRotation(M_PI);
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        {
            transform = CGAffineTransformMakeRotation(M_PI_2);
        }
            break;
        default:
        {
            transform = CGAffineTransformIdentity;
        }
            break;
    }
    JDGImageLibraryLiteFlowLayout *layout = (JDGImageLibraryLiteFlowLayout *)self.collectionView.collectionViewLayout;
    layout.transform = transform;
    [UIView animateWithDuration:0.3 animations:^{
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView layoutIfNeeded];
    }];
}

@end
