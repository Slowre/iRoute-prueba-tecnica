package com.iroute.app.Services;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;

@Service
public class CommerceQuarantineService {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;

    public List<Map<String, Object>> getAll() {
        String sql = "SELECT * FROM commerce_quarantine;";
        return jdbcTemplate.queryForList(sql);
    }

    public Map<String, Object> validateData(String processdate) {
        Map<String, Object> out = new HashMap<>();

        SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_validate_commerce");

        SqlParameterSource params = new MapSqlParameterSource()
                .addValue("in_pc_processdate",processdate);

        Map<String, Object> results = simpleJdbcCall.execute(params);


        out.putAll(results);
        return out;
    }
}
