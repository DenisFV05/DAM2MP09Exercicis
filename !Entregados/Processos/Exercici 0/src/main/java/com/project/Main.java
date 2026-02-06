package com.project;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;


public class Main {
    public static void main(String[] args) {
        ExecutorService executor = Executors.newFixedThreadPool(2);

        Runnable registrarEventos = () -> {
            System.out.println(Thread.currentThread().getName() + " → Registrando eventos del sistema...");
            try {
                Thread.sleep(2000); // Simular
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            System.out.println(Thread.currentThread().getName() + " → Eventos registrados.");
        };

        Runnable comprobarRed = () -> {
            System.out.println(Thread.currentThread().getName() + " → Comprobando estado de la red...");
            try {
                Thread.sleep(3000); // Simular 
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            System.out.println(Thread.currentThread().getName() + " → Estado de la red comprobado.");
        };

        // Enviar tasques 
        executor.execute(registrarEventos);
        executor.execute(comprobarRed);

        executor.shutdown();
    }
}
