package org.xxg.backend.backend.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;

import jakarta.annotation.PostConstruct;
import javax.sql.DataSource;

@Configuration
public class DatabaseInitializer {

    @Autowired
    private DataSource dataSource;

    @PostConstruct
    public void init() {
        try {
            ResourceDatabasePopulator resourceDatabasePopulator = new ResourceDatabasePopulator(false, false, "UTF-8", new ClassPathResource("schema-advanced.sql"));
            resourceDatabasePopulator.setContinueOnError(true);
            resourceDatabasePopulator.execute(dataSource);
        } catch (Exception e) {
            System.err.println("Failed to initialize advanced schema: " + e.getMessage());
        }
        
        // Force update columns to ensure length is sufficient (in case schema.sql didn't run or was old)
        try {
            java.sql.Connection conn = dataSource.getConnection();
            java.sql.Statement stmt = conn.createStatement();
            try {
                stmt.execute("ALTER TABLE cards MODIFY COLUMN card_key VARCHAR(512)");
                stmt.execute("ALTER TABLE cards MODIFY COLUMN encrypted_key VARCHAR(255)");
                stmt.execute("ALTER TABLE cards MODIFY COLUMN encryption_type VARCHAR(50)");
                System.out.println("Successfully updated cards table columns.");
            } catch (Exception e) {
                System.out.println("Column update might have failed (ignore if already updated): " + e.getMessage());
            } finally {
                stmt.close();
                conn.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Migrate plaintext passwords in admins table
        try {
            java.sql.Connection conn = dataSource.getConnection();
            java.sql.Statement stmt = conn.createStatement();
            java.sql.ResultSet rs = stmt.executeQuery("SELECT id, password FROM admins");
            
            org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder encoder = new org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder();
            
            while (rs.next()) {
                long id = rs.getLong("id");
                String pwd = rs.getString("password");
                
                // Simple check: if password length < 50, it's likely plaintext (BCrypt is 60 chars)
                // Or if it doesn't start with $2a$ or $2y$
                boolean isPlain = false;
                if (pwd == null || pwd.length() < 50) {
                    isPlain = true;
                } else if (!pwd.startsWith("$2a$") && !pwd.startsWith("$2y$")) {
                    isPlain = true;
                }
                
                if (isPlain) {
                    String newHash = encoder.encode(pwd);
                    java.sql.PreparedStatement ps = conn.prepareStatement("UPDATE admins SET password = ? WHERE id = ?");
                    ps.setString(1, newHash);
                    ps.setLong(2, id);
                    ps.executeUpdate();
                    ps.close();
                    System.out.println("Migrated plaintext password for admin id: " + id);
                }
            }
            rs.close();
            stmt.close();
            conn.close();
        } catch (Exception e) {
             System.out.println("Password migration check failed: " + e.getMessage());
        }
    }
}
