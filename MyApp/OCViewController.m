//
//  OCViewController.m
//  MyApp
//
//  Created by Destiny on 2019/12/11.
//  Copyright © 2019 Destiny. All rights reserved.
//

#import "OCViewController.h"

@interface OCViewController ()

@property (weak, nonatomic) IBOutlet UILabel *flutterMsgLbl;

@end

@implementation OCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *userName = self.flutterMsg[@"userName"];
    NSString *pwd = self.flutterMsg[@"pwd"];
    self.flutterMsgLbl.text = [NSString stringWithFormat:@"从Flutter页面产值为 :%@和%@",userName,pwd];
}

@end
