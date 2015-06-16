//
//  COOFormatterTextFieldDelegate.m
//  ios-receipt-scan-example
//
//  Version 0.0.1
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Paulo Miguel Almeida Rodenas <paulo.ubuntu@gmail.com>
//
//  Get the latest version from here:
//
//  https://github.com/nfscan/ios-receipt-scan-example
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "COOFormatterTextFieldDelegate.h"

@implementation COOFormatterTextFieldDelegate

/**
 *  Format input text to COO format even though it's
 *  just a parcial value yet.
 *
 *  @param textField text field reference
 */
-(void)reformat:(UITextField *)textField
{
    
    if ([textField.text isEqualToString:@""]) {
        textField.layer.cornerRadius=6.0f;
        textField.layer.masksToBounds=YES;
        textField.layer.borderColor=[[UIColor redColor]CGColor];
        textField.layer.borderWidth= 1.0f;
        
        textField.textColor = [UIColor redColor];
    }
    else
    {
        textField.textColor = [UIColor blackColor];
        textField.layer.borderColor=[[UIColor clearColor]CGColor];
    }
    
}

/**
 *  Asks the delegate if editing should stop in the specified
 *  text field.
 *
 *  The text field calls this method whenever the user types
 *  new character in the text field or deletes an existing
 *  character.
 *
 *  @param textField The text field containing the text.
 *  @param range     The range of characters to be replaced.
 *  @param string    The replacement string.
 *
 *  @return YES if the specified text range should be replaced; otherwise, NO to keep the old text.
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 6;
}

@end
