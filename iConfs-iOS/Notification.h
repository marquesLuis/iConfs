//
//  Notification.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 30/05/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *date;

@end
