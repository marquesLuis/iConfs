//
//  MapViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 09/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "Local.h"

@interface MapViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

//@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) IBOutlet UIImageView *map;

@end
