//
//  IConfsViewController.h
//  iConfs-iOS
//
//  Created by Luis Marques on 5/29/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "AESCrypt.h"

@interface IConfsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;


@end
