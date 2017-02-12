//
//  JOBTSecondViewController.m
//  BTDemo
//
//  Created by wbh on 12-4-18.
//  Copyright (c) 2012年 重庆金瓯科技. All rights reserved.
//

#import "JOBTSecondViewController.h"
#import "JOBluetooth/JOBluetoothDevice.h"

extern JOBluetoothDevice * activeDevice;
id<JOBluetoothDeviceDelegate> deviceDelegate=nil;

@interface JOBTSecondViewController ()

@end

@implementation JOBTSecondViewController
@synthesize textView_RecvData;
@synthesize textView_SendData;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    deviceDelegate = self;
    if(activeDevice)
    {
        activeDevice.delegate = deviceDelegate;
    }

}

- (void)viewDidUnload
{
    [self setTextView_RecvData:nil];
    [self setTextView_SendData:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    if(activeDevice)
    {
        activeDevice.delegate = nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (IBAction)buttonCompleteInputContent:(id)sender {
    [textView_RecvData resignFirstResponder];
    [textView_SendData resignFirstResponder];
}

- (IBAction)buttonSend:(id)sender {
    if(activeDevice!=nil && activeDevice.isConnected)
    {
        //转换成GB2312编码之后，再发送给打印机,否则打印机无法打印
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSData* data=[textView_SendData.text dataUsingEncoding:enc];
        if(data == nil)
        {//转换失败的话，我们转换为UTF8编码，但这个时候只能够打印英文字母
            data = [textView_SendData.text dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        /*NSMutableData * mData = [NSMutableData dataWithData:data];
        for(int i=0;i<500;i++)
        {
            [mData appendData:data];
        }
        if(![activeDevice writeData:mData])
        {
            [self alertMessage:@"发送数据失败"];
        }*/
       
        
        if(![activeDevice writeData:data])
        {
            [self alertMessage:@"发送数据失败"];
        }
        
        /*Byte * buf;
        int i;
        buf = (Byte *)data.bytes;
        for(i=0;i<100;i++)
        {
            buf[0] = i;
            if(![activeDevice writeData:data])
            {
                break;
                //[self alertMessage:@"发送数据失败"];
            }
        }*/
        
        /*NSString * msg = [[NSString alloc]initWithFormat:@"将 %d 个字节放入缓存",i* data.length];
         [self alertMessage:msg];*/
    }
    else {
        [self alertMessage:@"请连接设备后再发送数据"];
    }
}

- (IBAction)buttonClear:(id)sender {
    self.textView_SendData.text = nil;
    self.textView_RecvData.text = nil;
    recvDatas = nil;
}

-(void) bluetoothDevice:(JOBluetoothDevice *)device didDataReceived:(NSData *)data
{
    if(recvDatas==nil)
    {
        recvDatas = [NSMutableData dataWithData:data];
    }
    else {
        if(recvDatas.length>1000)
        {
            recvDatas = [NSMutableData dataWithData:data];
        }
        else {
            [recvDatas appendData:data];
        }    
    }    
    textView_RecvData.text = [[NSString alloc]initWithBytes:recvDatas.bytes length:recvDatas.length encoding:NSUTF8StringEncoding];
}

-(void) bluetoothDevice:(JOBluetoothDevice *)device didUpdateRSSISuccess:(Boolean)success
{
    NSLog(@"didUpdateRSSISuccess RSSI(%@)\n",device.RSSI);
}

-(void) alertMessage:(NSString *)msg{
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"提示" 
                                                   message:msg
                                                  delegate:self
                                         cancelButtonTitle:@"关闭" 
                                         otherButtonTitles:nil];
    [alert show];
    //[alert release];
    
}
@end
