//
//  ViewController.m
//  MyApp
//
//  Created by Destiny on 2019/12/10.
//  Copyright © 2019 Destiny. All rights reserved.
//

#import "ViewController.h"
#import <Flutter/Flutter.h>
#import "OCViewController.h"

@interface ViewController ()<FlutterStreamHandler>

@property (nonatomic,strong) FlutterViewController *flutterVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"原生首页";
    NSArray *dataArr = @[@"flutter列表",@"flutter登录页面",@"flutter练习"];
    [self createButton:dataArr.count withTitle:dataArr];
}

- (CGFloat)getStatusHeight{
    if (@available(iOS 13.0, *)) {
        return [[UIApplication sharedApplication].windows objectAtIndex:0].windowScene.statusBarManager.statusBarFrame.size.height;
    } else {
        return [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
}

- (void)createButton:(NSInteger)count withTitle:(NSArray*)titleArray{
    for (int i = 0; i<count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((MainScreenWidth-200)/2, KNavBarHeight+[self getStatusHeight]+i*50+(i+1)*10, 200, 50);
        btn.backgroundColor = [UIColor redColor];
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = CGRectGetHeight(btn.frame)/2;
        btn.layer.masksToBounds = YES;
        btn.tag = 1000+i;
        [self.view addSubview:btn];
    }
}

- (void)btnClick:(UIButton *)btn{
    if (btn.tag == 1000) {
        [self setFlutterAndNativeInteraction:0 withRoute:@"flutter_listView" withNavTitle:@"列表"];
    }else if (btn.tag == 1001) {
        [self setFlutterAndNativeInteraction:1 withRoute:@"flutter_login" withNavTitle:@"登录"];
    }else if (btn.tag == 1002) {
        [self setFlutterAndNativeInteraction:2 withRoute:@"flutter_exercise" withNavTitle:@"练习"];
    }
    [self.navigationController pushViewController:self.flutterVC animated:YES];
}

/// flutter、原生相互传递数据
- (void)setFlutterAndNativeInteraction:(int)type withRoute:(NSString *)route withNavTitle:(NSString *)title{
    self.flutterVC = [[FlutterViewController alloc]initWithProject:nil initialRoute:route nibName:nil bundle:nil];
    self.flutterVC.title = title;
    __weak typeof(self) weakSelf = self;
    //⚠️ channelName必须和flutter代码中的名字一致
    NSString *channelName = @"com.allen.test.call";
    if (type == 1) {
        /*⚠️ flutter主动和iOS交互*/
        FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:(NSObject<FlutterBinaryMessenger>*)self.flutterVC];
        [channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            // Flutter invokeMethod 特定方法的时候会触发到这里
            result(@"接收到flutter的消息,回传信息from OC");
            NSLog(@"接收到flutter的方法:%@,参数:%@",call.method,call.arguments);
            if ([call.method isEqualToString:@"getFlutterMessage"]) {
                OCViewController *ocVC = [[OCViewController alloc]init];
                ocVC.flutterMsg = call.arguments;
                [weakSelf.navigationController pushViewController:ocVC animated:YES];
            }
        }];
    }else if (type == 2) {
        /*⚠️ 初始化flutter界面时候iOS传值给flutter,需查看代理*/
        FlutterEventChannel *evenChannal = [FlutterEventChannel eventChannelWithName:channelName binaryMessenger:(NSObject<FlutterBinaryMessenger>*)self.flutterVC];
        [evenChannal setStreamHandler:self];
    }
}

#pragma mark - <FlutterStreamHandler>
// 这个onListen是Flutter端开始监听这个channel时的回调，第二个参数 EventSink是用来传数据的载体。
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(FlutterEventSink)events {
    // arguments flutter给native的参数
    // 回调给flutter， 建议使用实例指向，因为该block可以使用多次
    if (events) {
        events(@"push传值给flutter的vc");
    }
    return nil;
}

/// flutter不再接收
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    // arguments flutter给native的参数
    NSLog(@"%@", arguments);
    return nil;
}

@end
