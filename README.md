# react-native-file-log
Write log to file for React native app.

## Getting started

`$ npm install react-native-file-log --save`

### Mostly automatic installation

`$ react-native link react-native-file-log`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` -> `Add Files to [your project's name]`
2. Go to `node_modules` -> `react-native-file-log` and add `RNReactLogging.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNReactLogging.a` to your project's `Build Phases` -> `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNReactLoggingPackage;` to the imports at the top of the file
  - Add `new RNReactLoggingPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-file-log'
  	project(':react-native-file-log').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-file-log/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-file-log')
  	```


## Usage
```javascript
import RNReactLogging from 'react-native-file-log';

RNReactLogging.setTag('MyAppName'); // default: RNReactLogging
RNReactLogging.setConsoleLogEnabled(false); // default: true
RNReactLogging.setFileLogEnabled(true); // default: false
RNReactLogging.setMaxFileSize(1024 * 1024); // default: 512 * 1024 ~ 512 kb
RNReactLogging.printLog('test log');
RNReactLogging.listAllLogFiles().then(paths => {
    // do something with list of paths
});
``` 
