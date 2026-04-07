package com.kidspoint.api.config;

import com.kidspoint.api.kids.reward.domain.RewardPurchase;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;
import org.apache.ibatis.type.MappedTypes;
import org.postgresql.util.PGobject;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@MappedTypes(RewardPurchase.PurchaseStatus.class)
@MappedJdbcTypes(JdbcType.OTHER)
public class RewardPurchaseStatusTypeHandler extends org.apache.ibatis.type.BaseTypeHandler<RewardPurchase.PurchaseStatus> {

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, RewardPurchase.PurchaseStatus parameter, JdbcType jdbcType) throws SQLException {
        PGobject pgObject = new PGobject();
        pgObject.setType("reward_purchase_status");
        pgObject.setValue(parameter.name());
        ps.setObject(i, pgObject);
    }

    @Override
    public RewardPurchase.PurchaseStatus getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String value = rs.getString(columnName);
        return value == null ? null : RewardPurchase.PurchaseStatus.valueOf(value);
    }

    @Override
    public RewardPurchase.PurchaseStatus getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        String value = rs.getString(columnIndex);
        return value == null ? null : RewardPurchase.PurchaseStatus.valueOf(value);
    }

    @Override
    public RewardPurchase.PurchaseStatus getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        String value = cs.getString(columnIndex);
        return value == null ? null : RewardPurchase.PurchaseStatus.valueOf(value);
    }
}
