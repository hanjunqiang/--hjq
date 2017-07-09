
//
//  MonthCalendarView.m
//  LeSong
//
//  Created by 韩军强 on 2017/6/14.
//  Copyright © 2017年 韩军强. All rights reserved.
//

#import "MonthCalendarView.h"

@implementation MonthCalendarView

-(void)jq_initialData
{
    self.backgroundColor=[UIColor whiteColor];
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height - 64;

    
    [self addWeekView];  //周六-周五标题
    [self nowDate]; //当前日期

    [self addCalendarAndBackgroundScrollView]; //添加日历以及所在的UIScrollView
    
    _selectMonth = _nowMonth; //默认选中当前月
    
    NSLog(@"_smallDayArr=%@",_smallDayArr);
    NSLog(@"_selectDay=%d",_selectDay);
    
}


- (void)addWeekView{
    
    _weekArray = @[@"周六",@"周日",@"周一",@"周二",@"周三",@"周四",@"周五"];
    CGFloat width = ceilf(screenWidth/7);
    for (int i = 0; i < 7; i ++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(width*i,0,width,30)];
        label.text = _weekArray[i];
        label.textAlignment = 1;
        label.backgroundColor = [UIColor whiteColor];
        if (i == 0 || i == 1) {
            label.textColor = [UIColor colorFromHexRGB:@"d03e3e"];
        }else{
            label.textColor = [UIColor blackColor];
        }
        label.font = [UIFont systemFontOfSize:12];
        [self addSubview:label];
    }
    
}

//日历的背景
- (void)addCalendarAndBackgroundScrollView{
    
    _calendarSV = [[UIScrollView alloc]initWithFrame:CGRectMake(0,30,screenWidth,(screenWidth)/7*6)];
    _calendarSV.contentSize = CGSizeMake(screenWidth*3, (screenWidth)/7*6);
    _calendarSV.backgroundColor = [UIColor clearColor];
    _calendarSV.delegate = self;
    _calendarSV.pagingEnabled = true;
    _calendarSV.bounces = false;
    _calendarSV.showsHorizontalScrollIndicator = false;
    _calendarSV.contentOffset = CGPointMake(screenWidth, 0);
    [self addSubview:_calendarSV];
    
    [self addCurrentMouthCollectionView]; //初始化当前月的日历
    [self addLastMouthCollectionView]; //初始化上月的日历
    [self addNextMouthCollectionView]; //初始化下月的日历
    
}

//刷新所有的日历(可在此优化)
- (void)reloadAllDate{
    
    [_currentMonthCV reloadData];
    [_lastMonthCV reloadData];
    [_nextMonthCV reloadData];
    
}

//初始化当前显示月的日历
- (void)addCurrentMouthCollectionView{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((screenWidth)/7, (screenWidth)/7);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    //注意这里_calendarSV.bounds为(origin = (x = 320, y = 0), size = (width = 320, height = 274.285706))
    //因为_calendarSV.bounds偏移了一个屏幕的宽度
    _currentMonthCV = [[UICollectionView alloc] initWithFrame:_calendarSV.bounds collectionViewLayout:layout];
    _currentMonthCV.dataSource = self;
    _currentMonthCV.delegate = self;
    _currentMonthCV.backgroundColor = [UIColor clearColor];
    [_currentMonthCV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [_calendarSV addSubview:_currentMonthCV];
}

//初始化上月的日历
- (void)addLastMouthCollectionView{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((screenWidth)/7, (screenWidth)/7);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _lastMonthCV = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenWidth) collectionViewLayout:layout];
    _lastMonthCV.dataSource = self;
    _lastMonthCV.delegate = self;
    _lastMonthCV.backgroundColor = [UIColor clearColor];
    [_lastMonthCV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [_calendarSV addSubview:_lastMonthCV];
}

//初始化下月的日历
- (void)addNextMouthCollectionView{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((screenWidth)/7, (screenWidth)/7);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _nextMonthCV = [[UICollectionView alloc] initWithFrame:CGRectMake(screenWidth*2,0,screenWidth,screenWidth) collectionViewLayout:layout];
    _nextMonthCV.dataSource = self;
    _nextMonthCV.delegate = self;
    _nextMonthCV.backgroundColor = [UIColor clearColor];
    [_nextMonthCV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [_calendarSV addSubview:_nextMonthCV];
}


//周日历固定21天,月日历统一42天(根据实际的天数显示)
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    //    if (collectionView == _smallCalendar) {
    //        return 21;
    //    }else{
    return 7*6;
    //    }
}

//加载日历的日期
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [cell.contentView viewWithTag:10];
    [label removeFromSuperview];
    
    if (collectionView == _currentMonthCV) {
        [self addCellLabelWithView:cell.contentView WithIndex:indexPath.item WithDayArr:_currentMonthArr WithWeek:_currentWeek];
    }else if (collectionView == _lastMonthCV) {
        [self addCellLabelWithView:cell.contentView WithIndex:indexPath.item WithDayArr:_lastMonthArr WithWeek:_lastWeek];
    }else if (collectionView == _nextMonthCV) {
        [self addCellLabelWithView:cell.contentView WithIndex:indexPath.item WithDayArr:_nextMonthArr WithWeek:_nextWeek];
    }
    
    return cell;
}

#pragma mark - 切换到指定日期
-(void)jq_changeDate
{
    self.isChangeStr = @"1";
    [self collectionView:_currentMonthCV didSelectItemAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
}

//处理选中日期,
//当前为周日历,并且周日历显示两个月份的日期时(6月,7月),若由6月的日期选到7月的日期,在刷新界面的时候,同时需要将相应的月份更改掉;也许在此做处理.
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //该步骤和指定日期会选择一个走
    NSString *dayString = nil;
    if (indexPath.item >= _currentWeek-1 && indexPath.item <= _currentMonthArr.count-1+_currentWeek-1) {
        //            _selectItem = (int)indexPath.item;
        //            _selectOriginY = (indexPath.item/7)*((screenWidth)/7);
        dayString = _currentMonthArr[indexPath.item - (_currentWeek-1)];
        
        NSArray *array = [dayString componentsSeparatedByString:@"-"];
        
        int month = [array[0] intValue];
        int day = [array[1] intValue];
        _selectDay = day;
        _selectItem = _selectDay;
        
        NSLog(@"选中的时间为=%@",[NSString stringWithFormat:@"%02d:%02d:%02d",_currentYear,month,_selectDay]);
        
        NSString *jq_dateStr = [NSString stringWithFormat:@"%02d-%02d-%02d",_currentYear,month,_selectDay];
        self.selectBlock(jq_dateStr);
    }
    
    
    
    //选择指定日期
    if ([self.isChangeStr intValue]) {
        self.isChangeStr = @"0";
        
        
        NSArray *array = [self.dateStr componentsSeparatedByString:@"-"];
        int year = [array[0] intValue];
        _currentYear = year; //当前年（没具体分析，暂无问题）
        int month = [array[1] intValue];  //选中的月
        _currentMonth = month;
        
        //因为选择了指定的日期，所以这里要重新刷新数据，特别是为了刷新当前应该展示的_smallDayArr
        [self getDateWithYear:year WithMonth:month];

        [self reloadAllDate];
        _selectItem = [array[2] intValue]; //选中的天
        _selectDay = [array[2] intValue];
        
        NSLog(@"选中的时间为=%@",[NSString stringWithFormat:@"%02d:%02d:%02d",_currentYear,month,_selectDay]);
        
        NSString *jq_dateStr = [NSString stringWithFormat:@"%02d-%02d-%02d",_currentYear,month,_selectDay];
        self.selectBlock(jq_dateStr);
        
    }
    
    
    
    
    
    
    
    //选中的月
    _selectMonth = _currentMonth;
    //    [_smallCalendar reloadData];
    [_currentMonthCV reloadData];
}


-(void)isCanSelect:(NSIndexPath *)indexPath
{
    NSString *string = _smallDayArr[indexPath.row];
    NSArray *array = [string componentsSeparatedByString:@"-"];
    int month = [[array firstObject] intValue];
    int day = [[array lastObject] intValue];
    //选择哪一天
    if (day == _selectDay && month == _selectMonth) { //限定当前月的当前天才显示
        //        lab.layer.cornerRadius = (view.frame.size.width-10)/2;
        //        lab.layer.backgroundColor = [UIColor orangeColor].CGColor;
        //        lab.textColor = [UIColor whiteColor];
    }else{
        //判断昨天今天明天
        if (_nowYear < _currentYear) {
            //            lab.textColor = lastColor;
            NSLog(@"傻逼，时间没到呢！");
            
        }else if (_nowYear == _currentYear){
            if (_nowMonth < month) {
                //                lab.textColor = lastColor;
                NSLog(@"傻逼，时间没到呢！");
                
            }else if (_nowMonth == month){
                if (day > _nowDay) {
                    //                    lab.textColor = lastColor;
                    NSLog(@"傻逼，时间没到呢！");
                }else if (day == _nowDay){
                    //                    lab.textColor = [UIColor redColor];   //请求账单
                }else{
                    //                    lab.textColor = nextColor;            //请求账单
                }
            }else{
                //                lab.textColor = nextColor;                    //请求账单
            }
        }else{
            //            lab.textColor = nextColor;                            //请求账单
        }
    }
    
}


//左右切换月份
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    //    NSLog(@"%s",__func__);
    if (scrollView == _calendarSV) {
        int year = _currentYear;
        int mouth = _currentMonth;
        //        _selectDay = 1;
        
        //原本scrollView.contentOffset偏移了一个屏幕，向左则偏移scrollView.contentOffset=0，向右则偏移screenWidth*2为screenWidth*2
        if (scrollView.contentOffset.x == 0) {
            [self getDateWithYear:year WithMonth:mouth-1]; //上个月(切换上个月为当前月，重新上月、当前月、下月刷新数据。)
        }else if (scrollView.contentOffset.x == screenWidth*2) {
            [self getDateWithYear:year WithMonth:mouth+1]; //下个月
        }
        _selectItem = _currentWeek;

        [self reloadAllDate];
        
        //偏移一个屏幕宽度（往哪个方向偏移，哪个方向为正，所以这里就一直为screenWidth）
        CGPoint point = _calendarSV.contentOffset;
        point.x = screenWidth;
        _calendarSV.contentOffset = point;
        
    }
    
}



//显示月日历的日期,包括添加标记
- (void)addCellLabelWithView:(UIView *)view WithIndex:(NSInteger)index WithDayArr:(NSMutableArray *)dayArr WithWeek:(int)week{
    
    //这里的判断，week：当前月1号是周几。  这里是为了让1号放在指定的周几位置，然后dayArr中位置再偏移指定的位置week-1
    //假设，当前月1号为周一，那么index-(week-1)为0。以此类推。。。
    if (index >= week-1 && index <= dayArr.count-1+week-1){
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, view.frame.size.width-14, view.frame.size.height-14)];
        NSString *string = dayArr[index - (week-1)];
        
        
        NSArray *array = [string componentsSeparatedByString:@"-"];
        int month = [array[0] intValue];
        int day = [array[1] intValue];
        
        
        //        NSString *dayStr = [[string componentsSeparatedByString:@"-"] lastObject];
        //        int day = [dayStr intValue];
        lab.text = [@(day) stringValue];
        lab.textAlignment = 1;
        lab.tag = 10;
        lab.font = [UIFont systemFontOfSize:18];
        lab.layer.cornerRadius = (view.frame.size.width-14)/2;
        lab.clipsToBounds = YES;
        
        //选择的日期
        if (day == _selectDay && dayArr == _currentMonthArr &&month == _selectMonth) {
            
            lab.layer.backgroundColor = [UIColor colorFromHexRGB:@"3ebbd6"].CGColor;
            lab.textColor = [UIColor whiteColor];
            
            
        }else{
            UIColor *lastColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.8];
            UIColor *nextColor = [UIColor blackColor];
            //选择哪一天
            if (day == _selectDay && month == _selectMonth) { //限定当前月的当前天才显示
                //                lab.layer.cornerRadius = (view.frame.size.width-14)/2;
                //                lab.clipsToBounds = YES;
                lab.layer.backgroundColor = [UIColor colorFromHexRGB:@"3ebbd6"].CGColor;
                lab.textColor = [UIColor whiteColor];
            }else{
                //判断昨天今天明天
                if (_nowYear < _currentYear) {
                    lab.textColor = lastColor;
                }else if (_nowYear == _currentYear){
                    if (_nowMonth < month) {
                        lab.textColor = lastColor;
                    }else if (_nowMonth == month){
                        if (day > _nowDay) {
                            lab.textColor = lastColor;
                        }else if (day == _nowDay){
                            lab.textColor = [UIColor redColor];
                            [self addCellPointWithView:lab]; //当前天添加了个小红点
                            
                        }else{
                            lab.textColor = nextColor;
                        }
                    }else{
                        lab.textColor = nextColor;
                    }
                }else{
                    lab.textColor = nextColor;
                }
            }
            
        }
        
        [view addSubview:lab];
    }
}


//在日期下面添加点作为标记
- (void)addCellPointWithView:(UIView *)view{
    
    CALayer *layer=[CALayer layer];
    layer.bounds = CGRectMake(0, 0, 5, 5);
    layer.cornerRadius = 5/2;
    layer.masksToBounds = YES;
    layer.position = CGPointMake(((screenWidth)/7)/2+5, 5);
    layer.backgroundColor = [UIColor redColor].CGColor;
    [view.layer addSublayer:layer];
}

//计算相应的年份（这里做判断是为了，计算上一年和下一年，比如当前是一月，那么上一月传来的month就会为month-1=0月。）
- (int)getYearWithYear:(int)year WithMonth:(int)month{
    
    if (month <= 0) {
        year = year - 1;
    }else if (month >= 13) {
        year = year + 1;
    }
    
    return year;
}

//计算相应的月份（这里做判断是为了，计算上一月和下一月，比如当前是一月，那么上一月传来的month就会为month-1=0月，上面已经把year-1，那么这里应该是12月）
- (int)getMonthWithMonth:(int)month{
    
    if (month <= 0) {
        month = 12;
    }else if(month >= 13){
        month = 1;
    }
    
    return month;
}

//根据日期得到相应的星期
- (int)getWeekWithYear:(int)year WihtMonth:(int)month WithDay:(int)day{
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.day = day;
    comps.month = month;
    comps.year = year;
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [calendar dateFromComponents:comps];
    NSDateComponents *components =
    [calendar components:NSCalendarUnitWeekday fromDate:date];
    int week = (int)[components weekday];
    
    //让周日放在第一列，但是呢，下面week+1，所以这里是把周六放在了第一列。所以，如果调整周一到周日标题的位置，那么就可以在这里调整。
    if (week==7) {
        week=0;
    }
    
    //这里为了让日期都往后拖一天。
    return week+1;
}

//计算某年某月的日期
- (NSMutableArray *)getDayArrayWithYear:(int)year WithMonth:(int)month{
    
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM";
    NSString *dayString = [NSString stringWithFormat:@"%d-%d",year,month];
    NSDate *date = [formatter dateFromString:dayString];
    
    //计算某月又多少天（然后从1开始for循环出当月的天数。）
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    NSMutableArray *dayArray = [[NSMutableArray alloc] init];
    
    //这里是<=range.length,所以是i从1开始
    for (int i = 1;i <= range.length; i++) {
        NSString *mouthStr;
        NSString *dayStr;
        if (month<10) {
            mouthStr = [NSString stringWithFormat:@"0%d",month];
        }else{
            mouthStr = [NSString stringWithFormat:@"%d",month];
        }
        if (i<10) {
            dayStr = [NSString stringWithFormat:@"0%d",i];
        }else{
            dayStr = [NSString stringWithFormat:@"%d",i];
        }
        [dayArray addObject:[NSString stringWithFormat:@"%@-%@",mouthStr,dayStr]];
    }
    
    return dayArray;
}

//计算当前的日期
- (void)nowDate{
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy";
    NSString *year = [formatter stringFromDate:now];
    formatter.dateFormat = @"MM";
    NSString *mouth = [formatter stringFromDate:now];
    formatter.dateFormat = @"dd";
    NSString *day = [formatter stringFromDate:now];
    
    _nowYear = [year intValue];
    _nowMonth = [mouth intValue];
    _nowDay = [day intValue];
    
    NSString *dateStr = [NSString stringWithFormat:@"%02d-%02d-%02d",_nowYear,_nowMonth,_nowDay];
    self.selectBlock(dateStr); //回调选中的日期
    
    _selectDay = _nowDay;
    
    //获取当前年、上年、下一年，所有的月、周、天
    [self getDateWithYear:_nowYear WithMonth:_nowMonth];

}

//每次刷新界面时都需要重新计算年月日星期
- (void)getDateWithYear:(int)year WithMonth:(int)month{
    
    
    _currentYear = [self getYearWithYear:year WithMonth:month]; //当前年
    _currentMonth = [self getMonthWithMonth:month]; //当前月
    _currentWeek = [self getWeekWithYear:_currentYear WihtMonth:_currentMonth WithDay:1]; //当前月1号是周几
    _currentMonthArr = [self getDayArrayWithYear:_currentYear WithMonth:_currentMonth]; //当前月所有的天数
    
    NSLog(@"当前时间==%@",[NSString stringWithFormat:@"%d年%d月",_currentYear,_currentMonth]);
    
    //切换月的时候，回调出去，展示当前所在的是几月
    NSString *currentMonth = [NSString stringWithFormat:@"%d月份",_currentMonth];
    self.showMonthBlock(currentMonth);
    
    _lastYear = [self getYearWithYear:_currentYear WithMonth:_currentMonth-1];
    _lastMonth = [self getMonthWithMonth:_currentMonth-1];
    _lastWeek = [self getWeekWithYear:_lastYear WihtMonth:_lastMonth WithDay:1];
    _lastMonthArr = [self getDayArrayWithYear:_lastYear WithMonth:_lastMonth];
    
    _nextYear = [self getYearWithYear:_currentYear WithMonth:_currentMonth+1];
    _nextMonth = [self getMonthWithMonth:_currentMonth+1];
    _nextWeek = [self getWeekWithYear:_nextYear WihtMonth:_nextMonth WithDay:1];
    _nextMonthArr = [self getDayArrayWithYear:_nextYear WithMonth:_nextMonth];
}


@end
