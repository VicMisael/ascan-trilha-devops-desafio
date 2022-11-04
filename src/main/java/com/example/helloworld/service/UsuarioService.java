package com.example.helloworld.service;

import com.example.helloworld.model.Usuario;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class UsuarioService {

    public List<Usuario> getUsuarioList() {
        return List.
                of(Usuario.builder().nome("João").sobrenome("Almeida").nascimento(new Date()).build(),
                        Usuario.builder().nome("Victor").sobrenome("Misael").nascimento(new Date()).build()
                        , Usuario.builder().nome("Misael").sobrenome("Fenelon").nascimento(new Date()).build());
    }
}
