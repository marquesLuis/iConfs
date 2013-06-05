//
//  NetworkingViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 01/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "sqlite3.h"
#import "Networking.h"

@interface NetworkingViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *personName;
@property (strong, nonatomic) IBOutlet UILabel *networkingTitle;
@property (strong, nonatomic) NSString * netTitle;
@property (strong, nonatomic) NSString * namePerson;
@property (strong, nonatomic) NSString * networkingDescriptionContent;
@property (strong, nonatomic) NSString * photoPath;
@property (strong, nonatomic) NSString * personId;
@property (strong, nonatomic) NSString * networkingId;
@property (strong, nonatomic) IBOutlet UITextView *networkingDescription;
@property (strong, nonatomic) IBOutlet UIImageView *personPhoto;
@property int numNetworking;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

//- (IBAction)goToPersonProfile:(UIButton *)sender;
- (IBAction)goToPersonProfile:(UIButton *)sender;

@end
