//
//  JBViewController.m
//  JBNSLayoutConstraint
//
//  Created by Mike Swanson on 10/7/13.
//  Copyright (c) 2013 Juicy Bits. All rights reserved.
//

#import "JBViewController.h"
#import "JBNSLayoutConstraint+LinearEquation.h"
#import "JBNSLayoutConstraint+Install.h"
#import <QuartzCore/QuartzCore.h>

@interface JBViewController ()

@property (nonatomic, readwrite, strong)    UIView                  *containerView;
@property (nonatomic, readwrite, strong)    UITextView              *textView;
@property (nonatomic, readwrite, strong)    UIButton                *clearButton;
@property (nonatomic, readwrite, strong)    UIButton                *updateButton;
@property (nonatomic, readwrite, strong)    NSDictionary            *metrics;
@property (nonatomic, readwrite, strong)    NSMutableDictionary     *views;

@end

@implementation JBViewController

#pragma mark - View management

- (void)viewDidLoad {
    
    [super viewDidLoad];
 
    self.view.backgroundColor = [UIColor colorWithRed:(185.0f / 255.0f)
                                                green:(188.0f / 255.0f)
                                                 blue:(192.0f / 255.0f)
                                                alpha:1.0f];
    
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor colorWithWhite:0.99f alpha:1.0f];
    [self.view addSubview:self.containerView];
    
    self.textView = [[UITextView alloc] init];
    self.textView.backgroundColor = [UIColor colorWithWhite:0.99f alpha:1.0f];
    self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textView.spellCheckingType = UITextSpellCheckingTypeNo;
    self.textView.font = [UIFont fontWithName:@"CourierNewPSMT" size:11.0f];
    [self.view addSubview:self.textView];
    
    self.clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.clearButton.backgroundColor = [UIColor colorWithWhite:0.99f alpha:1.0f];
    [self.clearButton addTarget:self action:@selector(clearButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    [self.view addSubview:self.clearButton];
    
    self.updateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.updateButton.backgroundColor = [UIColor colorWithWhite:0.99f alpha:1.0f];
    [self.updateButton addTarget:self action:@selector(updateButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.updateButton setTitle:@"Update" forState:UIControlStateNormal];
    [self.view addSubview:self.updateButton];

    [NSLayoutConstraint jb_installConstraintsWithVisualFormat:@"H:|-10-[containerView]-10-|"
                                                              ";H:|-10-[textView]-10-|"
                                                              ";H:|-10-[clearButton]-10-[updateButton(==clearButton)]-10-|"
                                                              ";V:[topLayoutGuide]-2-[containerView(190)]-10-[textView(80)]-10-[clearButton]"
                                                              ";updateButton.centerY==clearButton"
                                                      options:0
                                                      metrics:nil
                                                        views:@{ @"topLayoutGuide" : self.topLayoutGuide,
                                                                 @"containerView"  : self.containerView,
                                                                 @"textView"       : self.textView,
                                                                 @"clearButton"    : self.clearButton,
                                                                 @"updateButton"   : self.updateButton }];
    
    // Some test metrics
    self.metrics = @{ @"metric1" : @(20.0f),
                      @"metric2" : @(50.0f),
                      @"metric3" : @(100.0f) };

    // Add some test views
    self.views = [NSMutableDictionary dictionary];
    NSUInteger totalViews = 3;
    for (NSUInteger index = 0; index < totalViews; index++) {
        
        NSString *viewKey = [NSString stringWithFormat:@"view%u", (index + 1)];
        
        UIView *view = [self viewWithTitle:viewKey];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        
        CGFloat hue = ((CGFloat)index / (CGFloat)totalViews);
        view.backgroundColor = [UIColor colorWithHue:hue
                                          saturation:1.0f
                                          brightness:0.5f
                                               alpha:1.0f];
        [self.containerView addSubview:view];
        
        [self.views setObject:view forKey:viewKey];
    }
    
    // Set initial constraints
    self.textView.text = @"H:|[view1(50)];V:|[view1(50)];\n"
                          "view2.center==|;view2.size==view1*2;\n"
                          "view3.width==view1.width*1.5;view3.height==metric1;view3.left==view2.right;view3.top==view2.bottom+5";
    
    [self updateConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

- (UIView *)viewWithTitle:(NSString *)title {
    
    UIView *view = [[UIView alloc] init];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:11.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.text = title;
    
    [view addSubview:label];
    
    [NSLayoutConstraint jb_installConstraintsWithVisualFormat:@"label.frame==|"
                                                      options:0
                                                      metrics:nil
                                                        views:@{ @"label" : label }];
    
    return view;
}

- (void)updateAmbiguousLayoutStatus {
    
    [self.views enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        UIView *view = (UIView *)obj;
        view.layer.borderColor = (view.hasAmbiguousLayout ?
                                  [UIColor redColor].CGColor :
                                  [UIColor greenColor].CGColor);
        view.layer.borderWidth = 1.0f;
    }];
}

#pragma mark - Interaction

- (void)clearButtonTouched:(UIButton *)sender {
    
    self.textView.text = @"";
}

- (void)updateButtonTouched:(UIButton *)sender {
    
    [self updateConstraints];
}

#pragma mark - Constraint helpers

- (void)updateConstraints {
    
    NSArray *newConstraints = nil;
    
    @try {
        
        newConstraints = [NSLayoutConstraint jb_constraintsWithVisualFormat:self.textView.text
                                                                    options:0
                                                                    metrics:self.metrics
                                                                      views:self.views];
        
        // Remove existing constraints for referenced views
        [self removeConstraintsFromView:self.containerView
                  forItemsInConstraints:newConstraints];
        
        // Add new constraints
        [self.containerView addConstraints:newConstraints];
        
        [self updateAmbiguousLayoutStatus];
    }
    @catch (NSException *exception) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Exception"
                                                            message:exception.description
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Continue", nil];
        [alertView show];
    }
    @finally {
        
        // Nothing to do
    }
}

- (void)removeConstraintsFromView:(UIView *)view forItemsInConstraints:(NSArray *)constraints {

    NSMutableSet *constrainedViews = [NSMutableSet set];
    for (NSLayoutConstraint *constraint in constraints) {
        
        if (![constrainedViews containsObject:constraint.firstItem]) {
            
            [constrainedViews addObject:constraint.firstItem];
        }
    }
    
    NSMutableArray *constraintsToRemove = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in view.constraints) {
        
        if ([constrainedViews containsObject:constraint.firstItem]) {
            
            [constraintsToRemove addObject:constraint];
        }
    }

    [view removeConstraints:constraintsToRemove];
}

@end