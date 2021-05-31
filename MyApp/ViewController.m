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
@property (nonatomic,strong) NSMutableArray *dataArr;
@end

@implementation ViewController

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc]initWithArray:@[@"1",@"12",@"45",@"14",@"54",@"75",@"85",@"19",@"62",@"17",@"98"]];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"原生首页";
    NSArray *dataArr = @[@"flutter列表",@"flutter登录页面",@"flutter练习"];
    [self createButton:dataArr.count withTitle:dataArr];
    [self sortMethod];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self studyGCD];
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

#pragma mark 各种排序方法
- (void)sortMethod{
    NSMutableArray *arr = [self.dataArr mutableCopy];
    [self quickSort:arr start:0 end:arr.count-1];
    NSLog(@"快速排序法排序后的数组: %@",arr);
    [self selectSort];
    [self bubblingSort];
}

//快速排序
- (void)quickSort:(NSMutableArray *)arr start:(NSInteger)start end:(NSInteger)end {
    //如果数组长度为0或1时返回
    if (start >= end) {
        return;
    }
    NSInteger low = start;
    NSInteger high = end;
    //记录比较基准数
    int stand = [arr[start] intValue];
    while (low < high) {
        /**** 首先从右边j开始查找比基准数小的值 ***/
        while (low < high && stand <= [arr[high] intValue]) { //如果比基准数大，继续查找
            high--;
        }
        if (low == high) {
            break;
        }
        //如果比基准数小，则将查找到的小值调换到i的位置(先赋值,然后再low+1)
        arr[low++] = arr[high];
        
        /**** 当在右边查找到一个比基准数小的值时，就从i开始往后找比基准数大的值 ***/
        while (low < high && stand >= [arr[low] intValue]) {//如果比基准数小，继续查找
            low++;
        }
        if (low == high) {
            break;
        }
        //如果比基准数大，则将查找到的大值调换到j的位置(先赋值,然后再high-1)
        arr[high--] = arr[low];
    }
    //把标准数赋值给低所在的位置
    arr[low] = @(stand);
    
    /**** 递归排序 ***/
    //排序基准数左边的
    [self quickSort:arr start:start end:low];
    //排序基准数右边的
    [self quickSort:arr start:low+1 end:end];
}

//选择排序法
- (void)selectSort{
    NSString *temp;
    NSMutableArray *arr = [self.dataArr mutableCopy];
    for (int i = 0; i<arr.count-1; i++) {
        for (int j = i+1; j<arr.count; j++) {
            if ([arr[i] intValue] > [arr[j] intValue]) {
                temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
        }
    }
    NSLog(@"选择排序法排序后的数组: %@",arr);
}

//冒泡排序法
- (void)bubblingSort{
    NSString *temp;
    NSMutableArray *arr = [self.dataArr mutableCopy];
    for (int i = 0; i<arr.count-1; i++) {
        for (int j = 0; j<arr.count-1-i; j++) {
            if ([arr[j] intValue] > [arr[j+1] intValue]) {
                temp = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = temp;
            }
        }
    }
    NSLog(@"冒泡排序法排序后的数组: %@",arr);
}

- (void)studyGCD{
    NSLog(@"--->1");
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"--->2");
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"--->3");
        dispatch_group_leave(group);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"--->4");
    });
    NSLog(@"--->5");
}

@end
