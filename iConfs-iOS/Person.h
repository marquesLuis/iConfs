//
//  Person.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 01/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *affiliation;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *biography;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *calendar_version;
@property (nonatomic, strong) NSString *photo;



@end
