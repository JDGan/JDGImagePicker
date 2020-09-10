//
//  JDGImagePicker.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/28.
//

#import "JDGImagePicker.h"
#import "JDGImagePickerNavigationController.h"

@interface JDGImagePicker ()

@property(nonatomic, retain) JDGImagePickerNavigationController* navigationController;

@property(nonatomic, retain) JDGImageStack *photoStack;

@end

static id _instance = nil;
@implementation JDGImagePicker
+ (instancetype)shared {
    @synchronized (self) {
        if(_instance == nil){
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

+ (void)destroyShared {
    _instance = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.photoStack = [JDGImageStack new];
    }
    return self;
}

- (void)dealloc
{
//    NSLog(@"%@ dealloc", self);
}

@end


@implementation JDGImagePicker (UI)

- (void)presentFromViewController:(UIViewController *)viewCtrl animated:(BOOL)flag completion:(void (^)(void))completion {
    self.navigationController = [JDGImagePickerNavigationController create];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [viewCtrl presentViewController:self.navigationController animated:flag completion:completion];
}

- (void)dismissWithDonePressed:(BOOL)isDonePressed {
    if([self.delegate respondsToSelector:@selector(imagePickerWillDismiss:)]) {
        [self.delegate imagePickerWillDismiss:self];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (isDonePressed) {
            if([self.delegate respondsToSelector:@selector(imagePicker:didFinishWithResultSelection:)]) {
                [self.delegate imagePicker:self didFinishWithResultSelection:self.photoStack];
            }
        } else {
            if([self.delegate respondsToSelector:@selector(imagePickerDidCancel:)]) {
                [self.delegate imagePickerDidCancel:self];
            }
        }
        self.navigationController = nil;
        [[self class] destroyShared];
    }];
}

- (void)dismiss {
    [self dismissWithDonePressed:(self.photoStack.selectedPhotos.count  > 0)];
}

@end
