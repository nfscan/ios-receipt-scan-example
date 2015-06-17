//
//  DateFormatterTextFieldDelegate.m
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

#import "DateFormatterTextFieldDelegate.h"

@interface DateFormatterTextFieldDelegate()

@property(strong,nonatomic) NSString *previousTextFieldContent;
@property(strong,nonatomic) UITextRange *previousSelection;

@end

@implementation DateFormatterTextFieldDelegate


// Version 1.2
// Source and explanation: http://stackoverflow.com/a/19161529/1709587
/**
 *  Format input text to date format even though it's
 *  just a parcial value yet.
 *
 *  @param textField text field reference
 */
-(void)reformat:(UITextField *)textField
{
    // In order to make the cursor end up positioned correctly, we need to
    // explicitly reposition it after we inject spaces into the text.
    // targetCursorPosition keeps track of where the cursor needs to end up as
    // we modify the string, and at the end we set the cursor position to it.
    NSUInteger targetCursorPosition =
    [textField offsetFromPosition:textField.beginningOfDocument
                       toPosition:textField.selectedTextRange.start];
    
    NSString *dateWithoutSpaces = [self removeNonDigits:textField.text andPreserveCursorPosition:&targetCursorPosition];
    
    if ([dateWithoutSpaces length] > 8) {
        [textField setText:self.previousTextFieldContent];
        textField.selectedTextRange = self.previousSelection;
        return;
    }
    
    NSString *dateNumberWithSpaces = [self insertFormattingIntoString:dateWithoutSpaces andPreserveCursorPosition:&targetCursorPosition];
    
    textField.text = dateNumberWithSpaces;
    UITextPosition *targetPosition =
    [textField positionFromPosition:[textField beginningOfDocument]
                             offset:targetCursorPosition];
    
    [textField setSelectedTextRange:
     [textField textRangeFromPosition:targetPosition
                           toPosition:targetPosition]
     ];
    
    
    if ([dateWithoutSpaces isEqualToString:@""]) {
        textField.layer.cornerRadius=6.0f;
        textField.layer.masksToBounds=YES;
        textField.layer.borderColor=[[UIColor redColor]CGColor];
        textField.layer.borderWidth= 1.0f;
        
        textField.textColor = [UIColor redColor];
    }
    else if (![self validateDate:dateWithoutSpaces])
    {
        textField.textColor = [UIColor redColor];
        textField.layer.borderColor=[[UIColor clearColor]CGColor];
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
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Note textField's current state before performing the change, in case
    // reformatTextField wants to revert it
    self.previousTextFieldContent = textField.text;
    self.previousSelection = textField.selectedTextRange;
    
    return YES;
}

/**
 *  Remove characters that aren't digits and update the
 *  instance cursor position
 *
 *  @param string         NSString text you want to
 *  @param cursorPosition cursor position pointer
 *
 *  @return A NSString containing digits only
 */
- (NSString *)removeNonDigits:(NSString *)string
    andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSUInteger originalCursorPosition = *cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    for (NSUInteger i=0; i<[string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        if (isdigit(characterToAdd)) {
            NSString *stringToAdd =
            [NSString stringWithCharacters:&characterToAdd
                                    length:1];
            
            [digitsOnlyString appendString:stringToAdd];
        }
        else {
            if (i < originalCursorPosition) {
                (*cursorPosition)--;
            }
        }
    }
    
    return digitsOnlyString;
}

/**
 *  Format it into a date format style
 *
 *  @param string         NSString you want
 *  @param cursorPosition cursor position pointer
 *
 *  @return A NSString containing a formatted date
 */
- (NSString *)insertFormattingIntoString:(NSString *)string
                          andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    for (NSUInteger i=0; i<[string length]; i++) {
        if (i == 2 || i == 4) {
            [stringWithAddedSpaces appendString:@"/"];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition)++;
            }
        }
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd =
        [NSString stringWithCharacters:&characterToAdd length:1];
        
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    
    return stringWithAddedSpaces;
}

/**
 *  Validate whether or not this is a valid date
 *
 *  @param dateStr NSString you want to validate
 *
 *  @return YES if valid or NO otherwise
 */
-(BOOL) validateDate:(NSString*) dateStr
{
    @try {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"ddMMyyyy"];
        NSDate *date = [dateFormat dateFromString:dateStr];
        return  date != nil ;
    }
    @catch (NSException *exception) {
        return NO;
    }
    
}

@end
