//
//  JBNSLayoutConstraint+LinearEquation.h
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

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (JBLayoutConstraintLinearEquationAdditions)

#pragma mark - Class methods

/**
 *  Create constraints described by ASCII art-like visual format strings and
 *  text-based linear equations of the following form:
 *
 *  view1.attr1 == view2.attr2 * multiplier + constant @ priority
 *
 *  @param  visualFormat    The format specifications for the constraints.
 *                          Separate multiple expressions with a semicolon.
 *  @param  options         Options describing the attribute and the direction of
 *                          layout for all objects in the visual format string.
 *  @param  metrics         A dictionary of constants that appear in the visual
 *                          format string. The keys must be the string values used
 *                          in the visual format string, and the values must be
 *                          @p NSNumber objects.
 *  @param  views           A dictionary of views that appear in the visual format
 *                          string. The keys must be the string values used in the
 *                          visual format string, and the values must be the view
 *                          objects.
 *
 *  @return                 An array of constraints that, combined, express the constraints
 *                          between the provided views and their parent view as described by
 *                          the visual format string. The constraints are returned in the same
 *                          order they were specified in the visual format string.
 */
+ (NSArray *)jb_constraintsWithVisualFormat:(NSString *)visualFormat
                                    options:(NSLayoutFormatOptions)options
                                    metrics:(NSDictionary *)metrics
                                      views:(NSDictionary *)views;

@end
