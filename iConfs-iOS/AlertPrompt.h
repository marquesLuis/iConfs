//
//  AlertPrompt.h
//  iConfs-iOS
//
//  Created by Marta Lidon on 13/06/13.
//  Copyright (c) 2013 FCTUNL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertPrompt : UIAlertView
{
    UITextView *textView;
}
@property (nonatomic, retain) UITextView *textView;
@property (readonly) NSString *enteredText;
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;
@end

/*#import <UIKit/UIKit.h>

@interface AlertPrompt : UIView {
    CGPoint lastTouchLocation;
    CGRect originalFrame;
    BOOL isShown;
}

@property (nonatomic) BOOL isShown;

- (void)show;
- (void)hide;

@end*/
