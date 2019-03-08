
import { NativeModules } from 'react-native';

const { RNReactLogging } = NativeModules;

export default {
  printLog: function (content: string) {
    RNReactLogging.printLog(content);
  },
  setTag: function (tag: string) {
    RNReactLogging.setTag(tag);
  },
  setConsoleLogEnabled: function (enabled: boolean) {
    RNReactLogging.setConsoleLogEnabled(enabled);
  },
  setFileLogEnabled: function (enabled: boolean) {
    RNReactLogging.setFileLogEnabled(enabled);
  },
  setMaxFileSize: function (size: number) {
    RNReactLogging.setMaxFileSize(size);
  },
  listAllLogFiles: function (): Promise {
    return RNReactLogging.listAllLogFiles();
  },
};
