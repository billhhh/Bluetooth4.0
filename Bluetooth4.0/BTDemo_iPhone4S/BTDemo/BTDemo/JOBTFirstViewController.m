//
//  JOBTFirstViewController.m
//  BTDemo
//
//  Created by wbh on 12-4-18.
//  Copyright (c) 2012年 重庆金瓯科技. All rights reserved.
//

#import "JOBTFirstViewController.h"
#import "JOBluetooth/JOBluetoothDevice.h"

JOBluetoothDevice * activeDevice = nil;
extern id<JOBluetoothDeviceDelegate> deviceDelegate;

@interface JOBTFirstViewController ()

@end

@implementation JOBTFirstViewController
@synthesize deviceListTableView;
@synthesize scanConnectActivityInd;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    bluetoothRadio = [[JOBluetoothRadio alloc] initWithDelegate:self];
}

- (void)viewDidUnload
{
    [self setDeviceListTableView:nil];
    [self setScanConnectActivityInd:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)buttonStartDiscovery:(id)sender {
    //清空当前设备列表
    [bluetoothRadio deleteAllDevice];
    [deviceListTableView reloadData];
    
    if([bluetoothRadio startDiscovery:DEFAULT_DISCOVERY_TIMEOUT])
        [scanConnectActivityInd startAnimating];
    else {
        [self alertMessage:@"查询设备失败，请确认蓝牙已经打开！"];
    }

}

/*!
 *
 *  @method JOBluetoothRadioDelegate didFoundDevice:
 *
 */
-(void) didFoundDevice:(JOBluetoothDevice *)device {
    //printf("foundDevice. name[%s], ID[%s], RSSI[%d]\n",device.name.UTF8String,device.UUID.UTF8String,device.RSSI.intValue);
    [deviceListTableView reloadData];
}

/*!
 *
 *  @method JOBluetoothRadioDelegate didDiscoveryComplete:
 *
 */
-(void) didDiscoveryComplete{
    [scanConnectActivityInd stopAnimating];
    [deviceListTableView reloadData];
}

/*
 JOBluetoothRadioDelegate didConnectDevice:error:
 */
-(void) didConnectDevice:(JOBluetoothDevice *)device error:(Boolean)error
{
    if(error)
    {
        NSString * msg = [[NSString alloc] initWithFormat:@"连接到设备 (%@) 失败",device.name];
        [self alertMessage:msg];
        //printf("connectComplete[Faild]. name[%s], ID[%s]\n",[device retrieveName].UTF8String,[device retrieveUUID].UTF8String);
    }
    else {
        //printf("connectComplete[Success]. name[%s], ID[%s]\n",[device retrieveName].UTF8String,[device retrieveUUID].UTF8String);
        
        activeDevice = device;
        if(deviceDelegate)
        {
            activeDevice.delegate = deviceDelegate;
        }

    }
    [deviceListTableView reloadData];
    [scanConnectActivityInd stopAnimating];
    
}

-(void) didDisconnectDevice:(JOBluetoothDevice *)device error:(Boolean)error
{
    //printf("disconnectComplete. name[%s], ID[%s]\n",[device retrieveName].UTF8String,[device retrieveUUID].UTF8String);
    [deviceListTableView reloadData];
    activeDevice = nil;
    [scanConnectActivityInd stopAnimating];
    
    if(!error)
    {
        NSString * msg = [[NSString alloc] initWithFormat:@"与设备 (%@) 的连接已经断开. ",device.name];
        [self alertMessage:msg];
    }
}

//－行的数量：
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section   
{
    return [bluetoothRadio.deviceList count];
}

//－行的定义  
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  
{
    static NSString * CellIdentifier = @"JODeviceListIdentifier";  
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];  
    if (cell == nil)
    {
        //默认样式
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];  
    }
    //文字的设置
    NSUInteger row=[indexPath row];
    JOBluetoothDevice * device = [bluetoothRadio.deviceList objectAtIndex:row];
    cell.textLabel.text= device.name;
    
    UIButton *button ; 
    button = [ UIButton buttonWithType : UIButtonTypeRoundedRect ];
    CGRect frame = CGRectMake ( 0.0 , 0.0 , 70 , 35 );
    button. frame = frame;
    if(device.isConnected)
    {
        [button setTitle:@"断开" forState:UIControlStateNormal];        
    }
    else {
        [button setTitle:@"连接" forState:UIControlStateNormal];
    }
    button.backgroundColor = [ UIColor clearColor ];
    cell.accessoryView = button;
    
    [button addTarget : self action : @selector ( btnDeviceListClicked : event :)   forControlEvents :UIControlEventTouchUpInside ];
    
    
    return cell;  
}

/*!
 *
 *  用户按下连接或者断开按钮，进行连接或者断开操作
 */
-( void )tableView:( UITableView *) tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    JOBluetoothDevice * device = [bluetoothRadio.deviceList objectAtIndex:[indexPath row]];
    
    [scanConnectActivityInd stopAnimating];
    if(device.isConnected)
    {
        //NSLog(@"buttonStartDisconnect\n");
        [bluetoothRadio startDisconnectDevice:device];
    }
    else {
        //NSLog(@"buttonStartConnect\n");
        [bluetoothRadio startConnectDevice:device timeout:DEFAULT_CONNECT_TIMEOUT];
    }
    [scanConnectActivityInd startAnimating];
}

/*!
 *
 *  检查用户点击按钮时的位置，并转发事件到对应的 accessory tapped 事件
 */
- ( void )btnDeviceListClicked:( id )sender event:( id )event
{
    NSSet *touches = [event allTouches ];
    UITouch *touch = [touches anyObject ];
    CGPoint currentTouchPosition = [touch locationInView : self.deviceListTableView];
    NSIndexPath *indexPath = [ self.deviceListTableView indexPathForRowAtPoint : currentTouchPosition];
    if (indexPath != nil )
    {
        [ self tableView : self.deviceListTableView accessoryButtonTappedForRowWithIndexPath : indexPath];
    }
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
