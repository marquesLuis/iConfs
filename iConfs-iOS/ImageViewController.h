//
//  ImageViewController.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 13/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "Local.h"
@interface ImageViewController :  UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate>{
	
	UIImageView *imageView;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSString * localID;
@end
