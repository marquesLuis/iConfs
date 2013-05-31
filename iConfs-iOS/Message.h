//
//  Message.h
//  iConfs-iOS
//
//  Created by Luis Marques on 5/29/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (nonatomic, strong) NSString *messageText;
@property (nonatomic, strong) NSString *email;

-(BOOL) verifyEmail:(NSString *)email;

@end
