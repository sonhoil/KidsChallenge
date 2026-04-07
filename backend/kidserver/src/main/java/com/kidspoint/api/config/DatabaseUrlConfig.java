package com.kidspoint.api.config;

import org.springframework.boot.context.event.ApplicationEnvironmentPreparedEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;

import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

/**
 * DATABASE_URL 환경 변수를 파싱하여 Spring Boot DataSource 설정에 반영
 */
public class DatabaseUrlConfig implements ApplicationListener<ApplicationEnvironmentPreparedEvent> {

    @Override
    public void onApplicationEvent(ApplicationEnvironmentPreparedEvent event) {
        ConfigurableEnvironment environment = event.getEnvironment();
        String databaseUrl = environment.getProperty("DATABASE_URL");
        
        if (databaseUrl != null && !databaseUrl.isEmpty()) {
            try {
                // Parse DATABASE_URL: postgresql://user:password@host:port/database?schema=boxsage
                URI uri = new URI(databaseUrl);
                
                String userInfo = uri.getUserInfo();
                String host = uri.getHost();
                int port = uri.getPort() == -1 ? 5432 : uri.getPort();
                String path = uri.getPath();
                String query = uri.getQuery();
                
                // Extract database name from path (remove leading /)
                String database = path != null && path.length() > 1 ? path.substring(1) : "postgres";
                
                // Extract username and password from userInfo
                String username = "postgres";
                String password = "";
                if (userInfo != null && !userInfo.isEmpty()) {
                    String[] userPass = userInfo.split(":", 2);
                    username = URLDecoder.decode(userPass[0], StandardCharsets.UTF_8);
                    if (userPass.length > 1) {
                        password = URLDecoder.decode(userPass[1], StandardCharsets.UTF_8);
                    }
                }
                
                // Extract schema from query parameters
                String schema = "public";
                if (query != null && query.contains("schema=")) {
                    String[] params = query.split("&");
                    for (String param : params) {
                        if (param.startsWith("schema=")) {
                            schema = param.substring("schema=".length());
                            break;
                        }
                    }
                }
                
                // Build JDBC URL
                String jdbcUrl = String.format("jdbc:postgresql://%s:%d/%s?currentSchema=%s",
                    host, port, database, schema);
                
                // Set properties
                Map<String, Object> properties = new HashMap<>();
                properties.put("spring.datasource.url", jdbcUrl);
                properties.put("spring.datasource.username", username);
                properties.put("spring.datasource.password", password);
                
                environment.getPropertySources().addFirst(
                    new MapPropertySource("databaseUrlProperties", properties)
                );
                
            } catch (Exception e) {
                throw new RuntimeException("Failed to parse DATABASE_URL: " + databaseUrl, e);
            }
        }
    }
}
