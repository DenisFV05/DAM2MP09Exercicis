package com.project;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;


public class Main {
    public static void main(String[] args) {
        // Crear un pool de 2 hilos
        ExecutorService executor = Executors.newFixedThreadPool(2);

        // Definir la primera tasca: registrar eventos del sistema
        Runnable registrarEventos = () -> {
            System.out.println(Thread.currentThread().getName() + " → Registrando eventos del sistema...");
            try {
                Thread.sleep(2000); // Simular procesamiento
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            System.out.println(Thread.currentThread().getName() + " → Eventos registrados.");
        };

        // Definir la segunda tasca: comprobar estado de la red
        Runnable comprobarRed = () -> {
            System.out.println(Thread.currentThread().getName() + " → Comprobando estado de la red...");
            try {
                Thread.sleep(3000); // Simular procesamiento
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            System.out.println(Thread.currentThread().getName() + " → Estado de la red comprobado.");
        };

        // Enviar tasques al executor
        executor.execute(registrarEventos);
        executor.execute(comprobarRed);

        // Cerrar executor (libera recursos)
        executor.shutdown();
    }
}
