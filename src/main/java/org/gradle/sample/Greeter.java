package org.gradle.sample;

import java.io.InputStream;
import java.io.FileInputStream;
import org.apache.log4j.LogManager;
import org.apache.commons.io.IOUtils;

public class Greeter {
    public String getGreeting() throws Exception {
        LogManager.getRootLogger().info("generating greeting.");
        InputStream greetingStr = getClass().getResourceAsStream("/greeting.txt");
        try {
            return IOUtils.toString(greetingStr).trim();
        }
        finally {
            greetingStr.close();
        }
    }
    public String getServerip() throws Exception {
        InputStream hostnameStr = new FileInputStream("/etc/hostname");
        try {
            return IOUtils.toString(hostnameStr).trim();
        }
        finally {
            hostnameStr.close();
        }
    }
}
