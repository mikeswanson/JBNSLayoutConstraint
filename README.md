JBNSLayoutConstraint
====================

By [Mike Swanson](http://blog.mikeswanson.com/)

JBNSLayoutConstraint is a set of categories that adds string-based linear equations and installation assistance to Auto Layout constraints.

JBNSLayoutConstraint+LinearEquation.h makes it easy to create constraints using a string-based linear equation of the following form:

    view1.attr1 == view2.attr2 * multiplier + constant @ priority

Multiple expressions can be passed by separating them with a semicolon, and linear equations can be mixed with NSLayoutConstraint's existing ASCII art-like visual format strings. 

JBNSLayoutConstraint+Install.h adds methods to automatically install (and uninstall) one or more constraints on the closest common ancestor of each constraint's involved views.

There are many NSLayoutConstraint categories out there, but I wanted one that allowed me to easily pass multiple visual format strings to a single method and also allowed me to express constraints using string-based linear equations. Basically, I just wanted to type less code.

## Requirements

The JBNSLayoutConstraint categories have been built and tested for iOS, and they have the same requirements as Auto Layout: iOS 6.0 and later. Also, while these categories may work for Mac development (and NSView) with slight modification, I have not tried this myself.

## JBNSLayoutConstraint+LinearEquation.h

To add string-based linear equation support to a project, simply:

    #import "JBNSLayoutConstraint+LinearEquation.h"

Then, you can replace a traditional NSLayoutConstraint method like this:

    [NSLayoutConstraint
        constraintWithItem:view1
                 attribute:NSLayoutAttributeCenterX
                 relatedBy:NSLayoutRelationEqual
                    toItem:view1.superview
                 attribute:NSLayoutAttributeCenterX
                multiplier:1.0f
                  constant:0.0f];

...with a string-based linear equation:

    [NSLayoutConstraint
        jb_constraintsWithVisualFormat:@"view1.centerX==|.centerX"
                               options:0
                               metrics:nil
                                 views:@{ @"view1" : view1 }];

Like Auto Layout's visual format, the pipe character (`|`) references the view's superview.

While this isolated example isn't much shorter, the true power of the category can be seen when creating multiple constraints:

    [NSLayoutConstraint
        jb_constraintsWithVisualFormat:@"view1.center==|;view1.size==50"
                               options:0
                               metrics:nil
                                 views:@{ @"view1" : view1 }];

This example uses two of the three _compound_ attributes that are included with the category: _center_, _frame_, and _size_. These compound attributes are automatically expanded to include an appropriate set of constraints. In this example, _center_ expands to include attributes for both _centerX_ and _centerY_, and _size_ expands to _width_ and _height_.

Also note that the second _center_ attribute in the first expression has been omitted, because both attributes of the constraint are the same.

As mentioned, linear equations can be mixed with Auto Layout's visual format to pass multiple expression types:

    [NSLayoutConstraint
        jb_constraintsWithVisualFormat:@"H:|[view1(20)];V:|[view1];view1.height==view2+metric1"
                               options:0
                               metrics:@{ @"metric1" : @(42) },
                                 views:@{ @"view1"   : view1,
                                          @"view2"   : view2 }];

## Compound Attributes

The three compound attributes expand to include multiple constraints (in these orders):

* _center_ expands to: _centerX_, _centerY_
* _size_ expands to: _width_, _height_
* _frame_ expands to: _top_, _left_, _bottom_, _right_

## JBNSLayoutConstraint+Install.h

To install and uninstall one or more constraints, first:

    #import "JBNSLayoutConstraint+Install.h"

Then, to install a constraint on the closest common ancestor of its involved views:

    NSLayoutConstraint *constraint = ...;
    [constraint jb_install];
    
Note that this also sets `translatesAutoresizingMaskIntoConstraints` to `NO` for the involved views.

To uninstall a constraint:

	[constraint jb_uninstall];
	
To install multiple constraints, each to the closest common ancestor ot its involved views:

	NSArray *constraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:...];
	[NSLayoutConstraint jb_installConstraints:constraints];

Like `jb_install`, this sets `translatesAutoresizingMaskIntoConstraints` to `NO` for the involved views of each constraint.


Similarly, to uninstall multiple constraints:

	[NSLayoutConstraint jb_uninstallConstraints:constraints];
	
Finally, to generate and install multiple constraints in a single call:

    [NSLayoutConstraint
        jb_installConstraintsWithVisualFormat:@"view1.centerX==|.centerX"
                                      options:0
                                      metrics:nil
                                        views:@{ @"view1" : view1 }];