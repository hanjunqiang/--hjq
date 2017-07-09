
//
//  WeekCalendarView.m
//  MyOCCalendar
//
//  Created by 韩军强 on 2017/6/13.
//  Copyright © 2017年 韩军强. All rights reserved.
//

#import "WeekCalendarView.h"

@implementation WeekCalendarView


-(void)jq_initialData
{
    self.backgroundColor=[UIColor whiteColor];
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height - 64;

    _allDataArr = [[NSMutableArray alloc] init];
    //    for (int i = 0; i < 12; i ++) {
    //        NSDictionary *dic = [NSDictionary dictionaryWithObject:@"12345" forKey:[NSString stringWithFormat:@"13"]];
    //        [_allDataArr addObject:dic];
    //    }
    
    [self addWeekView];
    [self nowDate];
    [self addBackgroundScrollView];
    [self addSmallCalendarView];
    
    _selectMonth = _nowMonth;
    
    NSLog(@"_smallDayArr=%@",_smallDayArr);
    NSLog(@"_selectDay=%d",_selectDay);
    
    //计算当前天的位置偏移量
    [self calculateCurrentDayContentOffset];
}

#pragma mark - 计算当前天的偏移位置
-(void)calculateCurrentDayContentOffset
{
    
    NSInteger index =0;
    for (NSString *string in _smallDayArr) {
        
        NSArray *array = [string componentsSeparatedByString:@"-"];
        int month = [[array firstObject] intValue];
        //        int day = [[array lastObject] intValue];
        
        NSString *str = [NSString stringWithFormat:@"%02d-%02d",month,_selectDay];
        if ([_smallDayArr containsObject:str]) {
            //对象所在的位置，注意：要和containsObject方法配合使用
            index = [_smallDayArr indexOfObject:str];
        }
        
    }
    
    NSLog(@"index===%d",index);
    
    
    NSLog(@"index/7==%d",index/7);
    
    //计算当前天所在的偏移量为几个屏幕宽度（因为这里是整页滚动的所以这里不能用滚动到某个位置的方法。）
    CGPoint point = _smallCalendar.contentOffset;
    point.x = screenWidth*(index/7);
    _smallCalendar.contentOffset = point;
    
}

//这个界面的背景
- (void)addBackgroundScrollView{
    
    _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,30,screenWidth,screenWidth/7)];
    _bgScrollView.contentSize = CGSizeMake(screenWidth, screenHeight+(screenWidth/7*5));
    _bgScrollView.bounces = false;
    _bgScrollView.delegate = self;
    _bgScrollView.showsVerticalScrollIndicator = false;
    _bgScrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:_bgScrollView];
    
    [self addCalendarBackgroundScrollView];
}

- (void)addWeekView{
    
    _weekArray = @[@"周六",@"周日",@"周一",@"周二",@"周三",@"周四",@"周五"];
    CGFloat width = (screenWidth/7);
    for (int i = 0; i < 7; i ++) {
        UILabel *label;
        if (UI_IS_IPHONE6PLUS) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(6+width*i,0,width-2,30)];
        }else if (UI_IS_IPHONE5)
        {
            label = [[UILabel alloc] initWithFrame:CGRectMake(width*i,0,width-1,30)];
        }else
        {
            label = [[UILabel alloc] initWithFrame:CGRectMake(width*i,0,width,30)];
        }
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
- (void)addCalendarBackgroundScrollView{
    
    _calendarSV = [[UIScrollView alloc]initWithFrame:CGRectMake(0,30,screenWidth,(screenWidth)/7*1)];
    _calendarSV.contentSize = CGSizeMake(screenWidth*3, (screenWidth)/7*6);
    _calendarSV.backgroundColor = [UIColor clearColor];
    _calendarSV.delegate = self;
    _calendarSV.pagingEnabled = true;
    _calendarSV.bounces = false;
    _calendarSV.showsHorizontalScrollIndicator = false;
    _calendarSV.contentOffset = CGPointMake(screenWidth, 0);
    [_bgScrollView addSubview:_calendarSV];
    
    [self addCurrentMouthCollectionView];
    [self addLastMouthCollectionView];
    [self addNextMouthCollectionView];
}

//刷新所有的日历(可在此优化)
- (void)reloadAllDate{
    
    [_currentMonthCV reloadData];
    [_lastMonthCV reloadData];
    [_nextMonthCV reloadData];
    [_smallCalendar reloadData];
}

//初始化当前显示月的日历
- (void)addCurrentMouthCollectionView{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((screenWidth)/7, (screenWidth)/7);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _currentMonthCV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 30, screenWidth, screenWidth/7) collectionViewLayout:layout];
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
    
    _lastMonthCV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 30, screenWidth, screenWidth/7) collectionViewLayout:layout];
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
    
    _nextMonthCV = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 30, screenWidth, screenWidth/7) collectionViewLayout:layout];
    _nextMonthCV.dataSource = self;
    _nextMonthCV.delegate = self;
    _nextMonthCV.backgroundColor = [UIColor clearColor];
    [_nextMonthCV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [_calendarSV addSubview:_nextMonthCV];
}

//初始化周日历
- (void)addSmallCalendarView{
    
    [self getSmallDayArray];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((screenWidth)/7, (screenWidth)/7);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _smallCalendar = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 30, screenWidth, screenWidth/7) collectionViewLayout:layout];
    _smallCalendar.dataSource = self;
    _smallCalendar.delegate = self;
    _smallCalendar.pagingEnabled = true;
    _smallCalendar.showsHorizontalScrollIndicator = NO;
    _smallCalendar.backgroundColor = [UIColor whiteColor];
    [_smallCalendar registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    
    [self addSubview:_smallCalendar];
}



//处理展示周日历时的坐标
- (void)showSmallCalendar{
    
    CGRect rect = _smallCalendar.frame;
    rect.size.height = (screenWidth)/7+1;
    _smallCalendar.frame = rect;
    
    CGPoint point = _smallCalendar.contentOffset;
    point.x = screenWidth;
    _smallCalendar.contentOffset = point;
    
    CGPoint TVPoint = _bgScrollView.contentOffset;
    TVPoint.y = (screenWidth)/7*5;
    _bgScrollView.contentOffset = TVPoint;
    _arrowImg.image = [UIImage imageNamed:@"slide down icon"];
}

//处理隐藏周日历时的坐标
- (void)hideSmallCalendar{
    
    CGRect rect = _smallCalendar.frame;
    rect.size.height = 0;
    _smallCalendar.frame = rect;
    
    CGPoint point = _bgScrollView.contentOffset;
    point.y = 0;
    _bgScrollView.contentOffset = point;
    _arrowImg.image = [UIImage imageNamed:@"slide up icon"];
}

//周日历固定21天,月日历统一42天(根据实际的天数显示)
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (collectionView == _smallCalendar) {
        return 21;
    }else{
        return 7*6;
    }
}

//加载日历的日期
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [cell.contentView viewWithTag:10];
    [label removeFromSuperview];
    

    [self LabelWithView:cell.contentView WithIndex:indexPath.item];
    
    return cell;
}


-(void)jq_changeDate
{
    self.isChangeStr = @"1";
    [self collectionView:_smallCalendar didSelectItemAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
}

//处理选中日期,
//当前为周日历,并且周日历显示两个月份的日期时(6月,7月),若由6月的日期选到7月的日期,在刷新界面的时候,同时需要将相应的月份更改掉;也许在此做处理.
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSString *dayString = nil;
    if (collectionView == _smallCalendar) {
        
        int month;
        
        //选择指定日期
        if ([self.isChangeStr intValue]) {
            self.isChangeStr = @"0";
            
            
            NSArray *array = [self.dateStr componentsSeparatedByString:@"-"];
            int year = [array[0] intValue];
            _currentYear = year; //当前年（没具体分析，暂无问题）
            month = [array[1] intValue];  //选中的月
            _currentMonth = month;
            
            //因为选择了指定的日期，所以这里要重新刷新数据，特别是为了刷新当前应该展示的_smallDayArr
            [self getDateWithYear:year WithMonth:month];
            [self getSmallDayArray];
            [self reloadAllDate];
            _selectItem = [array[2] intValue]; //选中的天
            _selectDay = [array[2] intValue];
            
        }else
        {
            
            
            //判断当前点击的时间是否可以点击(手动调用点击方法不知道选中的哪一行，所以不能调用该方法)
            [self isCanSelect:indexPath];
            
            //这里是当前年中的三个月，没有年
            dayString = _smallDayArr[indexPath.item];
            NSArray *array = [dayString componentsSeparatedByString:@"-"];
            month = [[array firstObject] intValue];  //选中的月
            _selectItem = [[array lastObject] intValue]; //选中的天
            _selectDay = [[array lastObject] intValue];
        }
        
        //        _selectDay = _selectItem; //_selectDay即为选中的天
        
        
        //这里或根据当前的年月，计算出当前的年！
        if (_currentMonth > month) {
            if (_currentMonth == 12) {
                _selectItem = _selectItem + _nextWeek-2;
                [self getDateWithYear:_currentYear WithMonth:_currentMonth+1];
            }else{
                _selectItem = _selectItem + _lastWeek-2;
                [self getDateWithYear:_currentYear WithMonth:_currentMonth-1];
            }
        }else if (_currentMonth == month){
            //这里本来是-2（-1时，点击周六会翻页，-2时，点击日期不会翻页，自行测试吧）
            _selectItem = _selectItem + _currentWeek-2;

        }else{
            if (month == 12) {
                _selectItem = _selectItem + _lastWeek-2;
                [self getDateWithYear:_currentYear WithMonth:_currentMonth-1];
            }else{
                _selectItem = _selectItem + _nextWeek-2;
                [self getDateWithYear:_currentYear WithMonth:_currentMonth+1];
            }
        }

        
        NSLog(@"选中的时间为=%@",[NSString stringWithFormat:@"%d:%d:%d",_currentYear,month,_selectDay]);
        NSString *dateStr = [NSString stringWithFormat:@"%02d-%02d-%02d",_currentYear,month,_selectDay];
        self.selectBlock(dateStr); //回调选中的日期
        
        [self getSmallDayArray];
    }else{
        if (indexPath.item >= _currentWeek-1 && indexPath.item <= _currentMonthArr.count-1+_currentWeek-1) {
            _selectItem = (int)indexPath.item;
            _selectOriginY = (indexPath.item/7)*((screenWidth)/7);
            dayString = _currentMonthArr[indexPath.item - (_currentWeek-1)];
            _selectDay = [[[dayString componentsSeparatedByString:@"-"] lastObject] intValue];
        }
        [self getSmallDayArray];
    }
    
    //选中的月
    _selectMonth = _currentMonth;
    [_smallCalendar reloadData];
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
        _selectDay = 1;
        if (scrollView.contentOffset.x == 0) {
            [self getDateWithYear:year WithMonth:mouth-1];
        }else if (scrollView.contentOffset.x == screenWidth*2) {
            [self getDateWithYear:year WithMonth:mouth+1];
        }
        _selectItem = _currentWeek;
        [self getSmallDayArray];
        [self reloadAllDate];
        CGPoint point = _calendarSV.contentOffset;
        point.x = screenWidth;
        _calendarSV.contentOffset = point;
        
        //若每次改变月份都要请求新的数据,就在此将旧数据删掉
        //        [_allDataArr removeAllObjects];
    }
    
    NSString *dayString = nil;
    if (scrollView == _smallCalendar) {
        if (scrollView.contentOffset.x>=0 && scrollView.contentOffset.x<=10) {
            dayString = _smallDayArr[0];
            NSArray *array = [dayString componentsSeparatedByString:@"-"];
            //            _selectDay = [[array lastObject] intValue]; //滚动时默认选左1
            _selectItem = [[array lastObject] intValue];
            _selectItem = _selectItem+(_currentWeek-1);
            int nowMouth = [[array firstObject] intValue];
            if (nowMouth != _currentMonth) {
                int year = _currentYear;
                int month = _currentMonth;
                [self getDateWithYear:year WithMonth:month-1];
                //若每次改变月份都要请求新的数据,就在此将旧数据删掉
                //                [_allDataArr removeAllObjects];
                _selectItem = _selectItem+(_currentWeek-1);
            }
        }
        
        if (scrollView.contentOffset.x>=2*(screenWidth-30) && scrollView.contentOffset.x<=2*screenWidth) {
            dayString = _smallDayArr[14];
            NSArray *array = [dayString componentsSeparatedByString:@"-"];
            //            _selectDay = [[array lastObject] intValue]; //滚动时默认选左1
            _selectItem = [[array lastObject] intValue]; //这里要重新赋值
            _selectItem = _selectItem+(_currentWeek-1);
            int nowMouth = [[array firstObject] intValue];
            if (nowMouth != _currentMonth) {
                int year = _currentYear;
                int month = _currentMonth;
                [self getDateWithYear:year WithMonth:month+1];
                //若每次改变月份都要请求新的数据,就在此将旧数据删掉
                //                [_allDataArr removeAllObjects];
                _selectItem = _selectItem+(_currentWeek-1);
            }
        }
        
        [self getSmallDayArray];
        [self reloadAllDate];
        _smallCalendar.contentOffset = CGPointMake(screenWidth, 0);
    }
    
    //    if (scrollView == _bgScrollView) {
    //        if (scrollView.contentOffset.y >= (screenWidth)/5) {
    //            [self showSmallCalendar];
    //        }else{
    //            [self hideSmallCalendar];
    //        }
    //    }
}

//隐藏或显示周日历
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//
//    if (scrollView == _bgScrollView) {
//        if (scrollView.contentOffset.y >= (screenWidth)/5) {
//            [self showSmallCalendar];
//        }else{
//            [self hideSmallCalendar];
//        }
//    }
//}

//显示周日历的日期
- (void)LabelWithView:(UIView *)view WithIndex:(NSInteger)index{
    
    CGFloat value1 = 14;
    CGFloat valueX = 5;
    if (UI_IS_IPHONE6PLUS) {
        value1 = 25;
        valueX = 17;
        
    }else if (UI_IS_IPHONE6)
    {
        value1 = 16;
        valueX = 8;
    }
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(valueX, 0, view.frame.size.width-value1, view.frame.size.height-value1)];
    NSString *string = _smallDayArr[index];
    NSArray *array = [string componentsSeparatedByString:@"-"];
    
    lab.text = [array lastObject];
    lab.textAlignment = 1;
    lab.tag = 10;
    lab.font = [UIFont systemFontOfSize:18];
    
    int month = [[array firstObject] intValue];
    int day = [[array lastObject] intValue];
    
    UIColor *lastColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.8];
    UIColor *nextColor = [UIColor blackColor];
    //选择哪一天
    if (day == _selectDay && month == _selectMonth) { //限定当前月的当前天才显示
        lab.layer.cornerRadius = (view.frame.size.width-value1)/2;
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
                    [self addCellPointWithView:lab];
                    
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
    
    //    for (NSDictionary *dic in _allDataArr) {
    //        NSString *key = [[dic allKeys] firstObject];
    //        if ([key isEqualToString:string]) {
    //            [self addCellPointWithView:lab];
    //        }
    //    }
    [view addSubview:lab];
}




//在日期下面添加点作为标记
- (void)addCellPointWithView:(UIView *)view{
    
    CALayer *layer=[CALayer layer];
    layer.bounds = CGRectMake(0, 0, 5, 5);
    layer.cornerRadius = 5/2;
    layer.position = CGPointMake(((screenWidth)/7)/2+5, 5);
    layer.backgroundColor = [UIColor redColor].CGColor;
    [view.layer addSublayer:layer];
}

//计算相应的年份
- (int)getYearWithYear:(int)year WithMonth:(int)month{
    
    if (month <= 0) {
        year = year - 1;
    }else if (month >= 13) {
        year = year + 1;
    }
    
    return year;
}

//计算相应的月份
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
    int week = (int)[components weekday];  //这里的返回的周，都多了一天。然而在返回的时候是week+1，所以_currentWeek-2，_lastWeek-2，_nextWeek-2.
    
    //最后一天，替换为第一天
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
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    NSMutableArray *dayArray = [[NSMutableArray alloc] init];
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
    
    
    //    }
    _selectDay = _nowDay;
    
    [self getDateWithYear:_nowYear WithMonth:_nowMonth];
    _selectItem = _nowDay + _currentWeek-2; //当前选中的是哪个item，这里的-2，原因是周六、周日在前两列。（）
}

//每次刷新界面时都需要计算年月日星期
- (void)getDateWithYear:(int)year WithMonth:(int)month{
    
    _currentYear = [self getYearWithYear:year WithMonth:month];
    _currentMonth = [self getMonthWithMonth:month];
    _currentWeek = [self getWeekWithYear:_currentYear WihtMonth:_currentMonth WithDay:1];
    _currentMonthArr = [self getDayArrayWithYear:_currentYear WithMonth:_currentMonth];
    //    self.navigationItem.title = [NSString stringWithFormat:@"%d年%d月",_currentYear,_currentMonth];
    
    NSLog(@"当前时间==%@",[NSString stringWithFormat:@"%d年%d月",_currentYear,_currentMonth]);
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

//通过当前三个月的日期,计算出周日历的日期(每次计算三周)
- (void)getSmallDayArray{
    
    if (_allDayArr == nil) {
        _allDayArr = [[NSMutableArray alloc] init];
    }else{
        [_allDayArr removeAllObjects];
    }
    
    if (_smallDayArr == nil) {
        _smallDayArr = [[NSMutableArray alloc] init];
    }else{
        [_smallDayArr removeAllObjects];
    }
    _allDayArr = [[NSMutableArray alloc] init];
    [_allDayArr addObjectsFromArray:_lastMonthArr];
    [_allDayArr addObjectsFromArray:_currentMonthArr];
    [_allDayArr addObjectsFromArray:_nextMonthArr];
    
    int week = _selectItem%7;
    //当当前月的1号是周六时,week=0;若week=0,得到的小日历的日期会增加一周(这里是为了，周六在最后一列放着的时候，点击时，自动滚动下一周，暂时不需要。)
//    if (week == 0) {
//        week = 7;
//    }
    /** 
         _lastMonthArr.count:上个月的总天数
        week:表示当前选中位置，距离周六的天数。
        _currentWeek：表示1号前面有几天没算的item。
        _selectItem：当前月选中的位置。
        -6：展示前一周。
     
         这里是获取三周日期，也就是21天。
     */
    
    //总感觉这里的-1+1是多余的。
//    int first = (int)_lastMonthArr.count-1  +_selectItem+1 -week   -_currentWeek-6;
    int first = (int)_lastMonthArr.count  +_selectItem-week-_currentWeek -6;
    for (int i = first; i < first+21; i ++) {
        NSString *dayStr = _allDayArr[i];
        [_smallDayArr addObject:dayStr];
    }
    [_smallCalendar reloadData];
}





@end
