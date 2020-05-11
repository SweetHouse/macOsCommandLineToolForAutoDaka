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
    }else{
        CGEventPost(kCGSessionEventTap, keyDown);
        CGEventPost(kCGSessionEventTap, keyUp);
        CFRelease(keyDown);
        CFRelease(keyUp);
    }
    
}
///打开文件
void openFile(bool isFullSreen){
    FILE *pipe = popen([@"open /Users/w9005556/Desktop/black.png" cStringUsingEncoding: NSASCIIStringEncoding], "r+");
    pclose(pipe);
    sleep(1);
    if (isFullSreen) {//全屏
        keyboardClick(3, kCGEventFlagMaskCommand ^ kCGEventFlagMaskControl);
    }
}
///打开应用
void openApplication(){
    FILE *pipe = popen([@"open /Applications/TeamTalk.app" cStringUsingEncoding: NSASCIIStringEncoding], "r+");
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
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, CGPointMake(1300, 500), kCGMouseButtonLeft);
    mouseClick(theEvent);
    sleep(5);
    ///点击打卡
    theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, CGPointMake(1333, 250), kCGMouseButtonLeft);
    mouseClick(theEvent);
    sleep(5);
    ///退出登录
    theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, CGPointMake(2020, 155), kCGMouseButtonLeft);
    mouseClick(theEvent);
    sleep(5);
    CFRelease(theEvent);
    openFile(true);//打开文件
}
///主函数
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ///选择任务
        printf("请输入任务类型?(回车任务执行):\n1:自动打卡\n2:间隔时间打开某程序(如每15分钟打开TeamTalk查看消息)\n");
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
                    sleep(1);
                    openFile(true);//打开文件
                    ///轮询判断
                    while (1) {
                        sleep(1);
                        struct tm *p;
                        time_t ptime;
                        time(&ptime);
                        p = gmtime(&ptime);
                        int hour,min,sec;
                        hour = p->tm_hour + 8;
                        min = p->tm_min;
                        sec = p->tm_sec;
                        if (((hour == 9)&&(min == 0)&&(sec == 0))||((hour == 19)&&(min == 0)&&(sec == 0))) {
                            keyboardClick(13, kCGEventFlagMaskCommand);//关闭文件
                            sleep(1);
                            autoDaka();
                            printf("成功:%d:%d:%d\n",p->tm_hour + 8,p->tm_min,p->tm_sec);
                        }
                    }
                }
                break;
            case 2:
                {
                    while (1) {
                        openApplication();
                        sleep(2);
                        keyboardClick(48, kCGEventFlagMaskCommand);//切回当前程序
                        sleep(150);
                    }
                    
                }
                break;
            default:
                break;
        }
    }
    return 0;
}

