//
//  AppDelegate.h
//  BaiduMapPractic
//
//  Created by XiaDian on 16/1/7.
//  Copyright © 2016年 xue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BMKMapManager *_mapManager;
}
@property (strong, nonatomic) UIWindow *window;


@end

