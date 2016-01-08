//
//  ViewController.m
//  BaiduMapPractic
//
//  Created by XiaDian on 16/1/7.
//  Copyright © 2016年 xue. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
@interface ViewController ()<BMKMapViewDelegate,UISearchBarDelegate,BMKPoiSearchDelegate,BMKLocationServiceDelegate,CLLocationManagerDelegate>
{  //地图的指针
    BMKMapView* _mapView;
    //搜索的指针
    BMKPoiSearch *_searcher;
    //定位的指针
    BMKLocationService *_locService;
    
}
@property(nonatomic,strong) CLLocationManager *locaManager;
@property(nonatomic,retain)CLLocation *coor;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property(nonatomic,assign)BOOL change;
@property(nonatomic,strong)NSMutableArray *arrPoi;
@end

@implementation ViewController
- (IBAction)myLoctiaon:(id)sender {
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}

- (IBAction)butt:(id)sender {
    
    self.change=!self.change;
    self.change?[_mapView setMapType:BMKMapTypeSatellite]:[_mapView setMapType:BMKMapTypeStandard];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrPoi=[[NSMutableArray alloc]init];
    self.change=NO;
    self.searchBar.delegate=self;
    //搜索功能
    _searcher =[[BMKPoiSearch alloc]init];
    _searcher.delegate =self;
    // Do any additional setup after loading the view, typically from a nib.
    //地图的功能
    _mapView =[[BMKMapView alloc]initWithFrame:self.view.frame];
    //地图的中心坐标，经纬显示范围
    BMKCoordinateRegion reg;
    reg.span.latitudeDelta=50;
    reg.span.longitudeDelta=50;
    [_mapView setRegion:reg];
    [self.view insertSubview:_mapView atIndex:0];
    [_mapView setTrafficEnabled:NO];
    _mapView.showsUserLocation=YES;
    
    [self getUSerLocation];
    ///////////////////////////////////////////////////////////////////////////
    _locService = [[BMKLocationService alloc]init];
    //启动LocationService
    
}
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}
/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
   // NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    BMKCoordinateRegion region;
    region.center.latitude  = userLocation.location.coordinate.latitude;
    region.center.longitude = userLocation.location.coordinate.longitude;
    region.span.latitudeDelta  = 0.02;
    region.span.longitudeDelta = 0.02;
    self.coor=userLocation.location;
    [_locService stopUserLocationService];
    if (_mapView)
    {
        _mapView.region = region;
        NSLog(@"当前的坐标是: %f,%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    }
    [_mapView updateLocationData:userLocation];
}
#pragma mark mapViewDelegate 代理方法
- (void)mapView:(BMKMapView *)mapView1 didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    BMKCoordinateRegion region;
    region.center.latitude  = userLocation.location.coordinate.latitude;
    region.center.longitude = userLocation.location.coordinate.longitude;
    region.span.latitudeDelta  = 0.2;
    region.span.longitudeDelta = 0.2;
    if (_mapView)
    {
        _mapView.region = region;
        NSLog(@"当前的坐标是: %f,%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//固定写法，必须写上
-(void)viewWillAppear:(BOOL)animated
{ //*当mapview即将被显式的时候调用，恢复之前存储的mapview状态。
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
   _locService.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _searcher.delegate = nil;
    _locService.delegate = nil;
}
//设置标注点必须要实现的代理方法
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}
- (void) viewDidAppear:(BOOL)animated {
    // 添加一个PointAnnotation注释标签
//   BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
//     //坐标
//    CLLocationCoordinate2D coor;
//    coor.latitude = +37.78583400;
//    coor.longitude = -122.40641700;
//    //设置注释坐标
//    annotation.coordinate = coor;
//    //注释的标题
//    annotation.title = @"这里是你的位置";
//    [_mapView addAnnotation:annotation];
}
//搜索按钮的代理方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    ///分页索引，可选，默认为0
    option.pageIndex =0;
    //每页的数量
    option.pageCapacity = 10;
    
    option.location =self.coor.coordinate;
;
    option.keyword = searchBar.text;
    BOOL flag = [_searcher poiSearchNearBy:option];
    if(flag)
    {
        NSLog(@"周边检索发送成功");
    }
    else
    {
        NSLog(@"周边检索发送失败");
    }
    [self.searchBar resignFirstResponder];
    
}
//发送搜索请求回调
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
       //获得兴趣点的数组
        NSArray *arr=poiResultList.poiInfoList;
        [_mapView removeAnnotations:self.arrPoi];
        NSLog(@"%lu",(unsigned long)arr.count);
        //获得每个兴趣点
        for ( BMKPoiInfo *info
 in arr) {
            NSLog(@"%@",info.name);
            [self deatail:info];

        }
          }
    else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
       // 当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
       //  result.cityList;
        NSLog(@"起始点有歧义");
    } else {
        NSLog(@"抱歉，未找到结果");
    }
}
-(void)deatail:(BMKPoiInfo *)uid{
    //放置搜索的标记
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    //坐标
    CLLocationCoordinate2D coor;
    coor.latitude = uid.pt.latitude;
    coor.longitude = uid.pt.longitude;
    annotation.coordinate = coor;
    annotation.title =uid.name;
    [_mapView addAnnotation:annotation];
    [self.arrPoi addObject:annotation];
    
    
    //POI详情检索
    BMKPoiDetailSearchOption* option = [[BMKPoiDetailSearchOption alloc] init];
    option.poiUid =uid.uid;//POI搜索结果中获取的uid
    BOOL flag = [_searcher poiDetailSearch:option];
    if(flag)
    {
        NSLog(@"//详情检索发起成功");
    }
    else
    {
        //详情检索发送失败
    }
}
//详情的回调方法
-(void)onGetPoiDetailResult:(BMKPoiSearch *)searcher result:(BMKPoiDetailResult *)poiDetailResult errorCode:(BMKSearchErrorCode)errorCode
{
   
    if(errorCode == BMK_SEARCH_NO_ERROR){
       // 在此处理正常结果
            NSLog(@"%@",poiDetailResult.name);
            BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
            CLLocationCoordinate2D coor;
            coor.latitude = poiDetailResult.pt.latitude;
            coor.longitude = poiDetailResult.pt.latitude;
            annotation.coordinate = coor;
            annotation.title =poiDetailResult.name;
            [_mapView addAnnotation:annotation];
    }
}
-(void)getUSerLocation{
    //初始化定位管理类
    _locaManager = [[CLLocationManager alloc] init];
    //delegate
    _locaManager.delegate = self;
    //    The desired location accuracy.//精确度
    _locaManager.desiredAccuracy = kCLLocationAccuracyBest;
    //Specifies the minimum update distance in meters.
    //距离 m
    _locaManager.distanceFilter = 10;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        //        [_locaManager requestWhenInUseAuthorization];
        [_locaManager requestAlwaysAuthorization];
    }
    //开始时时定位
    [_locaManager startUpdatingLocation];
    /*
     float latitude = 40.03595780;
     float longitude = 116.36348311;  //这里可以是任意的经纬度值
     CLLocation *location= [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
     [[_locaManager delegate] locationManager:_locaManager didUpdateLocations:@[location]];
     */
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //停止时时定位
    [manager stopUpdatingLocation];
    for(CLLocation *location in locations){
        NSLog(@"---------%@-------",location);
        
    }
    //地理反编码类 CLGeocoder
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    CLLocation *location = [locations objectAtIndex:0];
    //根据经纬度反向解析出地址等信息
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        for(CLPlacemark *place in placemarks)
        {
            self.coor=place.location;
            //获取到自己的坐标点，插上注释
           // BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
            CLLocationCoordinate2D coor;
            coor.latitude =place.location.coordinate.latitude;
            coor.longitude = place.location.coordinate.longitude;
           // annotation.coordinate = coor;
           // annotation.title =place.name;
           // [_mapView addAnnotation:annotation];
           // _mapView.centerCoordinate=place.location.coordinate;
            BMKCoordinateRegion reg;
            reg.center=coor;
            reg.span.latitudeDelta=1;
            reg.span.longitudeDelta=1;
            [_mapView setRegion:reg animated:YES];
        }
    }];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    switch([error code]) {
        case kCLErrorDenied:
            [self openGPSTips];
            break;
        case kCLErrorLocationUnknown:
            break;
        default:
            break;
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.view becomeFirstResponder];

}
-(void)openGPSTips{
    UIAlertView *alet = [[UIAlertView alloc] initWithTitle:@"当前定位服务不可用" message:@"请到“设置->隐私->定位服务”中开启定位" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alet show];
}
@end
