# Skyvision
Skyvision is a weather app that uses the new Apple Weather Services API called **WeatherKit**, introduced in WWDC22. 
Moreover, it provides widgets for lockscreen, aka accessory widgets, also introduced this year in iOS16.

# Purpose
This app is a demonstration on how to get started with WeatherKit API and how to use the new accessory widgets who periodically reload their content.

Other topics touched:
- Reload widgets via timeline configuration
- Rely on Intent configuration, because user should be able to choose the location for which he wants to see the weather details
- Deeplink URL from widgets to main app

# Explore
![App Flow](https://www.simpleimageresizer.com/_uploads/photos/546a3772/image_3_50.png)

[App demo here](https://streamable.com/qkhcot)

# Note
By default, the app/widget uses the user's current location for displaying the weather. 
In order to change this, in the app you can search for various locations and for the widgets it is fully customizable because it relies on intent configuration.

Xcode 14 required.

[WeatherKit](https://developer.apple.com/videos/play/wwdc2022/10003/)

[Complications and widgets](https://developer.apple.com/videos/play/wwdc2022/10050/)
