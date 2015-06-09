//
//  CNPJFormatterTextFieldDelegate.m
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

#import "CNPJFormatterTextFieldDelegate.h"

@interface CNPJFormatterTextFieldDelegate()

@property(strong,nonatomic) NSString *previousTextFieldContent;
@property(strong,nonatomic) UITextRange *previousSelection;

@end

@implementation CNPJFormatterTextFieldDelegate

// Version 1.2
// Source and explanation: http://stackoverflow.com/a/19161529/1709587
-(void)reformat:(UITextField *)textField
{
    // In order to make the cursor end up positioned correctly, we need to
    // explicitly reposition it after we inject spaces into the text.
    // targetCursorPosition keeps track of where the cursor needs to end up as
    // we modify the string, and at the end we set the cursor position to it.
    NSUInteger targetCursorPosition = [textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.selectedTextRange.start];
    
    NSString *cnpjNumberWithoutSpaces = [self removeNonDigits:textField.text andPreserveCursorPosition:&targetCursorPosition];
    
    if ([cnpjNumberWithoutSpaces length] > 14) {
        [textField setText:self.previousTextFieldContent];
        textField.selectedTextRange = self.previousSelection;
        return;
    }
    
    NSString *cnpjNumberWithSpaces =
    [self insertFormattingIntoString:cnpjNumberWithoutSpaces andPreserveCursorPosition:&targetCursorPosition];
    
    textField.text = cnpjNumberWithSpaces;
    UITextPosition *targetPosition = [textField positionFromPosition:[textField beginningOfDocument] offset:targetCursorPosition];
    
    [textField setSelectedTextRange: [textField textRangeFromPosition:targetPosition toPosition:targetPosition]];
    
    if ([cnpjNumberWithoutSpaces isEqualToString:@""]) {
        textField.layer.cornerRadius=6.0f;
        textField.layer.masksToBounds=YES;
        textField.layer.borderColor=[[UIColor redColor]CGColor];
        textField.layer.borderWidth= 1.0f;
    }
    else if (![self validarCNPJ:cnpjNumberWithoutSpaces])
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

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Note textField's current state before performing the change, in case
    // reformatTextField wants to revert it
    self.previousTextFieldContent = textField.text;
    self.previousSelection = textField.selectedTextRange;
    
    return YES;
}

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


- (NSString *)insertFormattingIntoString:(NSString *)string
                          andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    for (NSUInteger i=0; i<[string length]; i++) {
        if (i == 2 || i == 5) {
            [stringWithAddedSpaces appendString:@"."];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition)++;
            }
        }else if (i == 8) {
            [stringWithAddedSpaces appendString:@"/"];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition)++;
            }
        }else if (i == 12) {
            [stringWithAddedSpaces appendString:@"-"];
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

-(BOOL)validarCNPJ:(NSString *)cnpj {
    
    int retornoVerificarComuns = [self verificarComunsCNPJ:cnpj];
    
    if(retornoVerificarComuns == 0)
    {
        BOOL retornoValidarDigitos = [self validarDigitosCNPJ:cnpj];
        return retornoValidarDigitos ;
    }
    else
    {
        return NO;
    }
}

-(BOOL)validarDigitosCNPJ:(NSString *)cnpj {
    
    NSInteger soma = 0;
    NSInteger peso;
    NSInteger digito_verificador_13 = [[cnpj substringWithRange:NSMakeRange(12, 1)] integerValue];
    NSInteger digito_verificador_14 = [[cnpj substringWithRange:NSMakeRange(13, 1)] integerValue];
    NSInteger digito_verificador_13_correto;
    NSInteger digito_verificador_14_correto;
    
    //Verificação 13 Digito
    peso=2;
    for (int i=11; i>=0; i--) {
        
        soma = soma + ( [[cnpj substringWithRange:NSMakeRange(i, 1)] integerValue] * peso);
        
        peso = peso+1;
        
        if (peso == 10) {
            peso = 2;
        }
    }
    
    if (soma % 11 == 0 || soma % 11 == 1) {
        digito_verificador_13_correto = 0;
    }
    else{
        digito_verificador_13_correto = 11 - soma % 11;
    }
    
    //Verificação 14 Digito
    soma=0;
    peso=2;
    for (int i=12; i>=0; i--) {
        
        soma = soma + ( [[cnpj substringWithRange:NSMakeRange(i, 1)] integerValue] * peso);
        
        peso = peso+1;
        
        if (peso == 10) {
            peso = 2;
        }
    }
    
    if (soma % 11 == 0 || soma % 11 == 1) {
        digito_verificador_14_correto = 0;
    }
    else{
        digito_verificador_14_correto = 11 - soma % 11;
    }
    
    //Retorno
    if (digito_verificador_13_correto == digito_verificador_13 && digito_verificador_14_correto == digito_verificador_14) {
        return YES;
    }
    else{
        return NO;
    }
    
}

-(int)verificarComunsCNPJ:(NSString *)cnpj {
    /*
     0 - Validado
     1 - Não possui 14 digitos
     2 - CNPJ não permitido: Sequencia de números
     */
    if ([cnpj length] != 14 || [cnpj isEqualToString:@""]) {
        return 1;
    } else if (   [cnpj isEqualToString:@"00000000000000"]
               || [cnpj isEqualToString:@"11111111111111"]
               || [cnpj isEqualToString:@"22222222222222"]
               || [cnpj isEqualToString:@"33333333333333"]
               || [cnpj isEqualToString:@"44444444444444"]
               || [cnpj isEqualToString:@"55555555555555"]
               || [cnpj isEqualToString:@"66666666666666"]
               || [cnpj isEqualToString:@"77777777777777"]
               || [cnpj isEqualToString:@"88888888888888"]
               || [cnpj isEqualToString:@"99999999999999"]){
        return 2;
    }
    else{
        return 0;
    }
}

@end
