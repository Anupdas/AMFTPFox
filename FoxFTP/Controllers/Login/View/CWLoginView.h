//
//  CWLoginView.h
//  FoxFTP
//
//  Created by Anoop Mohandas on 27/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWLoginView : UIView

@property (nonatomic, strong) UITextField *hostTextField;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;

@property (nonatomic, strong) UISwitch *saveSwitch;
@property (nonatomic, strong) UIButton *loginButton;

- (BOOL)validate:(NSError **)error;

@end
