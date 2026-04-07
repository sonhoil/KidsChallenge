package com.kidspoint.api.config;

import com.kidspoint.api.organization.domain.OrganizationMember;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;
import org.apache.ibatis.type.MappedTypes;
import org.postgresql.util.PGobject;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@MappedTypes(OrganizationMember.OrgRole.class)
@MappedJdbcTypes(JdbcType.OTHER)
public class UserRoleTypeHandler extends org.apache.ibatis.type.BaseTypeHandler<OrganizationMember.OrgRole> {

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, OrganizationMember.OrgRole parameter, JdbcType jdbcType) throws SQLException {
        PGobject pgObject = new PGobject();
        // 스키마 이름 포함: boxsage.user_role
        pgObject.setType("boxsage.user_role");
        pgObject.setValue(parameter.name());
        ps.setObject(i, pgObject);
    }

    @Override
    public OrganizationMember.OrgRole getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String value = rs.getString(columnName);
        return value == null ? null : OrganizationMember.OrgRole.valueOf(value);
    }

    @Override
    public OrganizationMember.OrgRole getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        String value = rs.getString(columnIndex);
        return value == null ? null : OrganizationMember.OrgRole.valueOf(value);
    }

    @Override
    public OrganizationMember.OrgRole getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        String value = cs.getString(columnIndex);
        return value == null ? null : OrganizationMember.OrgRole.valueOf(value);
    }
}
