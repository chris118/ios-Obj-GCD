//
//  ViewController.m
//  GCDDemo
//
//  Created by wang xiaopeng on 8/19/15.
//  Copyright (c) 2015 Triton. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *mInfo;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%@", [NSThread currentThread].description);
    
//    [self Test1];
//    [self Test2];
//    [self Test3];
//    [self Test4];
//    [self Test5];
    [self Test6];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)Test1{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ // 1
        
        NSLog(@"%@", [NSThread currentThread].description);
        
        sleep(2);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"%@", [NSThread currentThread].description);
            
            [self.mInfo setText:@"Task 1 work thread is done !"];
        });
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ // 1
        
        NSLog(@"%@", [NSThread currentThread].description);
        
        sleep(1);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"%@", [NSThread currentThread].description);
            
            [self.mInfo setText:@"Task2 work thread is done !"];
        });
    });
}

-(void)Test2{
    
    int64_t delayInSeconds = 3.0;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds*NSEC_PER_SEC);

    dispatch_after(time, dispatch_get_main_queue(), ^{
        
        [self.mInfo setText:@"在UI线程 延迟执行一段代码!"];
    });
}

-(void)Test3{

    dispatch_queue_t queue = dispatch_queue_create("com.triton.gcddemo", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"%@", [NSThread currentThread].description);
        sleep(1);
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"%@", [NSThread currentThread].description);
        sleep(5);
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"%@", [NSThread currentThread].description);
        sleep(3);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        [self.mInfo setText:@"3个工作线程都完成了"];
    });
}

-(void)Test4{
    
    dispatch_queue_t queue = dispatch_queue_create("com.triton.gcddemo", DISPATCH_QUEUE_CONCURRENT);
    
//    // 1 -> 3 -> 2
//    dispatch_async(queue, ^{
//        sleep(1);
//        NSLog(@"thread 1 %@", [NSThread currentThread].description);
//    });
//    
//    dispatch_async(queue, ^{
//        sleep(5);
//        NSLog(@"thread 2 %@", [NSThread currentThread].description);
//    });
//    
//    dispatch_async(queue, ^{
//        sleep(3);
//        NSLog(@"thread 3 %@", [NSThread currentThread].description);
//    });
    
    
    // 4 -> 5 -> 6
    dispatch_async(queue, ^{
        sleep(1);
        NSLog(@"thread 4 %@", [NSThread currentThread].description);
    });
    
    dispatch_async(queue, ^{
        sleep(5);
        NSLog(@"thread 5 %@", [NSThread currentThread].description);
    });
    
    dispatch_barrier_async(queue, ^{
        sleep(3);
        NSLog(@"thread 6 %@", [NSThread currentThread].description);
        
    });
}

-(void)Test5{

    //dispatch_async 是同步的
    //NSLog(@"done"); 是在dispatch_apply操作完成后才会执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ // 1
        
        dispatch_apply(5, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t time) {
            sleep(2);
            NSLog(@"%@", [NSThread currentThread].description);
            
        });
        NSLog(@"done");
    });
}

-(void)Test6{
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    for (int i = 0; i < 100; i++)
//    {
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        dispatch_group_async(group, queue, ^{
//            NSLog(@"%i",i);
//            sleep(5);
//            dispatch_semaphore_signal(semaphore);
//        });
//    }
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int index = 0; index < 20; index++) {
        
        dispatch_async(queue, ^(){
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//
            
            NSLog(@"addd :%d", index);
            
            [array addObject:[NSNumber numberWithInt:index]];
            
            dispatch_semaphore_signal(semaphore);
            
        });
        
    }
}

@end
