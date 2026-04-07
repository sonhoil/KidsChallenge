package com.kidspoint.api.config;

import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.type.JdbcType;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;

import com.kidspoint.api.organization.domain.Organization;
import com.kidspoint.api.organization.domain.OrganizationMember;
import com.kidspoint.api.subscription.domain.Subscription;
import com.kidspoint.api.kids.mission.domain.MissionAssignment;
import com.kidspoint.api.kids.family.domain.FamilyMember;
import com.kidspoint.api.kids.reward.domain.RewardPurchase;
import javax.sql.DataSource;
import java.util.UUID;

@Configuration
@MapperScan(basePackages = "com.kidspoint.api")
public class MyBatisConfig {

    @Bean
    public SqlSessionFactory sqlSessionFactory(DataSource dataSource) throws Exception {
        SqlSessionFactoryBean sessionFactory = new SqlSessionFactoryBean();
        sessionFactory.setDataSource(dataSource);
        
        // MyBatis XML 매퍼 파일 위치 설정
        PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
        sessionFactory.setMapperLocations(
            resolver.getResources("classpath:mapper/**/*.xml")
        );
        
        // MyBatis 설정
        org.apache.ibatis.session.Configuration configuration = new org.apache.ibatis.session.Configuration();
        configuration.setMapUnderscoreToCamelCase(true);
        configuration.setDefaultFetchSize(100);
        configuration.setDefaultStatementTimeout(30);
        
        // UUID TypeHandler 등록
        configuration.getTypeHandlerRegistry().register(java.util.UUID.class, org.apache.ibatis.type.JdbcType.OTHER, new UUIDTypeHandler());
        
        // Organization.Plan TypeHandler 등록
        configuration.getTypeHandlerRegistry().register(Organization.Plan.class, org.apache.ibatis.type.JdbcType.OTHER, new OrganizationPlanTypeHandler());
        
        // OrganizationMember.OrgRole TypeHandler 등록
        configuration.getTypeHandlerRegistry().register(OrganizationMember.OrgRole.class, org.apache.ibatis.type.JdbcType.OTHER, new UserRoleTypeHandler());
        
        // Subscription.Status TypeHandler 등록
        configuration.getTypeHandlerRegistry().register(Subscription.Status.class, org.apache.ibatis.type.JdbcType.OTHER, new SubscriptionStatusTypeHandler());
        
        // MissionAssignment.MissionStatus TypeHandler 등록
        configuration.getTypeHandlerRegistry().register(MissionAssignment.MissionStatus.class, org.apache.ibatis.type.JdbcType.OTHER, new MissionStatusTypeHandler());
        
        // FamilyMember.FamilyRole TypeHandler 등록
        configuration.getTypeHandlerRegistry().register(FamilyMember.FamilyRole.class, org.apache.ibatis.type.JdbcType.OTHER, new FamilyRoleTypeHandler());
        
        // RewardPurchase.PurchaseStatus TypeHandler 등록
        configuration.getTypeHandlerRegistry().register(RewardPurchase.PurchaseStatus.class, org.apache.ibatis.type.JdbcType.OTHER, new RewardPurchaseStatusTypeHandler());
        
        sessionFactory.setConfiguration(configuration);
        
        return sessionFactory.getObject();
    }
}
