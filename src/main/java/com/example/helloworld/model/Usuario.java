package com.example.helloworld.model;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Builder
@Getter
@Setter
public class Usuario {
    String nome;
    String sobrenome;
    Date nascimento;
}
