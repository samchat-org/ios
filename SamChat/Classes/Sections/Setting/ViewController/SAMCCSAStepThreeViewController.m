//
//  SAMCCSAStepThreeViewController.m
//  SamChat
//
//  Created by HJ on 10/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCCSAStepThreeViewController.h"

@interface SAMCCSAStepThreeViewController ()

@property (nonatomic, strong) NSMutableDictionary *samProsInformation;

@end

@implementation SAMCCSAStepThreeViewController

- (instancetype)initWithInformation:(NSMutableDictionary *)information
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _samProsInformation = information;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
