package com.kidspoint.api.config;

import com.kidspoint.api.kids.family.domain.FamilyMember;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;
import org.apache.ibatis.type.MappedTypes;
import org.postgresql.util.PGobject;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@MappedTypes(FamilyMember.FamilyRole.class)
@MappedJdbcTypes(JdbcType.OTHER)
public class FamilyRoleTypeHandler extends org.apache.ibatis.type.BaseTypeHandler<FamilyMember.FamilyRole> {

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, FamilyMember.FamilyRole parameter, JdbcType jdbcType) throws SQLException {
        PGobject pgObject = new PGobject();
        pgObject.setType("family_role");
        pgObject.setValue(parameter.name());
        ps.setObject(i, pgObject);
    }

    @Override
    public FamilyMember.FamilyRole getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String value = rs.getString(columnName);
        return value == null ? null : FamilyMember.FamilyRole.valueOf(value);
    }

    @Override
    public FamilyMember.FamilyRole getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        String value = rs.getString(columnIndex);
        return value == null ? null : FamilyMember.FamilyRole.valueOf(value);
    }

    @Override
    public FamilyMember.FamilyRole getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        String value = cs.getString(columnIndex);
        return value == null ? null : FamilyMember.FamilyRole.valueOf(value);
    }
}
