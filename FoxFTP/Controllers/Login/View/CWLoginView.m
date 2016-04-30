//
//  CWLoginView.m
//  FoxFTP
//
//  Created by Anoop Mohandas on 27/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import "CWLoginView.h"

@interface CWLoginView ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *hostLabel;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *passwordLabel;
@property (nonatomic, strong) UILabel *saveLabel;

@property (nonatomic, strong) NSLayoutConstraint *verticalConstraint;
@property (nonatomic, assign) BOOL didLayoutConstraints;

@end

@implementation CWLoginView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.hostTextField];
        [self.contentView addSubview:self.usernameTextField];
        [self.contentView addSubview:self.passwordTextField];
        [self.contentView addSubview:self.saveSwitch];
        [self.contentView addSubview:self.loginButton];
        [self.contentView addSubview:self.hostLabel];
        [self.contentView addSubview:self.usernameLabel];
        [self.contentView addSubview:self.passwordLabel];
        [self.contentView addSubview:self.saveLabel];

    }return self;
}

- (void)updateConstraints{
    if (!self.didLayoutConstraints) {
        
        [self.contentView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:-30.0f];
        [self.contentView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        
        NSDictionary *metrics = @{@"hPin":@20,@"vPin":@15};
        NSDictionary *views = @{@"title":self.titleLabel,
                                @"serverF":self.hostTextField,
                                @"usernameF":self.usernameTextField,
                                @"passwordF":self.passwordTextField,
                                @"saveS":self.saveSwitch,
                                @"serverL":self.hostLabel,
                                @"usernameL":self.usernameLabel,
                                @"passwordL":self.passwordLabel,
                                @"saveL":self.saveLabel,
                                @"login":self.loginButton};
        
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title(==40)]-vPin-[serverL][serverF]-vPin-[usernameL][usernameF]-vPin-[passwordL][passwordF]-10-[saveS]-10-[login]-vPin-|" options:0 metrics:metrics views:views]];
        
         [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[title]|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hPin-[serverL]-hPin-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hPin-[serverF]-hPin-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hPin-[usernameL]-hPin-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hPin-[usernameF]-hPin-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hPin-[passwordL]-hPin-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hPin-[passwordF]-hPin-|" options:0 metrics:metrics views:views]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hPin-[saveS]-hPin-[saveL]" options:0 metrics:metrics views:views]];
        [self.saveLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.saveSwitch];
        
        [self.loginButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
        
        self.didLayoutConstraints = YES;
    }[super updateConstraints];
}

#pragma mark

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel newAutoLayoutView];
        _titleLabel.text = @"FTP Fox";
        _titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        _titleLabel.backgroundColor = [UIColor lightBlueColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }return _titleLabel;
}

- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [UIView newAutoLayoutView];
        [_contentView autoSetDimension:ALDimensionWidth toSize:300];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 4.0f;
        _contentView.layer.borderWidth = 0.5f;
        _contentView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _contentView.clipsToBounds = YES;
    }return _contentView;
}


- (UITextField *)hostTextField{
    if (!_hostTextField) {
        _hostTextField = [UITextField newAutoLayoutView];
        _hostTextField.borderStyle = UITextBorderStyleRoundedRect;
        _hostTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _hostTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _hostTextField.placeholder = @"Server URL or IP";
        [_hostTextField addTarget:self
                             action:@selector(returnButtonClick:)
                   forControlEvents:UIControlEventEditingDidEndOnExit];
        [_hostTextField addTarget:self
                               action:@selector(textFieldEditingChanged:)
                     forControlEvents:UIControlEventEditingChanged];
    }return _hostTextField;
}

- (UILabel *)hostLabel{
    if (!_hostLabel) {
        _hostLabel = [UILabel newAutoLayoutView];
        _hostLabel.text = @"Server";
    }return _hostLabel;
}

- (UITextField *)usernameTextField{
    if (!_usernameTextField) {
        _usernameTextField = [UITextField newAutoLayoutView];
        _usernameTextField.borderStyle = UITextBorderStyleRoundedRect;
        _usernameTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _usernameTextField.placeholder = @"Enter Username";
        [_usernameTextField addTarget:self
                               action:@selector(returnButtonClick:)
                     forControlEvents:UIControlEventEditingDidEndOnExit];
        [_usernameTextField addTarget:self
                               action:@selector(textFieldEditingChanged:)
                     forControlEvents:UIControlEventEditingChanged];
    }return _usernameTextField;
}

- (UILabel *)usernameLabel{
    if (!_usernameLabel) {
        _usernameLabel = [UILabel newAutoLayoutView];
        _usernameLabel.text = @"Username";
    }return _usernameLabel;
}

- (UITextField *)passwordTextField{
    if (!_passwordTextField) {
        _passwordTextField = [UITextField newAutoLayoutView];
        _passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
        _passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.placeholder = @"Enter Password";
        [_passwordTextField addTarget:self
                               action:@selector(returnButtonClick:)
                     forControlEvents:UIControlEventEditingDidEndOnExit];
        
        [_passwordTextField addTarget:self
                               action:@selector(textFieldEditingChanged:)
                     forControlEvents:UIControlEventEditingChanged];
    }return _passwordTextField;
}

- (UILabel *)passwordLabel{
    if (!_passwordLabel) {
        _passwordLabel = [UILabel newAutoLayoutView];
        _passwordLabel.text = @"Password";
    }return _passwordLabel;
}

- (UISwitch *)saveSwitch{
    if (!_saveSwitch) {
        _saveSwitch = [UISwitch newAutoLayoutView];
    }return _saveSwitch;
}

- (UILabel *)saveLabel{
    if (!_saveLabel) {
        _saveLabel = [UILabel newAutoLayoutView];
        _saveLabel.text = @"Save";
        _saveLabel.font = [UIFont systemFontOfSize:16.0f];
        _saveLabel.textColor = [UIColor grayColor];
    }return _saveLabel;
}

- (UIButton *)loginButton{
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _loginButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_loginButton setTitle:@"Login" forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    }return _loginButton;
}

#pragma mark - 

- (void)returnButtonClick:(UITextField *)textField{
    [textField resignFirstResponder];
}

- (void)textFieldEditingChanged:(UITextField *)textField{
    self.loginButton.enabled = [self validate:NULL];
}

#pragma mark - Keyboard 

#pragma mark - Validation

- (BOOL)validate:(NSError *__autoreleasing *)error{
    BOOL valid = self.hostTextField.text.length &&
                    self.usernameTextField.text.length &&
                        self.passwordTextField.text.length;
    return valid;
}

@end
