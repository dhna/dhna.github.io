---
layout: post
title: "GooglePlayService를 사용하는데 IncompatibleClassChangeError 오류는 왜 발생 하는가?"
quote: "앱과 라이브러리에서 참조한 GooglePlayService의 버전 차이에 따른 호환성 문제를 살펴봅니다."
image: false
video: false
comments: true
---

제가 개발하고 있는 앱에서는 GooglePlayService로 제공되는 GoogleAnalytics와  GoogleAds 등을 사용하고 있었습니다. 여기에 좀 더 효율적인 마케팅을 위해서 Moloco 서비스를 도입하기로 했고 그에 따라 라이브러리를 추가하게 되었습니다.
그러나 해당 라이브러리를 추가한 후 아래와 같은 오류가 발생했습니다.

<br/>

## Exception
~~~
E/AndroidRuntime: FATAL EXCEPTION: main
    Process: com.dhna.sampleapp, PID: 20003
    java.lang.IncompatibleClassChangeError: 
        The method 'boolean com.google.android.gms.common.api.GoogleApiClient.isConnected()'
        was expected to be of type interface but instead was found to be of type virtual 
        (declaration of 'com.moloco.van.context.MolocoContext' appears in /data/app/com.dhna.sampleapp-1/base.apk)
    at com.moloco.van.context.MolocoContext.init(MolocoContext.java:98)
    at com.moloco.van.context.MolocoEntryPoint.init(MolocoEntryPoint.java:67)
    at com.dhna.sampleapp.analytics.moloco.Moloco.init(Moloco.java:19)
    at com.dhna.sampleapp.base.BDApplication.initAnalytics(AppApplication.java:156)
    at com.dhna.sampleapp.base.BDApplication.init(AppApplication.java:133)
    at com.dhna.sampleapp.base.BDApplication.onCreate(AppApplication.java:123)
    at android.app.Instrumentation.callApplicationOnCreate(Instrumentation.java:1036)
    at android.app.ActivityThread.handleBindApplication(ActivityThread.java:6316)
    at android.app.ActivityThread.access$1800(ActivityThread.java:221)
    at android.app.ActivityThread$H.handleMessage(ActivityThread.java:1860)
    at android.os.Handler.dispatchMessage(Handler.java:102)
    at android.os.Looper.loop(Looper.java:158)
    at android.app.ActivityThread.main(ActivityThread.java:7224)
    at java.lang.reflect.Method.invoke(Native Method)
    at com.android.internal.os.ZygoteInit$MethodAndArgsCaller.run(ZygoteInit.java:1230)
    at com.android.internal.os.ZygoteInit.main(ZygoteInit.java:1120)
~~~

IncompatibleClassChangeError는 왜 발생했을까요?
이 해답을 알기 위해서 먼저 이 Exception이 무엇인지 확인해봤습니다.

<br/>

## IncompatibleClassChangeError
IncompatibleClassChangeError는 같은 클래스에서 양립할 수 없는 변경사항이 있을 때 발생합니다. 예를 들어 아래와 같은 경우들이 있습니다.

1. Non-static 필드를 static 필드로 변경한 경우
2. Class를 interface로 변경한 경우
3. Interface를 class로 변경한 경우
4. ...

IncompatibleClassChangeError가 언제 발생하는지는 알았지만 이 Exception이 왜 발생하고 있는지에 대한 답은 아닙니다.
그래서 구글에서 "GooglePlayService + IncompatibleClassChangeError" 키워드로 검색해보았고 GooglePlayService v8.1에서 오류가 발생할 수 있다는 걸 알게 되었습니다.
좀 더 확실히 하기 위해서 GooglePlayService의 ReleaseNote를 확인해봤습니다.

<br/>

## GooglePlayService v8.1 ReleaseNote
GooglePlayService v8.1 버전에서 아래와 같은 [변경 이력](https://developers.google.com/android/guides/releases#september_2015_-_v81)이 포함되어 있습니다.

{% include image.html url="/media/2016-09-17-playservice-incompatibleclasschangeerror/playservice-v8.1-changelog.png" width="100%" %}

<br/>

## 결론

ReleaseNote를 보고 GooglePlayService v8.1 버전에서 GoogleApiClient가 interface에서 abstract class로 변경되는 것을 알았습니다. 처음 언급했던 Exception 로그를 살펴보면 'isConnected() 메소드가 interface 타입이여야 하는데 virtual 타입의 메소드이다'라는 설명도 보았습니다. 즉, GoogleApiClient의 타입이 변경되면서 발생한 호환성 문제라고 볼 수 있습니다.

이 문제를 해결하려면
 (1) Moloco 라이브러리가 사용하고 있는  GooglePlayService 버전을 v8.1 이상으로 올리거나
 (2) 앱에서 사용하고 있는 GooglePlayService 버전을 v8.1 미만으로 낮추어야 합니다.

해결방법이 허무하지만, 저는 이 문제를 Moloco 측에 GooglePlayService 최신 버전 대응을 요청하여 해결하였습니다.
