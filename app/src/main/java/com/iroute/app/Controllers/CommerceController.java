package com.iroute.app.Controllers;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.iroute.app.Services.CommerceService;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PostMapping;

@RestController
@RequestMapping("/commerces")
@CrossOrigin(origins = "http://localhost:3000")
public class CommerceController {

    @GetMapping("/")
    public String getMethodName() {
        return "SALUDOS";
    }

    private CommerceService service;

    public CommerceController(CommerceService service) {
        this.service = service;
    }

    @PostMapping("/")
    public ResponseEntity<?> saveCommerces(@RequestParam("file") MultipartFile file,
            RedirectAttributes redirectAttributes) {
        Map<String, Object> error = new HashMap<>();
        if (file == null || file.isEmpty()) {
            error.put("code", "EEF");
            error.put("message", "El archivo enviado está vacío");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
        try {

            Map<String, Object> result = service.processCsv(file);
            if (result.containsKey("error")) {
                error.put("code", "EDB");
                error.put("message", "Error con crear los registros");
                error.put("error ", result.get("error"));
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
            }

            result.put("message", "Archivo recibido correctamente");
            result.put("filename", file.getOriginalFilename());
            return ResponseEntity.ok(result);

        } catch (Exception e) {
            error.put("code", "EDB");
            error.put("message", "No se pudo cargar los registros en cuarentena");
            error.put("error ", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

}
