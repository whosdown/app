//
//  WDViewController.m
//  app
//
//  Created by Joseph Schaffer on 1/19/14.
//  Copyright (c) 2014 Who's Down. All rights reserved.
//

#import "WDViewController.h"

@interface WDViewController ()

@property UITextView *canvas;

@end

@implementation WDViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _canvas = [[UITextView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.canvas];
    
    CGRect canvasFrame = CGRectMake(self.canvas.frame.origin.x,
                                    self.canvas.frame.origin.y + [UIApplication sharedApplication].statusBarFrame.size.height,
                                    self.canvas.frame.size.width,
                                    self.canvas.frame.size.height);
    self.canvas.frame = canvasFrame;
    self.canvas.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22];
    
    [self.canvas becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
