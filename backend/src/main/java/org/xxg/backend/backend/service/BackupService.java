package org.xxg.backend.backend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class BackupService {

    @Value("${spring.datasource.username}")
    private String dbUsername;

    @Value("${spring.datasource.password}")
    private String dbPassword;

    // Assuming database name is 'kami' as per application.properties
    private String dbName = "kami";

    private final SettingsService settingsService;

    public BackupService(SettingsService settingsService) {
        this.settingsService = settingsService;
    }

    public String createBackup() throws IOException, InterruptedException {
        String backupDir = "backups";
        File dir = new File(backupDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String fileName = "backup_" + timestamp + ".sql";
        Path backupPath = Paths.get(backupDir, fileName);

        // Construct mysqldump command
        // Note: mysqldump must be in system PATH or specify full path
        // For Windows, it might be tricky if not in PATH. Assuming it is or user configures it.
        // Also handling password securely is important, but for simplicity we pass it inline (warning: visible in process list).
        // Better way: use config file or environment variable.
        
        List<String> commands = Arrays.asList(
                "mysqldump",
                "-u" + dbUsername,
                "-p" + dbPassword,
                "--databases",
                dbName,
                "-r",
                backupPath.toString()
        );
        
        // Check if OS is Windows to run via cmd /c if needed, but ProcessBuilder usually handles executables.
        // However, standard mysqldump usage with -r output file works directly.
        
        ProcessBuilder pb = new ProcessBuilder(commands);
        pb.redirectErrorStream(true); // Capture error output if needed
        Process process = pb.start();
        
        int exitCode = process.waitFor();
        if (exitCode != 0) {
            // Read output
            String output = new String(process.getInputStream().readAllBytes());
            throw new RuntimeException("mysqldump failed with exit code " + exitCode + ": " + output);
        }

        // Apply retention policy
        applyRetentionPolicy(backupDir);

        return backupPath.toString();
    }

    private void applyRetentionPolicy(String backupDir) {
        try {
            String retentionStr = settingsService.getSetting("backupRetention");
            int retentionCount = 7; // Default
            if (retentionStr != null && !retentionStr.isEmpty()) {
                try {
                    retentionCount = Integer.parseInt(retentionStr);
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }

            File dir = new File(backupDir);
            File[] files = dir.listFiles((d, name) -> name.startsWith("backup_") && name.endsWith(".sql"));
            
            if (files != null && files.length > retentionCount) {
                // Sort by last modified (oldest first) or by name (since name has timestamp)
                // Name sorting is safer for timestamps
                List<File> sortedFiles = Arrays.stream(files)
                        .sorted(Comparator.comparing(File::getName))
                        .collect(Collectors.toList());
                
                int filesToDelete = sortedFiles.size() - retentionCount;
                for (int i = 0; i < filesToDelete; i++) {
                    File fileToDelete = sortedFiles.get(i);
                    if (fileToDelete.delete()) {
                        System.out.println("Deleted old backup: " + fileToDelete.getName());
                    } else {
                        System.err.println("Failed to delete old backup: " + fileToDelete.getName());
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Error applying backup retention policy: " + e.getMessage());
        }
    }
}
