package com.kidspoint.api.config;

import com.kidspoint.api.subscription.domain.Subscription;
import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;
import org.postgresql.util.PGobject;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@MappedJdbcTypes(JdbcType.OTHER)
public class SubscriptionStatusTypeHandler extends BaseTypeHandler<Subscription.Status> {

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, Subscription.Status parameter, JdbcType jdbcType) throws SQLException {
        PGobject pgObject = new PGobject();
        pgObject.setType("subscription_status");
        pgObject.setValue(parameter.name());
        ps.setObject(i, pgObject);
    }

    @Override
    public Subscription.Status getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String value = rs.getString(columnName);
        return value == null ? null : Subscription.Status.valueOf(value);
    }

    @Override
    public Subscription.Status getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        String value = rs.getString(columnIndex);
        return value == null ? null : Subscription.Status.valueOf(value);
    }

    @Override
    public Subscription.Status getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        String value = cs.getString(columnIndex);
        return value == null ? null : Subscription.Status.valueOf(value);
    }
}
