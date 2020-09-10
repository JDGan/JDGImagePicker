//
//  JDGImageSelectionViewController.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/31.
//

#import "JDGImageSelectionViewController.h"
#import "JDGImageSelectionItemCell.h"
#import "JDGImagePicker.h"

@interface JDGImageSelectionViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation JDGImageSelectionViewController

- (CGFloat)itemSide {
    return [JDGImageSelectionItemCell getItemSize].width;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    JDGImagePickerConfiguration *config = JDGImagePickerConfiguration.shared;
    self.title = config.selectedViewTitle;
    
    UILongPressGestureRecognizer *editLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedCollectionViewItem:)];
    [self.collectionView addGestureRecognizer:editLongPressGesture];
}

- (void)longPressedCollectionViewItem:(UILongPressGestureRecognizer *)gesture {
    CGPoint locationPoint = [gesture locationInView:self.collectionView];
    switch(gesture.state) {
    case UIGestureRecognizerStateBegan:
        {
            NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint:locationPoint];
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:selectedIndexPath];
        }
            break;
    case UIGestureRecognizerStateChanged:
        {
            [self.collectionView updateInteractiveMovementTargetPosition:locationPoint];
        }
            break;
    case UIGestureRecognizerStateEnded:
        {
            [self.collectionView endInteractiveMovement];
        }
            break;
    default:
        {
            [self.collectionView cancelInteractiveMovement];
        }
            break;
    }
}

- (JDGImagePickerPhoto *)itemForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger count = JDGImagePicker.shared.photoStack.selectedPhotos.count;
    return JDGImagePicker.shared.photoStack.selectedPhotos[count - indexPath.row - 1];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return JDGImagePicker.shared.photoStack.selectedPhotos.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"JDGImageSelectionItemCell" forIndexPath:indexPath];
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)aCell forItemAtIndexPath:(NSIndexPath *)indexPath {
    JDGImageSelectionItemCell *cell = (JDGImageSelectionItemCell *)aCell;
    JDGImagePickerPhoto *itemData = [self itemForIndexPath:indexPath];
    [cell customizeWithData:itemData];
    cell.deleteBlock = ^(id _Nullable data) {
        if(![data isKindOfClass:[JDGImagePickerPhoto class]]) {return;}
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除" message:@"确认是否要删除该图片?" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:^{
                dispatch_main_async_jdg_safe(^{
                    [collectionView performBatchUpdates:^{
                        [JDGImagePicker.shared.photoStack pop:data];
                        [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                    } completion:^(BOOL finished) {
                        [collectionView reloadData];
                    }];
                });
            }];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    };
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    JDGImagePickerPhoto *photo = [self itemForIndexPath:indexPath];
    
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    JDGImagePickerPhoto *sourcePhoto = [self itemForIndexPath:sourceIndexPath];
    JDGImagePickerPhoto *destinationPhoto = [self itemForIndexPath:destinationIndexPath];
    [JDGImagePicker.shared.photoStack insertItem:sourcePhoto beforeDestination:destinationPhoto];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat h = [self itemSide];
     return CGSizeMake(h, h);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    JDGImagePickerConfiguration *config = JDGImagePickerConfiguration.shared;
    CGFloat sideGap = config.libraryItemGap;
    return UIEdgeInsetsMake(sideGap, sideGap, sideGap, sideGap);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    JDGImagePickerConfiguration *config = JDGImagePickerConfiguration.shared;
    return config.libraryItemGap;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    JDGImagePickerConfiguration *config = JDGImagePickerConfiguration.shared;
    return config.libraryItemGap;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
