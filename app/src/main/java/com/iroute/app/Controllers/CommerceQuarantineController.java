package com.iroute.app.Controllers;

import org.springframework.web.bind.annotation.RestController;

import com.iroute.app.Services.CommerceQuarantineService;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;



@RestController
@RequestMapping("/commercequarantine")
@CrossOrigin(origins = "http://localhost:3000")
public class CommerceQuarantineController {

    private CommerceQuarantineService service;

    public CommerceQuarantineController(CommerceQuarantineService service){
        this.service=service;
    }

    @GetMapping("/")
    public ResponseEntity<?> getCommerceQuarantine() {
        try {
            return ResponseEntity.ok(this.service.getAll());
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("code", "EDB");
            error.put("message", "No se pudo cargar los registros en cuarentena");
            error.put("error ", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    @PostMapping("/")
    public ResponseEntity<?> validateCommerceData(@RequestBody Map<String, Object> body) {
        String date = (String)body.get("in_pc_processdate");
        try {
            return ResponseEntity.ok(this.service.validateData(date));
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("code", "EDB");
            error.put("message", "No se pudo cargar los registros en cuarentena");
            error.put("error ", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
}
