package com.kidspoint.api.config;

import com.kidspoint.api.kids.mission.domain.MissionAssignment;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;
import org.apache.ibatis.type.MappedTypes;
import org.postgresql.util.PGobject;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@MappedTypes(MissionAssignment.MissionStatus.class)
@MappedJdbcTypes(JdbcType.OTHER)
public class MissionStatusTypeHandler extends org.apache.ibatis.type.BaseTypeHandler<MissionAssignment.MissionStatus> {

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, MissionAssignment.MissionStatus parameter, JdbcType jdbcType) throws SQLException {
        PGobject pgObject = new PGobject();
        pgObject.setType("mission_status");
        pgObject.setValue(parameter.name());
        ps.setObject(i, pgObject);
    }

    @Override
    public MissionAssignment.MissionStatus getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String value = rs.getString(columnName);
        return value == null ? null : MissionAssignment.MissionStatus.valueOf(value);
    }

    @Override
    public MissionAssignment.MissionStatus getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        String value = rs.getString(columnIndex);
        return value == null ? null : MissionAssignment.MissionStatus.valueOf(value);
    }

    @Override
    public MissionAssignment.MissionStatus getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        String value = cs.getString(columnIndex);
        return value == null ? null : MissionAssignment.MissionStatus.valueOf(value);
    }
}
