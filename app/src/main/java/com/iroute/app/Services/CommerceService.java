package com.iroute.app.Services;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class CommerceService {

    @Autowired
    JdbcTemplate jdbcTemplate;

    public Map<String, Object> processCsv(MultipartFile file) {
        Map<String, Object> out = new HashMap<>();
        try {

            InputStreamReader inputStreamReader = new InputStreamReader(file.getInputStream());
            BufferedReader bufferedReader = new BufferedReader(inputStreamReader);

            List<String> lines = bufferedReader.lines().toList();

            int inserted = 0;
            int errors = 0;
            for (int i = 1; i < lines.size(); i++) {
                String[] column = lines.get(i).split(",");

                String pc_processdate = null;

                if (validarFecha(column[2])) {
                    pc_processdate = column[2];
                }

            
                String pc_nomcomred = column.length > 0 ? column[0] : "";
                String pc_numdoc = column.length > 1 ? column[1] : "";
                String pc_direccion = column.length > 3 ? column[3] : "";
                String pc_telefono = column.length > 3 ? column[4] : "";
                String pc_email = column.length > 5 ? column[5] : "";

                callSPCreateCommerce(pc_nomcomred, pc_numdoc, pc_processdate, pc_direccion, pc_telefono, pc_email);
                inserted++;
            }
            out.put("inserted", inserted);
            out.put("errors", errors);

        } catch (IOException e) {
            e.printStackTrace();
            out.put("error", e.getMessage());
        }
        return out;
    }

    private void callSPCreateCommerce(String name, String doc, String proDate, String direcc, String phone,
            String email) {
        jdbcTemplate.update(
                "CALL sp_create_commerce(?, ?, ?, ?, ?, ?)",
                name,
                doc,
                proDate,
                direcc,
                phone,
                email);

    }

    public static boolean validarFecha(String fecha) {
        try {
            LocalDate.parse(fecha);
            return true;
        } catch (DateTimeParseException e) {
            return false;
        }
    }
}
