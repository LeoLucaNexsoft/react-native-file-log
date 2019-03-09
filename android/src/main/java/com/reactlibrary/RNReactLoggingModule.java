
package com.reactlibrary;

import android.util.Log;
import android.os.Environment;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableNativeArray;

import java.io.File;
import java.io.FileWriter;
import java.io.FilenameFilter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Date;
import java.util.Locale;

import javax.annotation.Nullable;

public class RNReactLoggingModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;
    private String tag = "RNReactLogging";
    private boolean consoleLog = true;
    private boolean fileLog = false;
    private long maxFileSize = 512 * 1024; // 512 kb

    public RNReactLoggingModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNReactLogging";
    }

    @ReactMethod
    public void printLog(String content) {
        if (consoleLog) {
            Log.d(tag, content);
        }
        if (fileLog) {
            writeLogToFile(content);
        }
    }

    @Nullable
    File createLogFile(File folder, String name) {
        File f = new File(folder, name);
        try {
            if (f.createNewFile()) {
                return f;
            }
            return null;
        } catch (Exception e) {
            return null;
        }
    }


    void writeLogToFile(String content) {
        File logDirectory = new File( Environment.getExternalStorageDirectory() + "/AeffeCQ" );
        File logFolder = new File(logDirectory + "/log");

        // create app folder
        if ( !logDirectory.exists() ) {
            logDirectory.mkdir();
        }

        // create log folder
        if ( !logFolder.exists() ) {
            logFolder.mkdir();
        }

        if (!logFolder.exists() && !logFolder.mkdir()) {
            return;
        }

        // get latest log file
        File[] logFiles = logFolder.listFiles(new FilenameFilter() {
            @Override
            public boolean accept(File file, String name) {
                return name.startsWith("log") && name.endsWith(".txt");
            }
        });
        File logFile;
        if (logFiles.length == 0) {
            logFile = createLogFile(logFolder, "log0.txt");
        } else {
            // sort files by name
            Arrays.sort(logFiles, new Comparator<File>() {
                @Override
                public int compare(File a, File b) {
                    String fileName1 = a.getName().replaceAll("log|\\.txt", "");
                    String fileName2 = a.getName().replaceAll("log|\\.txt", "");
                    try {
                        int file1 = Integer.parseInt(fileName1);
                        int file2 = Integer.parseInt(fileName2);
                        return file1 - file2;
                    } catch (Exception e) {
                        Log.e("Error parse int", e.getMessage());
                    }
                    return 0;
                }
            });
            File lastLogFile = logFiles[logFiles.length - 1];
            if (lastLogFile.length() < maxFileSize) {
                logFile = lastLogFile;
            } else {
                int newNumber = Integer.parseInt(lastLogFile.getName().replaceAll("log|\\.txt", "")) + 1;
                logFile = createLogFile(logFolder, "log" + newNumber + ".txt");
            }
        }
        if (logFile == null) {
            Log.e(tag, "Cannot create log file");
            return;
        }
        try {
            FileWriter fw = new FileWriter(logFile, true);
            String currentTime = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss", Locale.getDefault()).format(new Date());
            fw.write(tag + " - " + currentTime + " - " + content);
            fw.append("\n");
            fw.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void setTag(String tag) {
        this.tag = tag;
    }

    @ReactMethod
    public void setConsoleLogEnabled(boolean enabled) {
        this.consoleLog = enabled;
    }

    @ReactMethod
    public void setFileLogEnabled(boolean enabled) {
        this.fileLog = enabled;
    }

    @ReactMethod
    public void setMaxFileSize(long maxFileSize) {
        this.maxFileSize = maxFileSize;
    }

    @ReactMethod
    public void listAllLogFiles(Promise promise) {
        File logFolder = new File(this.reactContext.getFilesDir().getAbsolutePath() + "/rn-loggings");
        WritableArray result = new WritableNativeArray();
        if (!logFolder.exists() && !logFolder.mkdir()) {
            promise.reject(result);
            return;
        }
        File[] logFiles = logFolder.listFiles(new FilenameFilter() {
            @Override
            public boolean accept(File file, String name) {
                return name.startsWith("log") && name.endsWith(".txt");
            }
        });
        for (int i = 0; i < logFiles.length; i++) {
            result.pushString(logFiles[i].getAbsolutePath());
        }
        promise.resolve(result);
    }

}
