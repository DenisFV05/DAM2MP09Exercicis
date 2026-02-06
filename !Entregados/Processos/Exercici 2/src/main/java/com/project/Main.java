package com.project;

import java.util.concurrent.CompletableFuture;

public class Main {

    public static void main(String[] args) {

        // Primera etapa: validar datos (supplyAsync)
        CompletableFuture<String> validacio = CompletableFuture.supplyAsync(() -> {
            System.out.println("Validant dades de la sol·licitud...");
            try { Thread.sleep(1000); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
            return "Dades inicials correctes";
        });

        // Segona etapa: processar dades (thenApply)
        CompletableFuture<String> proces = validacio.thenApply(dades -> {
            System.out.println("Processant dades...");
            try { Thread.sleep(1500); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
            return dades + " -> Resultat calculat";
        });

        // Tercera etapa: mostrar resposta (thenAccept)
        CompletableFuture<Void> resposta = proces.thenAccept(resultat -> {
            System.out.println("Enviant resposta a l'usuari: " + resultat);
        });

        // Esperar que tota la cadena asíncrona acabi abans de finalitzar
        resposta.join();

        System.out.println("Procés completat.");
    }
}
