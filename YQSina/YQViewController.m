//
//  YQViewController.m
//  YQSina
//
//  Created by niko on 13-6-2.
//  Copyright (c) 2013年 开源强则中国强. All rights reserved.
//

#import "YQViewController.h"
#import "YQVdiskSession.h"

@interface YQViewController ()

@end

@implementation YQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)LoginBtn:(id)sender {
    
    [[YQVdiskSession sharedSession] linkWithSessionType:kVdiskSessionTypeDefault];
    
}
@end
