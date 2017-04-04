Don't know what Zype is? Check this [overview](http://www.zype.com/).

# Zype iOS Template

This is a core Zype iOS project. It is used to provide an API service layer to zype platform and display the data.
An example of fully functional app that is using a Zype sandbox account


### Prerequisites

```
XCode
CocoaPods
```

### Installing

```
1. Clon repo
2. run pod install
3. Open the workspace 
4. Click build and run
```

### Creating new iOS app based of Zype Template

A step by step series of examples that tell you how to get a new app running

```
1. Clon repo
2. removed .git directory
3. open workspace
4. rename project, save
5. close project
6. modify pod file with a new name
7. run pod install
8. open workspace
9. Change bundle identifier for main target
10. Edit Scheme and rename your main scheme
11. Change Fabric script. otherwise the new app will be created under Zype account after running the app with new bundle id
12. remove reference to libs from the old project in project navigator
13. replace app icon
14. change oath key, app_key. 
15. change root_playlist_id
16. change bundle id and run the app. It will create a new app on the Fabric website
17. change bundle name and bundle display name in info plist
18. Update app with your assets
```


## Built With

* [Objective-C](https://en.wikipedia.org/wiki/Objective-C) - Language Objective-C
* [CocoaPods](https://cocoapods.org) - Dependency Management
* [Fabric](https://get.fabric.io/) - Analytics and Crashlitics
* [OneSignal](https://onesignal.com/) - Multiplatform push notifications
* [Zype API](http://dev.zype.com/api_docs/intro/) - Zype API docs

## App Architecture

<a href="https://drive.google.com/uc?export=view&id=0B9aYmGA7O0ZYOEpjUERGd1hJTjQ"><img src="https://drive.google.com/uc?export=view&id=0B9aYmGA7O0ZYOEpjUERGd1hJTjQ" style="width: 500px; max-width: 100%; height: auto" title="Click for the larger version." /></a>

Image made with draw.io and source file can be opened via the follwing link: https://drive.google.com/file/d/0B9aYmGA7O0ZYTFRXaVR2bzU5WGc/view?usp=sharing

## Contributing

Please submit pull requests to us.

## Versioning

For the versions available, see the [tags on this repository](https://github.com/zype/zype-ios/tags). 

## Authors

* **Andrey Kasatkin** - *Initial work* - [Svetliy](https://github.com/svetdev)

See also the list of [contributors](https://github.com/zype/zype-ios/graphs/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details


