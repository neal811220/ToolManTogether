![image](https://github.com/SpockHsueh/ToolManTogether/blob/master/ToolManTogether/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60%402x.png)
# Toolgather App

>### Main concept 
工聚人是款當遇到困擾的事情卻無能為力時，讓你可以透過發出任務來使用他人的生活技能，同時也分享自己的專長來回饋，就此形成一個工具人社群網路。

# The Key function

>### MapKit Annotation add Tap gesture and annotation popup information detail when the user tapped.
![image](https://github.com/SpockHsueh/ToolManTogether/blob/master/IMG_01.PNG) ![image](https://github.com/SpockHsueh/ToolManTogether/blob/master/IMG_02.PNG)
>### Three steps:
>1. 我們可以透過 MapKit 本身提供的方法來拿到使用者點擊了哪個 Annotation，同時拿到該點的經緯度資料，進行後續動作。
```javascript
func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
  
        guard let coordinate = view.annotation?.coordinate else {
            return
        }
        
        animateViewUp()
        .....
        ...
    }
```

>2. 將手勢加到地圖上，讓使用者點擊其他地方可以將任務詳細頁面
縮回。
```javascript
  func addTap(taskCoordinate: CLLocationCoordinate2D) {
        guestMode()
        let mapTap = UITapGestureRecognizer(target: self, action: #selector(animateViewDown))
        mapView.addGestureRecognizer(mapTap)
  }
```
>3. 資訊詳細頁面的動畫效果，我們可以透過動態調整該 view 的高來達到彈出又隱藏的動畫效果。
