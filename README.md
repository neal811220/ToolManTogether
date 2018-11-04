![image](https://github.com/SpockHsueh/ToolManTogether/blob/master/ToolManTogether/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60%402x.png)
# Toolgather App

>### Main concept 
工聚人是款當遇到困擾的事情卻無能為力時，讓你可以透過發出任務來使用他人的生活技能，同時也分享自己的專長來回饋，就此形成一個工具人社群網路。

# The Key function

>### MapKit Annotation add Tap gesture and annotation popup information detail when the user tapped.
![image](https://github.com/SpockHsueh/ToolManTogether/blob/master/IMG_01.PNG) ![image](https://github.com/SpockHsueh/ToolManTogether/blob/master/IMG_02.PNG)
>### Three steps:
>1. Whenever we would like to use one shared resource, we send a request to its semaphore;
>2. Once the semaphore gives us the green light (see what I did here?) we can assume that the resource is ours and we can use it;
>3. Once the resource is no longer necessary, we let the semaphore know by sending him a signal, allowing him to assign the resource to another thread. 
>4. Can think of these request/signal as the resource lock/unlock.

