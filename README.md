# MyPhoto

![alt text][ScreenShot]

[ScreenShot]: https://github.com/1ryberr/MyPhoto/blob/master/IMG_142D4DEBCFBA-1.jpeg

# What the application does.
> When the application first launches the onboard GPS gets the current location. Once the current location is obtained, temperature data is download from the Weather App API while simultaneously photos based on current location are downloaded from Flickr to a collection view. Starting from top to bottom and left to right there is a search text field where you can put city and state or city and country to search for weather data and photos according to that location. When you type in your location simply press the intuitively placed search button. You should see your weather data displayed along with its labels to the left on the top red view. If you believe your location has changed or you just want to see different photos then update it with collectionview pull to refresh and it will use your devices GPS to update the location and acquire weather and photo data. If there are more photos the app randomly selects pages to display into the collection view. Sometimes there are no photos and the app will display a no photo label in the collection view. On the bottom left is a button labeled map. When you press map the top red view will change to a map and the button will now be labeled search. The map should show your current locations with a pin annotation and the location city will be centered on the map. The map is interactive and you can choose another location by scrolling the map and long pressing on the new location.  When you do this, you will see a red pin annotation on the map and the photos will update. Pressing the search button you will be able to see your weather data.  In the collection view if you see a photo that, for you, best represents the city you are searching then click on it. A view controller will display from the bottom with a choice to either save the photo along with the city and coordinate data or dismiss it. Dismissing will just dismiss this photo view controller. Saving it will persist the data until you’re ready to delete it and dismiss the view controller . To view your saved data just press the saved city button in the bottom right of the view controller.  A smooth navigation will guide you to a table view.  The cell will display your photo along with your city and the weather data labels. When you would like to know the weather press the accessory button and weather data will download onto the cell. To delete the table view cell swipe right and press delete or swipe right until it deletes on its own.

# How to install the application.
- OSX and Xcode
- clone the repository and  set up a similator or sideload app on to a device 
