//
//  JBNSLayoutConstraintTests.m
//  JBNSLayoutConstraintTests
//
//  Created by Mike Swanson on 10/7/13.
//  Copyright (c) 2013 Juicy Bits. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JBNSLayoutConstraint+LinearEquation.h"
#import "JBNSLayoutConstraint+Install.h"

@interface JBNSLayoutConstraintTests : XCTestCase

@property (nonatomic, readwrite, strong)    UIView          *superview;
@property (nonatomic, readwrite, strong)    UIView          *view1;
@property (nonatomic, readwrite, strong)    UIView          *view2;
@property (nonatomic, readwrite, strong)    NSDictionary    *metrics;
@property (nonatomic, readwrite, strong)    NSDictionary    *views;

@end

@implementation JBNSLayoutConstraintTests

- (void)setUp {
    
    [super setUp];
    
    _superview = [[UIView alloc] init];
    _superview.translatesAutoresizingMaskIntoConstraints = NO;
    
    _view1 = [[UIView alloc] init];
    _view1.translatesAutoresizingMaskIntoConstraints = NO;
    [_superview addSubview:_view1];
    
    _view2 = [[UIView alloc] init];
    _view2.translatesAutoresizingMaskIntoConstraints = NO;
    [_superview addSubview:_view2];
    
    _metrics = @{ @"metric1" : @(42.0f) };
    
    _views = @{ @"view1" : _view1,
                @"view2" : _view2 };
}

- (void)tearDown {
    
    [super tearDown];
}

#pragma mark - Test helpers

- (BOOL)isConstraint:(NSLayoutConstraint *)constraint1 equalTo:(NSLayoutConstraint *)constraint2 {
    
    return (constraint1.firstItem == constraint2.firstItem &&
            constraint1.firstAttribute == constraint2.firstAttribute &&
            constraint1.relation == constraint2.relation &&
            constraint1.secondItem == constraint2.secondItem &&
            constraint1.secondAttribute == constraint2.secondAttribute &&
            constraint1.multiplier == constraint2.multiplier &&
            constraint1.constant == constraint2.constant &&
            constraint1.priority == constraint2.priority);
}

#pragma mark - Tests

- (void)testEmptyStrings {
    
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:nil
                                                               options:0
                                                               metrics:nil
                                                                 views:nil], @"Shouldn't allow an empty expression");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@""
                                                               options:0
                                                               metrics:nil
                                                                 views:nil], @"Shouldn't allow an empty expression");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"   "
                                                               options:0
                                                               metrics:nil
                                                                 views:nil], @"Shouldn't allow an empty expression");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@";"
                                                               options:0
                                                               metrics:nil
                                                                 views:nil], @"Shouldn't allow an empty expression");
}

- (void)testWhitespace {
    
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.top == view2.top * 2.0 + 2.0 @100"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Whitespace shouldn't matter");
}

- (void)testVisualFormats {
    
    NSArray *constraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:@"|[view1]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:_views];
    XCTAssertTrue(constraints.count > 0, @"Problem handling visual format");
    
    constraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:@"H:|[view1]|"
                                                             options:0
                                                             metrics:nil
                                                               views:_views];
    XCTAssertTrue(constraints.count > 0, @"Problem handling visual format");
    
    constraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:@"H:|[view1]|;V:|[view1]|"
                                                             options:0
                                                             metrics:nil
                                                               views:_views];
    XCTAssertTrue(constraints.count > 0, @"Problem handling multiple visual formats");
}

- (void)testItem1 {
    
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.top==view2.top"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"First item is valid");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@".top==view2.top"
                                                               options:0
                                                               metrics:nil
                                                                 views:_views], @"First layout item is required");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.top==view2.top"
                                                               options:0
                                                               metrics:nil
                                                                 views:@{ @"view" : _view1 }], @"First layout item key should be in views dictionary");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.==view2.top"
                                                               options:0
                                                               metrics:nil
                                                                 views:_views], @"First layout attribute is required");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.unknown==view2.top"
                                                               options:0
                                                               metrics:nil
                                                                 views:_views], @"First layout attribute should be valid");
}

- (void)testRelations {
    
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.top=<view2.top"
                                                               options:0
                                                               metrics:nil
                                                                 views:_views], @"Less than or equal relation should be '<='");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.top=view2.top"
                                                               options:0
                                                               metrics:nil
                                                                 views:_views], @"Equal relation should be '=='");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.top=>view2.top"
                                                               options:0
                                                               metrics:nil
                                                                 views:_views], @"Greater than or equal relation should be '>='");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.top<=view2.top"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Should allow '<=' relation");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.top==view2.top"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Should allow '==' relation");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.top>=view2.top"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Should allow '>=' relation");
    
    // Validate relation types
    NSArray *constraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.top==view2.top;view1.top<=view2.top;view1.top>=view2.top"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:_views];
    XCTAssertTrue(((NSLayoutConstraint *)constraints[0]).relation == NSLayoutRelationEqual, @"Equal relation doesn't match expression");
    XCTAssertTrue(((NSLayoutConstraint *)constraints[1]).relation == NSLayoutRelationLessThanOrEqual, @"Less than or equal relation doesn't match expression");
    XCTAssertTrue(((NSLayoutConstraint *)constraints[2]).relation == NSLayoutRelationGreaterThanOrEqual, @"Greater than or equal relation doesn't match expression");
}

- (void)testItem2 {
    
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width=="
                                                               options:0
                                                               metrics:nil
                                                                 views:nil], @"Second layout item is required");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.top==.top"
                                                               options:0
                                                               metrics:nil
                                                                 views:_views], @"Second layout item is required");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.top==view2.top"
                                                               options:0
                                                               metrics:nil
                                                                 views:@{ @"view1" : _view1 }], @"Second layout item key should be in views dictionary");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.top==view2"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Second layout attribute is not required");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.top==view2.unknown"
                                                               options:0
                                                               metrics:nil
                                                                 views:_views], @"Second layout attribute should be valid");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.frame==metric"
                                                               options:0
                                                               metrics:_metrics
                                                                 views:_views], @"Constant value should be in metrics dictionary");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==50.0"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Second item can be a constant");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==+50.0"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Second item can be a signed constant");
    
    // Validate decimal constant (make sure it isn't confused with the second attribute)
    NSArray *constraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==50.5"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:_views];
    XCTAssertTrue([self isConstraint:constraints[0] equalTo:[NSLayoutConstraint constraintWithItem:_view1
                                                                                         attribute:NSLayoutAttributeWidth
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:nil
                                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                                        multiplier:1.0f
                                                                                          constant:50.5f]],
                  @"Constraint doesn't match specified constant");
    
}

- (void)testCompoundAttributes {
    
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.center==50.0"
                                                               options:0
                                                               metrics:nil
                                                                 views:_views], @"'center' attribute cannot be set to a constant");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.size==50.0"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"'size' attribute can be set to a constant");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.frame==50.0"
                                                               options:0
                                                               metrics:nil
                                                                 views:_views], @"'frame' attribute cannot be set to a constant");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.frame==view2.size"
                                                               options:0
                                                               metrics:nil
                                                                 views:_views], @"Compound attributes must match");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.frame>=view2.frame"
                                                               options:0
                                                               metrics:nil
                                                                 views:_views], @"'frame' compound attributes must have equality relation");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.frame==|"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"'frame' attribute can be set to its superview");
    
    // Validate 'size' compound attribute
    NSArray *constraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.size==view2.size"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:_views];
    XCTAssertTrue([self isConstraint:constraints[0] equalTo:[NSLayoutConstraint constraintWithItem:_view1
                                                                                         attribute:NSLayoutAttributeWidth
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:_view2
                                                                                         attribute:NSLayoutAttributeWidth
                                                                                        multiplier:1.0f
                                                                                          constant:0.0f]],
                  @"First 'size' compound attribute is invalid");
    XCTAssertTrue([self isConstraint:constraints[1] equalTo:[NSLayoutConstraint constraintWithItem:_view1
                                                                                         attribute:NSLayoutAttributeHeight
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:_view2
                                                                                         attribute:NSLayoutAttributeHeight
                                                                                        multiplier:1.0f
                                                                                          constant:0.0f]],
                  @"Second 'size' compound attribute is invalid");
    
    // Validate 'center' compound attribute
    constraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.center==view2.center"
                                                             options:0
                                                             metrics:nil
                                                               views:_views];
    XCTAssertTrue([self isConstraint:constraints[0] equalTo:[NSLayoutConstraint constraintWithItem:_view1
                                                                                         attribute:NSLayoutAttributeCenterX
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:_view2
                                                                                         attribute:NSLayoutAttributeCenterX
                                                                                        multiplier:1.0f
                                                                                          constant:0.0f]],
                  @"First 'center' compound attribute is invalid");
    XCTAssertTrue([self isConstraint:constraints[1] equalTo:[NSLayoutConstraint constraintWithItem:_view1
                                                                                         attribute:NSLayoutAttributeCenterY
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:_view2
                                                                                         attribute:NSLayoutAttributeCenterY
                                                                                        multiplier:1.0f
                                                                                          constant:0.0f]],
                  @"Second 'center' compound attribute is invalid");
    
    // Validate 'frame' compound attribute
    constraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.frame==view2.frame"
                                                             options:0
                                                             metrics:nil
                                                               views:_views];
    XCTAssertTrue([self isConstraint:constraints[0] equalTo:[NSLayoutConstraint constraintWithItem:_view1
                                                                                         attribute:NSLayoutAttributeTop
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:_view2
                                                                                         attribute:NSLayoutAttributeTop
                                                                                        multiplier:1.0f
                                                                                          constant:0.0f]],
                  @"First 'frame' compound attribute is invalid");
    XCTAssertTrue([self isConstraint:constraints[1] equalTo:[NSLayoutConstraint constraintWithItem:_view1
                                                                                         attribute:NSLayoutAttributeLeft
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:_view2
                                                                                         attribute:NSLayoutAttributeLeft
                                                                                        multiplier:1.0f
                                                                                          constant:0.0f]],
                  @"Second 'frame' compound attribute is invalid");
    XCTAssertTrue([self isConstraint:constraints[2] equalTo:[NSLayoutConstraint constraintWithItem:_view1
                                                                                         attribute:NSLayoutAttributeBottom
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:_view2
                                                                                         attribute:NSLayoutAttributeBottom
                                                                                        multiplier:1.0f
                                                                                          constant:0.0f]],
                  @"Third 'frame' compound attribute is invalid");
    XCTAssertTrue([self isConstraint:constraints[3] equalTo:[NSLayoutConstraint constraintWithItem:_view1
                                                                                         attribute:NSLayoutAttributeRight
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:_view2
                                                                                         attribute:NSLayoutAttributeRight
                                                                                        multiplier:1.0f
                                                                                          constant:0.0f]],
                  @"Fourth 'frame' compound attribute is invalid");
}

- (void)testOperators {
    
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width**2.0"
                                                               options:0
                                                               metrics:nil
                                                                 views:_views], @"'**' is an invalid operator");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width*2.0"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"'*' is a valid operator");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width/2.0"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"'/' is a valid operator");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width+2.0"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"'+' is a valid operator");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width*metric"
                                                               options:0
                                                               metrics:_metrics
                                                                 views:_views], @"First value should be in metrics dictionary");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width*2.0*2.0"
                                                               options:0
                                                               metrics:nil
                                                                 views:_views], @"Operators must be different");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width*2.0+2.0"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Operators must be different");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width*2.0+metric"
                                                               options:0
                                                               metrics:_metrics
                                                                 views:_views], @"Second value should be in metrics dictionary");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width*metric1+metric1"
                                                                options:0
                                                                metrics:_metrics
                                                                  views:_views], @"Metric values should be in metrics dictionary");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width*"
                                                               options:0
                                                               metrics:nil
                                                                 views:nil], @"Operator should not allow missing value");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width*2+"
                                                               options:0
                                                               metrics:nil
                                                                 views:nil], @"Operator should not allow missing value");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width*2+1@"
                                                               options:0
                                                               metrics:nil
                                                                 views:nil], @"Operator should not allow missing value");
    
    // Validate multiplier and constant
    NSArray *constraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width*2.0+3.0"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:_views];
    XCTAssertTrue(((NSLayoutConstraint *)constraints[0]).multiplier == 2.0f, @"Multiplier doesn't match expression");
    XCTAssertTrue(((NSLayoutConstraint *)constraints[0]).constant == 3.0f, @"Constant doesn't match expression");
    
    // Validate division
    constraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width/2.0"
                                                             options:0
                                                             metrics:nil
                                                               views:_views];
    XCTAssertTrue(((NSLayoutConstraint *)constraints[0]).multiplier == (1.0f / 2.0f), @"Multiplier doesn't match expression");
}

- (void)testPriorities {
    
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width@"
                                                               options:0
                                                               metrics:nil
                                                                 views:_views], @"Priority value missing");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2@100"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Valid priority specification");
    XCTAssertThrows([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2@metric"
                                                               options:0
                                                               metrics:_metrics
                                                                 views:_views], @"Metric values should be in metrics dictionary");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width@100"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Valid priority specification");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width*2.0@100"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Valid priority specification");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width+2.0@100"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Valid priority specification");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width*2.0+2.0@100"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Valid priority specification");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width+2.0*2.0@100"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Valid priority specification");

    // Validate priority
    NSArray *constraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width@100"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:_views];
    XCTAssertTrue(((NSLayoutConstraint *)constraints[0]).priority == 100.0f, @"Priority doesn't match expression");
    
    // Validate priority with metric
    constraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2.width@metric1"
                                                             options:0
                                                             metrics:_metrics
                                                               views:_views];
    XCTAssertTrue(((NSLayoutConstraint *)constraints[0]).priority == 42.0f, @"Priority doesn't match expression metric");
    
}

- (void)testNegativeValues {
    
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2-50.5"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Constants can be negative");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==-50.5"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Constants can be negative");
    XCTAssertNoThrow([NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view1*2.5-10"
                                                                options:0
                                                                metrics:nil
                                                                  views:_views], @"Constants can be negative");

    // Validate negative constant
    NSArray *constraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:@"view1.width==view2-50.5"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:_views];
    XCTAssertTrue(((NSLayoutConstraint *)constraints[0]).constant == -50.5f, @"Constraint doesn't match negative constant");
}

- (void)testInstallAndUninstall {
    
    //       Test view hierarchy
    //
    //            [view1]        [view6]
    //            /      \
    //        [view2]  [view3]
    //        /      \
    //    [view4]  [view5]
    
    UIView *view1 = [[UIView alloc] init];
    UIView *view2 = [[UIView alloc] init];
    UIView *view3 = [[UIView alloc] init];
    UIView *view4 = [[UIView alloc] init];
    UIView *view5 = [[UIView alloc] init];
    UIView *view6 = [[UIView alloc] init];
    [view2 addSubview:view4];
    [view2 addSubview:view5];
    [view1 addSubview:view2];
    [view1 addSubview:view3];
    
    NSDictionary *views = @{ @"view1" : view1,
                             @"view2" : view2,
                             @"view3" : view3,
                             @"view4" : view4,
                             @"view5" : view5,
                             @"view6" : view6 };
    
    NSLayoutConstraint *constraint1 =
    [[NSLayoutConstraint jb_constraintsWithVisualFormat:@"view4.width==view6.width"
                                                options:0
                                                metrics:nil
                                                  views:views] firstObject];
    XCTAssertThrows([constraint1 jb_install], @"Shouldn't install constraint without a common ancestor");
    
    NSLayoutConstraint *constraint2 =
    [[NSLayoutConstraint jb_constraintsWithVisualFormat:@"view3.width==view4.width"
                                                options:0
                                                metrics:nil
                                                  views:views] firstObject];
    
    XCTAssertNoThrow([constraint2 jb_install], @"Constraints share a common ancestor");
    XCTAssertTrue([view1.constraints containsObject:constraint2], @"Constraint isn't installed on the common ancestor (view1)");
    XCTAssertTrue(view1.translatesAutoresizingMaskIntoConstraints, @"Shouldn't have disabled autoresizing mask translation on view1");
    XCTAssertTrue(!view3.translatesAutoresizingMaskIntoConstraints, @"Should have disabled autoresizing mask translation on view3");
    XCTAssertTrue(!view4.translatesAutoresizingMaskIntoConstraints, @"Should have disabled autoresizing mask translation on view4");
    
    NSLayoutConstraint *constraint3 =
    [[NSLayoutConstraint jb_constraintsWithVisualFormat:@"view5.width==view5.height"
                                                options:0
                                                metrics:nil
                                                  views:views] firstObject];
    
    XCTAssertNoThrow([constraint3 jb_install], @"Constraints share the same ancestor");
    XCTAssertTrue([view5.constraints containsObject:constraint3], @"Constraint isn't installed on view5");
    XCTAssertTrue(!view5.translatesAutoresizingMaskIntoConstraints, @"Should have disabled autoresizing mask translation on view5");
    
    NSLayoutConstraint *constraint4 =
    [[NSLayoutConstraint jb_constraintsWithVisualFormat:@"view6.width==50"
                                                options:0
                                                metrics:nil
                                                  views:views] firstObject];
    
    XCTAssertNoThrow([constraint4 jb_install], @"Constraint is for a single view");
    XCTAssertTrue([view6.constraints containsObject:constraint4], @"Constraint isn't installed on view6");
    XCTAssertTrue(!view6.translatesAutoresizingMaskIntoConstraints, @"Should have disabled autoresizing mask translation on view6");
    
    // Uninstallation
    XCTAssertNoThrow([constraint1 jb_uninstall], @"Constraint wasn't installed, so nothing should happen on uninstall");
    
    XCTAssertNoThrow([constraint2 jb_uninstall], @"Constraint should uninstall");
    XCTAssertTrue(![view1.constraints containsObject:constraint2], @"Constraint should no longer exist on view1");
    
    XCTAssertNoThrow([constraint3 jb_uninstall], @"Constraint should uninstall");
    XCTAssertTrue(![view5.constraints containsObject:constraint3], @"Constraint should no longer exist on view5");
    
    XCTAssertNoThrow([constraint4 jb_uninstall], @"Constraint should uninstall");
    XCTAssertTrue(![view6.constraints containsObject:constraint4], @"Constraint should no longer exist on view6");
    
    // Group installation
    NSArray *constraints = @[ constraint2,
                              constraint3 ];
    
    XCTAssertThrows([NSLayoutConstraint jb_installConstraints:nil], @"Requires an array");
    XCTAssertNoThrow([NSLayoutConstraint jb_installConstraints:constraints], @"Constraints are valid and should install");
    XCTAssertTrue([view1.constraints containsObject:constraint2], @"Constraint isn't installed on the common ancestor (view1)");
    XCTAssertTrue([view5.constraints containsObject:constraint3], @"Constraint isn't installed on view5");
    
    // Group uninstallation
    XCTAssertThrows([NSLayoutConstraint jb_uninstallConstraints:nil], @"Requires an array");
    XCTAssertNoThrow([NSLayoutConstraint jb_uninstallConstraints:constraints], @"Constraints should uninstall");
    XCTAssertTrue(![view1.constraints containsObject:constraint2], @"Constraint should no longer exist on view1");
    XCTAssertTrue(![view5.constraints containsObject:constraint3], @"Constraint should no longer exist on view5");
}

@end
