//
//  WDViewController.m
//  app
//
//  Created by Joseph Schaffer on 1/19/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDViewController.h"

@interface WDViewController ()

@property (nonatomic, strong) UITextView *canvas;

@end

@implementation WDViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }

  return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.canvas];
    
    [self.canvas becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Lazy Initializers

- (UITextView *)canvas {
  if (!_canvas) {
    _canvas = [[UITextView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    CGRect canvasFrame = CGRectMake(self.view.bounds.origin.x,
                                    self.view.bounds.origin.y + [UIApplication sharedApplication].statusBarFrame.size.height,
                                    self.view.bounds.size.width,
                                    self.view.bounds.size.height);
    _canvas.frame = canvasFrame;
    _canvas.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22];
    
    _canvas.returnKeyType = UIReturnKeySend;
    _canvas.delegate = self;
  }
  return _canvas;
  
}

#pragma mark UITextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
  
  if ([text isEqualToString:@"\n"]) {
    return NO;
  }
  
  return YES;
}


@end
