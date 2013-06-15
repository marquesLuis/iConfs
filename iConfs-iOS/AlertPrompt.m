#import "AlertPrompt.h"

@implementation AlertPrompt
 @synthesize textView;
 @synthesize enteredText;
 
 - (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
 {
 
 if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])
 {
     NSLog(@"init alertview");
 UITextView *theTextField = [[UITextView alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 200.0)];
 [theTextField setBackgroundColor:[UIColor whiteColor]];
 [self addSubview:theTextField];
 self.textView = theTextField;
     
     
 // CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 130.0);
 //[self setTransform:translate];
 }
 return self;
 }
 
 
 
 - (void)show
 {
     [textView becomeFirstResponder];
     [super show];
 }
 - (NSString *)enteredText
 {
     return textView.text;
 }

@end
