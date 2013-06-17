//
//  Note.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 17/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Note : NSObject

@property (nonatomic, strong) NSString * noteID;
@property  BOOL isLocal;
@property (nonatomic, strong) NSString * content;

@end
