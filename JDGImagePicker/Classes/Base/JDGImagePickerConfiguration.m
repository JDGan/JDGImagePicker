//
//  JDGImagePickerConfiguration.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/8/28.
//

#import "JDGImagePickerConfiguration.h"

@interface JDGImagePickerConfiguration ()
@property (nonatomic, assign) UIDeviceOrientation previousOrientation;
@end

static id _instance = nil;
@implementation JDGImagePickerConfiguration

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
        self.mainColor = [UIColor colorWithRed:0.09 green:0.11 blue:0.13 alpha:1];
        self.cameraButtonColor = UIColor.whiteColor;
        self.cameraButtonHighlightedColor = UIColor.grayColor;
        self.cameraButtonTitleColor = UIColor.grayColor;
        self.cameraButtonTitleFont = [UIFont systemFontOfSize:16];
        self.flashAutoColor = [UIColor greenColor];
        self.flashOnColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.45 alpha:1];
        self.flashOffColor = [UIColor grayColor];
        
        self.maskViewBackgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.6];
        
        self.allowVideoSelection = NO;
        self.allowAudioSession = YES;
        self.enableFlashMode = YES;
        self.imageStackCount = 5;
        self.allowedOrientations = @[@(UIDeviceOrientationPortrait),@(UIDeviceOrientationLandscapeLeft),@(UIDeviceOrientationLandscapeRight),@(UIDeviceOrientationPortraitUpsideDown)];
        
        self.imageSize = UIScreen.mainScreen.bounds.size;
        self.imageDeliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        self.libraryItemMaxCountForLine = 4;
        self.libraryItemGap = 4;
        self.libraryLiteItemGap = 4;
        self.libraryLiteHeightMax = 200;
        self.libraryLiteHeightMin = 144;
        self.libraryLiteVelocityBoundary = 100;
        self.libraryLiteHeaderHeight = 24;
        
        self.errorDomain = @"JDGImagePicker";
        self.errorPermissionDenied = @"Permission denied";
        self.errorImageNotFound = @"Image not found";
        self.cameraUnavailableTitle = @"Camera is not available";
        self.goSettingsButtonTitle = @"Go settings";
        self.cancelButtonTitle = @"Cancel";
        self.doneButtonTitle = @"Done";
        self.libraryViewTitle = @"Album";
        self.selectedViewTitle = @"Selected";
        self.previewViewTitle = @"Preview";
    }
    return self;
}

- (CGAffineTransform)rotationTransform {
    UIDeviceOrientation current = UIDevice.currentDevice.orientation;
    if (![self.allowedOrientations containsObject:@(current)]) {
        if(self.previousOrientation == UIDeviceOrientationUnknown) {
            self.previousOrientation = [self.allowedOrientations.firstObject intValue];
        }
    } else {
        switch (current) {
            case UIDeviceOrientationPortrait:
            case UIDeviceOrientationPortraitUpsideDown:
            case UIDeviceOrientationLandscapeLeft:
            case UIDeviceOrientationLandscapeRight:
            {
                self.previousOrientation = current;
            }
                break;
            default:
                break;
        }
    }
    switch (self.previousOrientation) {
        case UIDeviceOrientationLandscapeLeft:
        {
            return CGAffineTransformMakeRotation(M_PI * 0.5);
        }
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            return CGAffineTransformMakeRotation(-M_PI * 0.5);
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
        {
            return CGAffineTransformMakeRotation(M_PI);
        }
            break;
        default:
        {
            return CGAffineTransformIdentity;
        }
            break;
    }
}

@end
