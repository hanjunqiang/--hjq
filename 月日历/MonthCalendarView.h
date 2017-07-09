/** 
 
    流程：一个UIScrollView中放了三个UICollectionView.(上月、当前月、下月)，
     UIScrollView默认偏移一个屏幕宽度，展示当前月。
 
 */


#import <UIKit/UIKit.h>

typedef void(^SelectBlock)(NSString *dateStr);
typedef void(^ShowMonthBlock)(NSString *month);
@interface MonthCalendarView : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UIAlertViewDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    BOOL isCan;
    int _selectMonth;
    int _selectItem;
    int _selectDay;
    NSArray *_weekArray;
    NSMutableArray *_currentMonthArr;
    NSMutableArray *_lastMonthArr;
    NSMutableArray *_nextMonthArr;
    int _nowYear;
    int _nowMonth;
    int _nowDay;
    int _currentYear;
    int _lastYear;
    int _nextYear;
    int _currentMonth;
    int _lastMonth;
    int _nextMonth;
    int _currentWeek;
    int _lastWeek;
    int _nextWeek;
    
    NSMutableArray *_allDayArr;//三个月
    
    UIScrollView *_bgScrollView;
    UIScrollView *_calendarSV;
    UICollectionView *_currentMonthCV;
    UICollectionView *_lastMonthCV;
    UICollectionView *_nextMonthCV;
    
    UICollectionView *_smallCalendar;
    NSMutableArray *_smallDayArr;
    BOOL _isShow;
    BOOL _isTop;
    
    CGFloat _selectOriginY;
    
    UIImageView *_arrowImg;
    NSMutableArray *_allDataArr;
    NSMutableArray *_showArray;
    BOOL _isHistory;
}

@property (nonatomic, strong) NSString *dateStr;  //展示指定的日期

@property (nonatomic, strong) NSString *isChangeStr; //1:有改变

@property (nonatomic, copy) SelectBlock selectBlock; //选中日期回调
@property (nonatomic, copy) ShowMonthBlock showMonthBlock; //当前展示的月份

-(void)jq_initialData; //因为有时候initWithFrame初始化时，dateStr还没赋值。
-(void)jq_changeDate;


@end
