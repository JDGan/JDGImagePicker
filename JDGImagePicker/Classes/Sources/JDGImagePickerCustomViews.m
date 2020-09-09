//
//  JDGImagePickerCustomViews.m
//  JDGImagePicker
//
//  Created by JDGan on 2020/9/9.
//

#import "JDGImagePickerCustomViews.h"
#import "JDGImagePicker.h"

@interface JDGImagePickerPrivacyUnavailableView ()

@property (nonatomic, retain) UILabel *descLabel;

@property (nonatomic, retain) UIButton *goSettingsButton;

@end

@implementation JDGImagePickerPrivacyUnavailableView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSubviews];
    }
    return self;
}

- (void)initialSubviews {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    JDGImagePickerConfiguration *config = JDGImagePicker.sharedPicker.configuration;
    UILabel *label = [UILabel new];
    label.font = config.cameraButtonTitleFont;
    label.textColor = UIColor.whiteColor;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = config.errorPermissionDenied;
    [self addSubview:label];
    self.descLabel = label;
    // 处理描述标题的约束对齐方式
    NSMutableArray *layoutConstraints = [NSMutableArray array];
    NSLayoutConstraint *layoutConstraint = [NSLayoutConstraint constraintWithItem:self.descLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [layoutConstraints addObject:layoutConstraint];
    
    layoutConstraint = [NSLayoutConstraint constraintWithItem:self.descLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:24];
    [layoutConstraints addObject:layoutConstraint];
    
    [self addConstraints:layoutConstraints];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:@selector(goSettingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:config.goSettingsButtonTitle forState:UIControlStateNormal];
    [self addSubview:button];
    self.goSettingsButton = button;
    
    layoutConstraints = [NSMutableArray array];
    layoutConstraint = [NSLayoutConstraint constraintWithItem:self.goSettingsButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [layoutConstraints addObject:layoutConstraint];
    
    layoutConstraint = [NSLayoutConstraint constraintWithItem:self.goSettingsButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.descLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:24];
    [layoutConstraints addObject:layoutConstraint];
    [self addConstraints:layoutConstraints];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8;
}

- (void)goSettingsButtonPressed {
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([app canOpenURL:url]) {
        [app openURL:url options:@{} completionHandler:nil];
    }
}

@end
