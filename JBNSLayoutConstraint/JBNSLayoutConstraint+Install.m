//
//  JBNSLayoutConstraint+Install.m
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

#import "JBNSLayoutConstraint+Install.h"
#import "JBNSLayoutConstraint+LinearEquation.h"

@implementation NSLayoutConstraint (JBLayoutConstraintInstallAdditions)

#pragma mark - Class methods

+ (void)jb_installConstraintsWithVisualFormat:(NSString *)visualFormat
                                      options:(NSLayoutFormatOptions)options
                                      metrics:(NSDictionary *)metrics
                                        views:(NSDictionary *)views {
    
    [NSLayoutConstraint jb_installConstraints:
     [NSLayoutConstraint jb_constraintsWithVisualFormat:visualFormat
                                                options:options
                                                metrics:metrics
                                                  views:views]];
}

+ (void)jb_installConstraints:(NSArray *)constraints {
    
    NSParameterAssert([constraints isKindOfClass:[NSArray class]]);
    
    for (NSLayoutConstraint *constraint in constraints) {
        
        [constraint jb_install];
    }
}

+ (void)jb_uninstallConstraints:(NSArray *)constraints {
    
    NSParameterAssert([constraints isKindOfClass:[NSArray class]]);
    
    for (NSLayoutConstraint *constraint in constraints) {
        
        [constraint jb_uninstall];
    }
}

#pragma mark - Instance methods

- (void)jb_install {
    
    UIView *commonAncestor = [self jb_commonAncestor];
    NSAssert(commonAncestor, @"Items do not share a common ancestor");
    
    ((UIView *)self.firstItem).translatesAutoresizingMaskIntoConstraints = NO;
    ((UIView *)self.secondItem).translatesAutoresizingMaskIntoConstraints = NO;
    
    [commonAncestor addConstraint:self];
}

- (void)jb_uninstall {
    
    UIView *currentView = self.firstItem;
    
    do {
        
        if ([currentView.constraints containsObject:self]) {
            
            [currentView removeConstraint:self];
            break;
        } else {
            
            currentView = currentView.superview;
        }
    } while (currentView);
}

- (UIView *)jb_commonAncestor {
    
    __block UIView *commonAncestor = nil;
    
    if (!self.secondItem ||
        self.firstItem == self.secondItem) {
        
        commonAncestor = self.firstItem;
        
    } else if (((UIView *)self.firstItem).superview == ((UIView *)self.secondItem).superview) {
        
        commonAncestor = ((UIView *)self.firstItem).superview;
        
    } else {
        
        NSArray *firstItemSuperviews = [self jb_superviewsForView:self.firstItem];
        NSArray *secondItemSuperviews = [self jb_superviewsForView:self.secondItem];
        [firstItemSuperviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

            if ([secondItemSuperviews containsObject:obj]) {
                
                commonAncestor = obj;
                *stop = YES;
            }
        }];
    }
    
    return commonAncestor;
}

- (NSArray *)jb_superviewsForView:(UIView *)view {
    
    NSMutableArray *superviews = [NSMutableArray array];
    
    // Be sure to include the original view
    UIView *currentView = view;
    
    do {
        
        [superviews addObject:currentView];
        currentView = currentView.superview;
        
    } while (currentView);
    
    return [NSArray arrayWithArray:superviews];
}

@end
