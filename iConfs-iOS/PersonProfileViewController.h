//
//  PersonProfileViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 02/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "sqlite3.h"

@interface PersonProfileViewController : UIViewController

@property (strong, nonatomic) NSString * personID;

@end
