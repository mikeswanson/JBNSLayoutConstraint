//
//  JBNSLayoutConstraint+LinearEquation.m
//
//  Created by Mike Swanson on 10/8/13.
//  Copyright (c) 2013 Mike Swanson. All rights reserved.
//  http://blog.mikeswanson.com
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "JBNSLayoutConstraint+LinearEquation.h"

@implementation NSLayoutConstraint (JBLayoutConstraintLinearEquationAdditions)

#pragma mark - Class methods

// Create a constraint of the form "view1.attr1 <relation> view2.attr2 * multiplier + constant @ priority
+ (NSArray *)jb_constraintsWithVisualFormat:(NSString *)visualFormat
                                    options:(NSLayoutFormatOptions)options
                                    metrics:(NSDictionary *)metrics
                                      views:(NSDictionary *)views {
    
    NSAssert(visualFormat &&
             visualFormat.length > 0,
             [NSLayoutConstraint jb_assertMessage:@"Format is an empty string"
                                   withExpression:visualFormat
                                            index:0
                                        showIndex:NO]);

    NSMutableArray *constraints = [NSMutableArray array];
    
    NSArray *expressions = [visualFormat componentsSeparatedByString:@";"];
    
    for (NSString *expression in expressions) {
        
        NSAssert(expression.length > 0,
                 [NSLayoutConstraint jb_assertMessage:@"Expression is an empty string"
                                       withExpression:expression
                                                index:0
                                            showIndex:NO]);

        // Is the expression a visual format?
        NSRange range = [expression rangeOfString:@"["];
        if (range.location != NSNotFound) {
            
            [constraints addObjectsFromArray:
             [NSLayoutConstraint constraintsWithVisualFormat:expression
                                                     options:options
                                                     metrics:metrics
                                                       views:views]];
        } else {

            // Initialize once
            static NSCharacterSet *whitespaceAndNewlineCharacterSet;
            static NSDictionary *attributes;
            static NSArray *compoundAttributes;
            static NSDictionary *relations;
            static NSArray *operators;
            if (!whitespaceAndNewlineCharacterSet) {
                
                whitespaceAndNewlineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                
                attributes = @{ @"naa"        : @(NSLayoutAttributeNotAnAttribute),
                                @"left"       : @(NSLayoutAttributeLeft),
                                @"right"      : @(NSLayoutAttributeRight),
                                @"top"        : @(NSLayoutAttributeTop),
                                @"bottom"     : @(NSLayoutAttributeBottom),
                                @"leading"    : @(NSLayoutAttributeLeading),
                                @"trailing"   : @(NSLayoutAttributeTrailing),
                                @"width"      : @(NSLayoutAttributeWidth),
                                @"height"     : @(NSLayoutAttributeHeight),
                                @"centerX"    : @(NSLayoutAttributeCenterX),
                                @"centerY"    : @(NSLayoutAttributeCenterY),
                                @"baseline"   : @(NSLayoutAttributeBaseline) };
                
                compoundAttributes = @[ @"center",
                                        @"size",
                                        @"frame" ];
                
                relations = @{ @"<="          : @(NSLayoutRelationLessThanOrEqual),
                               @"=="          : @(NSLayoutRelationEqual),
                               @">="          : @(NSLayoutRelationGreaterThanOrEqual) };
                
                operators = @[ @"+",
                               @"-",
                               @"*",
                               @"/",
                               @"@" ];
            }

            id view1 = nil;
            NSString *view1Attribute = nil;
            BOOL view1AttributeIsCompound = NO;
            NSString *relation = nil;
            id view2 = nil;
            NSString *view2Attribute = @"naa";
            BOOL view2AttributeIsCompound = NO;
            NSNumber *multiplierNumber = nil;
            NSNumber *constantNumber = nil;
            NSNumber *layoutPriorityNumber = nil;
            NSNumber *number = nil;
            
            // Clean-up the expression
            NSString *cleanedExpression = [[expression
                                            componentsSeparatedByCharactersInSet:whitespaceAndNewlineCharacterSet]
                                           componentsJoinedByString:@"" ];
            
            // Item 1
            NSUInteger index = 0;
            NSRange terminationRange;
            NSString *component = [NSLayoutConstraint jb_componentInString:cleanedExpression
                                                                 fromIndex:index
                                                terminatedByStringsInArray:@[ @"==",
                                                                              @"<=",
                                                                              @">=" ]
                                                          terminationRange:&terminationRange];
            
            NSAssert(component,
                     [NSLayoutConstraint jb_assertMessage:@"Expected a view"
                                           withExpression:cleanedExpression
                                                    index:0
                                                showIndex:YES]);
            
            NSString *terminationString = (terminationRange.location != NSNotFound ?
                                           [cleanedExpression substringWithRange:terminationRange] :
                                           nil);
            
            relation = terminationString;
            NSAssert(relation,
                     [NSLayoutConstraint jb_assertMessage:@"No valid relation"
                                           withExpression:cleanedExpression
                                                    index:cleanedExpression.length
                                                showIndex:YES]);
            
            NSArray *item1 = [component componentsSeparatedByString:@"."];
            
            NSAssert(item1.count == 2,
                     [NSLayoutConstraint jb_assertMessage:@"Expected an attribute"
                                           withExpression:cleanedExpression
                                                    index:terminationRange.location
                                                showIndex:YES]);
            NSString *view1Key = item1[0];
            view1 = [views objectForKey:view1Key];
            NSAssert(view1,
                     [NSLayoutConstraint jb_assertMessage:([NSString stringWithFormat:@"\"%@\" is not a key in the views dictionary",
                                                            view1Key])
                                           withExpression:cleanedExpression
                                                    index:view1Key.length
                                                showIndex:YES]);
            
            view1Attribute = item1[1];
            view1AttributeIsCompound = [compoundAttributes containsObject:view1Attribute];
            NSAssert([attributes objectForKey:view1Attribute] ||
                     view1AttributeIsCompound,
                     [NSLayoutConstraint jb_assertMessage:([NSString stringWithFormat:@"\"%@\" is not a valid attribute",
                                                            view1Attribute])
                                           withExpression:cleanedExpression
                                                    index:component.length
                                                showIndex:YES]);
            
            // Item 2
            index = terminationRange.location + terminationRange.length;
            component = [NSLayoutConstraint jb_componentInString:cleanedExpression
                                                       fromIndex:index
                                      terminatedByStringsInArray:operators
                                                terminationRange:&terminationRange];
            
            NSAssert(component,
                     [NSLayoutConstraint jb_assertMessage:@"Expected a view"
                                           withExpression:cleanedExpression
                                                    index:cleanedExpression.length
                                                showIndex:YES]);
            
            terminationString = (terminationRange.location != NSNotFound ?
                                 [cleanedExpression substringWithRange:terminationRange] :
                                 nil);
            
            // Is this a constant/metric?
            number = ([NSLayoutConstraint jb_isNumericString:component] ? @([component floatValue]) : nil);
            if (number ||
                [metrics objectForKey:component]) {
                
                NSAssert((view1AttributeIsCompound && [view1Attribute isEqualToString:@"size"]) ||
                         !view1AttributeIsCompound,
                         [NSLayoutConstraint jb_assertMessage:([NSString stringWithFormat:@"\"%@\" cannot be set to a constant",
                                                                view1Attribute])
                                               withExpression:cleanedExpression
                                                        index:terminationRange.location
                                                    showIndex:YES]);
                
                // Constant, so "rewind" a bit and let the metrics logic do its job
                terminationRange.location = index - 1;
                terminationRange.length = 1;
                terminationString = @"+";
                
            } else {
                
                NSArray *item2 = [component componentsSeparatedByString:@"."];
                
                NSAssert(item2.count <= 2,
                         [NSLayoutConstraint jb_assertMessage:@"Too many components"
                                               withExpression:cleanedExpression
                                                        index:terminationRange.location
                                                    showIndex:YES]);
                
                NSString *view2Key = item2[0];
                
                if ([view2Key isEqualToString:@"|"]) {
                    
                    // View 1's superview
                    view2 = ((UIView *)view1).superview;
                }
                else {
                    
                    view2 = [views objectForKey:view2Key];
                    NSAssert(view2,
                             [NSLayoutConstraint jb_assertMessage:([NSString stringWithFormat:@"\"%@\" is not a key in the views dictionary",
                                                                    view2Key])
                                                   withExpression:cleanedExpression
                                                            index:(MIN(cleanedExpression.length, terminationRange.location) -
                                                                   component.length +
                                                                   view2Key.length)
                                                        showIndex:YES]);
                }
                
                view2Attribute = (item2.count < 2 ? view1Attribute : item2[1]);
                view2AttributeIsCompound = [compoundAttributes containsObject:view2Attribute];
                if (view2AttributeIsCompound) {
                    
                    NSAssert([view2Attribute isEqualToString:view1Attribute],
                             [NSLayoutConstraint jb_assertMessage:@"Compound attributes must match"
                                                   withExpression:cleanedExpression
                                                            index:terminationRange.location
                                                        showIndex:YES]);
                }
                else {
                    
                    NSAssert([attributes objectForKey:view2Attribute],
                             [NSLayoutConstraint jb_assertMessage:([NSString stringWithFormat:@"\"%@\" is not a valid attribute",
                                                                    view2Attribute])
                                                   withExpression:cleanedExpression
                                                            index:terminationRange.location
                                                        showIndex:YES]);
                }
                
                if ([view1Attribute isEqualToString:@"frame"]) {
                    
                    NSAssert([relation isEqualToString:@"=="],
                             [NSLayoutConstraint jb_assertMessage:@"The \"frame\" attribute must have an equality relation"
                                                   withExpression:cleanedExpression
                                                            index:terminationRange.location
                                                        showIndex:YES]);
                }
            }
            
            // Metrics
            while (terminationString) {
                
                index = terminationRange.location + terminationRange.length;
                
                if (index < cleanedExpression.length) {
                    
                    component = [NSLayoutConstraint jb_componentInString:cleanedExpression
                                                               fromIndex:index
                                              terminatedByStringsInArray:operators
                                                        terminationRange:&terminationRange];
                } else {
                    
                    component = nil;
                }
                
                NSAssert(component &&
                         component.length > 0,
                         [NSLayoutConstraint jb_assertMessage:@"Expected a value"
                                               withExpression:cleanedExpression
                                                        index:(terminationRange.location + 1)
                                                    showIndex:YES]);
                
                // Is this a number?
                number = ([NSLayoutConstraint jb_isNumericString:component] ? @([component floatValue]) : nil);
                if (!number) {
                    
                    number = [metrics objectForKey:component];
                    
                    NSAssert(number,
                             [NSLayoutConstraint jb_assertMessage:([NSString stringWithFormat:@"\"%@\" is not a key in the metrics dictionary",
                                                                    component])
                                                   withExpression:cleanedExpression
                                                            index:terminationRange.location
                                                        showIndex:YES]);
                }
                
                if ([terminationString isEqualToString:@"+"] ||
                    [terminationString isEqualToString:@"-"]) {

                    NSAssert(!constantNumber,
                             [NSLayoutConstraint jb_assertMessage:@"Only one constant can be specified"
                                                   withExpression:cleanedExpression
                                                            index:terminationRange.location
                                                        showIndex:YES]);
                    
                    constantNumber = @([terminationString isEqualToString:@"+"] ?
                                       [number floatValue] :
                                      -[number floatValue]);
                    
                } else if ([terminationString isEqualToString:@"*"] ||
                           [terminationString isEqualToString:@"/"]) {
                    
                    NSAssert(!multiplierNumber,
                             [NSLayoutConstraint jb_assertMessage:@"Only one multiplier can be specified"
                                                   withExpression:cleanedExpression
                                                            index:terminationRange.location
                                                        showIndex:YES]);
                    
                    multiplierNumber = @([terminationString isEqualToString:@"*"] ?
                                         [number floatValue] :
                                         (1.0f / [number floatValue]));
                    
                } else if ([terminationString isEqualToString:@"@"]) {
                    
                    NSAssert(!layoutPriorityNumber,
                             [NSLayoutConstraint jb_assertMessage:@"Only one layout priority can be specified"
                                                   withExpression:cleanedExpression
                                                            index:terminationRange.location
                                                        showIndex:YES]);
                    
                    layoutPriorityNumber = number;
                }
                
                terminationString = (terminationRange.location != NSNotFound ?
                                     [cleanedExpression substringWithRange:terminationRange] :
                                     nil);
            }
            
            // Build constraints
            NSMutableArray *newConstraints = [NSMutableArray array];
            
            CGFloat constant = (constantNumber ? [constantNumber floatValue] : 0.0f);
            CGFloat multiplier = (multiplierNumber ? [multiplierNumber floatValue] : 1.0f);
            UILayoutPriority layoutPriority = [layoutPriorityNumber floatValue];
            
            if (view1AttributeIsCompound) {
                
                if ([view1Attribute isEqualToString:@"size"]) {
                    
                    [newConstraints addObject:
                     [NSLayoutConstraint constraintWithItem:view1
                                                  attribute:NSLayoutAttributeWidth
                                                  relatedBy:[[relations objectForKey:relation] integerValue]
                                                     toItem:view2
                                                  attribute:([view2Attribute isEqualToString:@"naa"] ?
                                                             NSLayoutAttributeNotAnAttribute :
                                                             ([view2Attribute isEqualToString:@"size"] ?
                                                              NSLayoutAttributeWidth :
                                                              [[attributes objectForKey:view2Attribute] integerValue]))
                                                 multiplier:multiplier
                                                   constant:constant]];
                    
                    [newConstraints addObject:
                     [NSLayoutConstraint constraintWithItem:view1
                                                  attribute:NSLayoutAttributeHeight
                                                  relatedBy:[[relations objectForKey:relation] integerValue]
                                                     toItem:view2
                                                  attribute:([view2Attribute isEqualToString:@"naa"] ?
                                                             NSLayoutAttributeNotAnAttribute :
                                                             ([view2Attribute isEqualToString:@"size"] ?
                                                              NSLayoutAttributeHeight :
                                                              [[attributes objectForKey:view2Attribute] integerValue]))
                                                 multiplier:multiplier
                                                   constant:constant]];
                }
                else if ([view1Attribute isEqualToString:@"center"]) {
                    
                    [newConstraints addObject:
                     [NSLayoutConstraint constraintWithItem:view1
                                                  attribute:NSLayoutAttributeCenterX
                                                  relatedBy:[[relations objectForKey:relation] integerValue]
                                                     toItem:view2
                                                  attribute:([view2Attribute isEqualToString:@"center"] ?
                                                             NSLayoutAttributeCenterX :
                                                             [[attributes objectForKey:view2Attribute] integerValue])
                                                 multiplier:multiplier
                                                   constant:constant]];
                    
                    [newConstraints addObject:
                     [NSLayoutConstraint constraintWithItem:view1
                                                  attribute:NSLayoutAttributeCenterY
                                                  relatedBy:[[relations objectForKey:relation] integerValue]
                                                     toItem:view2
                                                  attribute:([view2Attribute isEqualToString:@"center"] ?
                                                             NSLayoutAttributeCenterY :
                                                             [[attributes objectForKey:view2Attribute] integerValue])
                                                 multiplier:multiplier
                                                   constant:constant]];
                }
                else if ([view1Attribute isEqualToString:@"frame"]) {
                    
                    [newConstraints addObject:
                     [NSLayoutConstraint constraintWithItem:view1
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:[[relations objectForKey:relation] integerValue]
                                                     toItem:view2
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:multiplier
                                                   constant:constant]];
                    
                    [newConstraints addObject:
                     [NSLayoutConstraint constraintWithItem:view1
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:[[relations objectForKey:relation] integerValue]
                                                     toItem:view2
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:multiplier
                                                   constant:constant]];
                    
                    [newConstraints addObject:
                     [NSLayoutConstraint constraintWithItem:view1
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:[[relations objectForKey:relation] integerValue]
                                                     toItem:view2
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:multiplier
                                                   constant:constant]];
                    
                    [newConstraints addObject:
                     [NSLayoutConstraint constraintWithItem:view1
                                                  attribute:NSLayoutAttributeRight
                                                  relatedBy:[[relations objectForKey:relation] integerValue]
                                                     toItem:view2
                                                  attribute:NSLayoutAttributeRight
                                                 multiplier:multiplier
                                                   constant:constant]];
                }
            }
            else {
                
                [newConstraints addObject:
                 [NSLayoutConstraint constraintWithItem:view1
                                              attribute:[[attributes objectForKey:view1Attribute] integerValue]
                                              relatedBy:[[relations objectForKey:relation] integerValue]
                                                 toItem:view2
                                              attribute:[[attributes objectForKey:view2Attribute] integerValue]
                                             multiplier:multiplier
                                               constant:constant]];
            }
            
            if (newConstraints.count > 0) {
                
                if (layoutPriorityNumber) {
                    
                    for (NSLayoutConstraint *constraint in newConstraints) {
                        
                        constraint.priority = layoutPriority;
                    }
                }
                
                [constraints addObjectsFromArray:newConstraints];
            }
        }
    }
    
    return [NSArray arrayWithArray:constraints];
}

// NOTE: Avoiding NSNumberFormatter (too expensive for what we need)
+ (BOOL)jb_isNumericString:(NSString *)string {
    
    BOOL isNumeric = YES;
    
    static NSString *validNumericCharacters = @"0123456789.+-";
    
    for (NSUInteger index = 0; index < string.length; index++) {
        
        isNumeric = [validNumericCharacters rangeOfString:[string substringWithRange:NSMakeRange(index, 1)]].location != NSNotFound;
        if (!isNumeric) {
            
            break;
        }
    }
    
    return isNumeric;
}

+ (NSString *)jb_componentInString:(NSString *)string
                         fromIndex:(NSUInteger)index
        terminatedByStringsInArray:(NSArray *)terminationStrings
                  terminationRange:(NSRange *)terminationRange {
    
    NSAssert(string &&
             string.length > 0, @"String cannot be empty");
    
    NSString *component = nil;
    
    NSRange closestTerminationRange = NSMakeRange(NSNotFound, 0);               // NOTE: NSNotFound == NSIntegerMax
    
    if (index < string.length) {
        
        if ((index + 1) < string.length) {
            
            NSRange searchRange = NSMakeRange((index + 1),                      // Skip the first character (to avoid +/- issues)
                                              (string.length - index - 1));
            
            for (NSString *searchTerminationString in terminationStrings) {
                
                NSRange range = [string rangeOfString:searchTerminationString
                                              options:NSLiteralSearch
                                                range:searchRange];
                
                if (range.location < closestTerminationRange.location) {
                    
                    closestTerminationRange = range;
                }
            }
        }
        
        // If no component, just grab the remainder of the string
        component = (closestTerminationRange.location != NSNotFound ?
                     [string substringWithRange:NSMakeRange(index, (closestTerminationRange.location - index))] :
                     [string substringFromIndex:index]);
    }
    
    if (terminationRange) {
        
        *terminationRange = closestTerminationRange;
    }
    
    return component;
}

+ (NSString *)jb_assertMessage:(NSString *)message
                withExpression:(NSString *)expression
                         index:(NSUInteger)index
                     showIndex:(BOOL)showIndex {
    
    NSMutableString *assertMessage = [NSMutableString stringWithFormat:@"Unable to parse constraint format:%@%@",
                                      (showIndex ? @"\n" : @" "),
                                      message];
    if (showIndex) {
        
        [assertMessage appendString:[NSString stringWithFormat:@"\n%@\n%@^",
                                     expression,
                                     [[NSString string] stringByPaddingToLength:MIN(index, expression.length)
                                                                     withString:@" "
                                                                startingAtIndex:0]]];
    }
    
    return assertMessage;
}

@end
