//
//  JOBTSecondViewController.h
//  BTDemo
//
//  Created by wbh on 12-4-18.
//  Copyright (c) 2012年 重庆金瓯科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JOBluetooth/JOBluetoothDevice.h"

@interface JOBTSecondViewController : UIViewController<JOBluetoothDeviceDelegate>
{
    NSMutableData * recvDatas;
}
@property (weak, nonatomic) IBOutlet UITextView *textView_RecvData;
@property (weak, nonatomic) IBOutlet UITextView *textView_SendData;
- (IBAction)buttonCompleteInputContent:(id)sender;
- (IBAction)buttonSend:(id)sender;
- (IBAction)buttonClear:(id)sender;

@end
