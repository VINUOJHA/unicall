uniCall is VOIP Mobile Application using pjsip for iOS platform.

Application Architecture Summary:
The essence class in the uniCall iPhone application is uniCallAppDelegate which is a singleton delegated from UIApplication. uniCallAppDelegate contains an instance of all the other classes. Once the program is started the uniCallAppDelegate creates the instances and the views, checks if the device is connected to the internet using Reachaility class and checks if it is possible to retrieve the device location using LocationManager class. After that the program registers with the server. UniCallManager class, is a utility class, acts as a middleware application between uniCallAppDelegate and PJSUAManager, there is no direct connection between the last two. PJSUAManager is a program written in C language, which contains all the API for the PJLib library, the only connection of this program is with UniCallManager. Finally, the SQLite database is only to store the call history, and it’s called only by the uniCallAppDelegate and HistoryController.

To view the application screenshots, visit: http://aspspider.info/unicall/Tutorial.aspx#iphone

The project was done based on PJSIP library (http://www.pjsip.org/).