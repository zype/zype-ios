# Zype iOS Template

Steps to build an app using Zype template:
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
