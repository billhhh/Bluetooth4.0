//
//  JOBTFirstViewController.h
//  BTDemo
//
//  Created by wbh on 12-4-18.
//  Copyright (c) 2012年 重庆金瓯科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JOBluetooth/JOBluetoothRadio.h"

@interface JOBTFirstViewController : UIViewController<JOBluetoothRadioDelegate,UITableViewDelegate,UITableViewDataSource>
{
    JOBluetoothRadio *bluetoothRadio;
}
@property (weak, nonatomic) IBOutlet UITableView *deviceListTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scanConnectActivityInd;
- (IBAction)buttonStartDiscovery:(id)sender;

@end
