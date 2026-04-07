package com.kidspoint.api.config;

import com.kidspoint.api.organization.domain.Organization;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;
import org.apache.ibatis.type.MappedTypes;
import org.postgresql.util.PGobject;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@MappedTypes(Organization.Plan.class)
@MappedJdbcTypes(JdbcType.OTHER)
public class OrganizationPlanTypeHandler extends org.apache.ibatis.type.BaseTypeHandler<Organization.Plan> {

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, Organization.Plan parameter, JdbcType jdbcType) throws SQLException {
        PGobject pgObject = new PGobject();
        // 스키마 이름 포함: boxsage.organization_plan
        pgObject.setType("boxsage.organization_plan");
        pgObject.setValue(parameter.name());
        ps.setObject(i, pgObject);
    }

    @Override
    public Organization.Plan getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String value = rs.getString(columnName);
        return value == null ? null : Organization.Plan.valueOf(value);
    }

    @Override
    public Organization.Plan getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        String value = rs.getString(columnIndex);
        return value == null ? null : Organization.Plan.valueOf(value);
    }

    @Override
    public Organization.Plan getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        String value = cs.getString(columnIndex);
        return value == null ? null : Organization.Plan.valueOf(value);
    }
}
