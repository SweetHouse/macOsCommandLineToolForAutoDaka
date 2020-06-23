#import <Foundation/Foundation.h>
///键盘
void keyboardClick(int keyCode,CGEventFlags flags){
    CGEventRef keyDown = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keyCode, true);
    CGEventRef keyUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keyCode, false);
    if (flags) {
        CGEventRef commandUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)55, false);
        CGEventRef controlUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)59, false);
        CGEventSetFlags(keyDown, flags);
        CGEventSetFlags(keyUp, flags);
        CGEventPost(kCGSessionEventTap, keyDown);
        CGEventPost(kCGSessionEventTap, keyUp);
        CGEventPost(kCGSessionEventTap, commandUp);//谜之keyUp，用完flag需要弹起
        CGEventPost(kCGSessionEventTap, controlUp);//谜之keyUp，用完flag需要弹起
        CFRelease(keyDown);
        CFRelease(keyUp);
        sleep(1);
    }else{
        CGEventPost(kCGSessionEventTap, keyDown);
        CGEventPost(kCGSessionEventTap, keyUp);
        CFRelease(keyDown);
        CFRelease(keyUp);
    }
    
}
///命令行
void runCommandLine(NSString * commandLine){
    FILE *pipe = popen([commandLine cStringUsingEncoding: NSASCIIStringEncoding], "r+");
    pclose(pipe);
}
///鼠标
void mouseClick(CGEventRef theEvent){
    CGEventPost(kCGHIDEventTap, theEvent);
    CGEventSetType(theEvent, kCGEventLeftMouseUp);
    CGEventPost(kCGHIDEventTap, theEvent);
    CGEventSetIntegerValueField(theEvent, kCGMouseEventClickState, 2);
    CGEventSetType(theEvent, kCGEventLeftMouseDown);
    CGEventPost(kCGHIDEventTap, theEvent);
    CGEventSetType(theEvent, kCGEventLeftMouseUp);
    CGEventPost(kCGHIDEventTap, theEvent);
}
///功能
void autoDaka(){
    ///点击登录
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, CGPointMake(1318, 471), kCGMouseButtonLeft);
    mouseClick(theEvent);
    sleep(5);
    ///打
    theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, CGPointMake(1337, 221), kCGMouseButtonLeft);
    mouseClick(theEvent);
    sleep(5);
    ///退出登录
    theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, CGPointMake(2025, 130), kCGMouseButtonLeft);
    mouseClick(theEvent);
    sleep(5);
    CFRelease(theEvent);
    ///关闭浏览器
    runCommandLine(@"pkill firefox");
    sleep(5);
    ///打开图片
    runCommandLine(@"open /Users/w9005556/Desktop/black.png");
    sleep(5);
    keyboardClick(3, kCGEventFlagMaskCommand ^ kCGEventFlagMaskControl);
}
///主函数
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ///选择任务
        printf("请输入任务类型?(回车任务执行):\n1:自动点点啥\n2:间隔时间打开某程序(如每15分钟打开TeamTalk查看消息)\n");
        BOOL selectOK = false;//输入正确否
        int selectType = 0;//输入类型
        while (selectOK == false) {
            char c;
            c = getchar();
            if (c == '1') {
                selectOK = true;
            }else if (c == '2'){
                selectOK = true;
            }else if (c != '\n'){
                selectOK = false; printf("无效输入，请重试:\n");
            }
            selectType = c - '0';///ASCII转int
        }
        ///执行任务
        switch (selectType) {
            case 1:
                {
                    ///关闭浏览器
                    runCommandLine(@"pkill firefox");
                    ///关闭图片
                    runCommandLine(@"pkill Preview");
                    ///打开图片
                    runCommandLine(@"open /Users/w9005556/Desktop/black.png");
                    sleep(10);
                    keyboardClick(3, kCGEventFlagMaskCommand ^ kCGEventFlagMaskControl);//全屏
                    ///随机分秒
                    int randomMin,randomSec;
                    randomMin = arc4random()%20 + 40;
                    randomSec = arc4random()%60;
                    sleep(3);
                    ///轮询判断
                    while (1) {
                        sleep(1);
                        struct tm *p;
                        time_t ptime;
                        time(&ptime);
                        p = gmtime(&ptime);
                        int currentHour,currentMin,currentSec;
                        currentHour = p->tm_hour + 8;
                        currentMin = p->tm_min;
                        currentSec = p->tm_sec;
                        if (((currentHour == 8)&&(currentMin == randomMin)&&(currentSec == randomSec))||((currentHour == 19)&&(currentMin == randomMin)&&(currentSec == randomSec))) {
                            ///关闭图片
                            runCommandLine(@"pkill Preview");
                            sleep(3);
                            runCommandLine(@"open -a \"/Applications/firefox.app\" --args  --kiosk  'https://oms.myoas.com'");
                            sleep(30);
                            autoDaka();
                            //重新生成随机分秒
                            randomMin = arc4random()%20 + 40;
                            randomSec = arc4random()%60;
                        }
                    }
                }
                break;
            case 2:
                {
                    printf("任务已开始,control+c终止任务");
                    while (1) {
                        runCommandLine(@"open /Applications/TeamTalk.app");
                        sleep(3);
                        keyboardClick(48, kCGEventFlagMaskCommand);//切回当前程序
                        sleep(1800);
                    }
                    
                }
                break;
            default:
                break;
        }
    }
    return 0;
}

