package com.example.helloworld.service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
public class UsuarioServiceTest {

    @Autowired
    UsuarioService usuarioService;

    @Test
    public void testService() {
        assertTrue(usuarioService.getUsuarioList().stream().anyMatch(f -> f.getNome().equals("João")));
    }

}
