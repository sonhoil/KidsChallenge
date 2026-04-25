package com.kidspoint.server;

import com.kidspoint.api.config.DatabaseUrlConfig;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication(scanBasePackages = {"com.kidspoint.server", "com.kidspoint.api"})
@EnableScheduling
public class KidspointApplication {

	public static void main(String[] args) {
		SpringApplication app = new SpringApplication(KidspointApplication.class);
		// DATABASE_URL 환경 변수가 있으면 자동으로 파싱
		// 없으면 application.properties의 설정 사용
		app.addListeners(new DatabaseUrlConfig());
		app.run(args);
	}

}
