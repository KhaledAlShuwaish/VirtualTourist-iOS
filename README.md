# VirtualTourist - Final Project

This app allows users specify travel locations around the world, and create virtual photo albums for each location. The locations and photo albums will be stored in Core Data.



## View Controller
The application contains two View Controller

**Travel Locations Map View** :   The user can add a pin anywhere in the map and save it directly in the Core Data.

**Photo Album View** :   After adding a pin on the map, the user can see all the special pictures in place of the pin position, and where the images are updated or deleted, the images are saved automatically in the Core Data.



## Technologies used
In this application we used the network, the database.

*Network* : We used the API provided by Flickr, this api provides us with pictures of the world's , where once the pin is pinned anywhere in the map many data is pulled from the images.


*Core Data* : Is a local database, through which entities are created and attributes are added within. It can establish relationships between entities. You can add, delete, or update your database.


## Value added by the developer in this project

1- The user can save the pictures in the photo album in his phone or share it with his friends.

2- In this project I added a function through which to know the status of the Internet connection in the device, and notify the user in the absence of Internet connection.

3- Show the download mark at the time of loading images from the API.




