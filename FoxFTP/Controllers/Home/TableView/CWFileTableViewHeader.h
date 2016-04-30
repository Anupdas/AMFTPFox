//
//  CWFileTableViewHeader.h
//  FoxFTP
//
//  Created by Anoop Mohandas on 30/04/16.
//  Copyright © 2016 Anoop Mohandas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CWFileTableViewHeader : UITableViewHeaderFooterView

@property (nonatomic, strong) NSString *hostName;
@property (nonatomic, assign) BOOL showProgress;
@property (nonatomic, strong) NSDictionary *progressInfo;

@end
