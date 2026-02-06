package com.project;

import java.util.Arrays;
import java.util.List;
import java.util.concurrent.*;

public class Main {

    private static double suma;
    private static double mitjana;
    private static double desviacio;

    public static void main(String[] args) {
        // Conjunto de datos de ejemplo
        List<Double> dades = Arrays.asList(10.0, 20.0, 30.0, 40.0, 50.0);

        // CyclicBarrier para sincronizar 3 tareas y mostrar resultados finales
        CyclicBarrier barrier = new CyclicBarrier(3, () -> {
            System.out.println("=== Resultats finals ===");
            System.out.println("Suma: " + suma);
            System.out.println("Mitjana: " + mitjana);
            System.out.println("Desviació estàndard: " + desviacio);
        });

        // Tarea para calcular la suma
        Runnable tascaSuma = () -> {
            suma = dades.stream().mapToDouble(Double::doubleValue).sum();
            esperar(barrier);
        };

        // Tarea para calcular la media
        Runnable tascaMitjana = () -> {
            mitjana = dades.stream().mapToDouble(Double::doubleValue).average().orElse(0);
            esperar(barrier);
        };

        // Tarea para calcular la desviación estándar
        Runnable tascaDesviacio = () -> {
            double mitjaLocal = dades.stream().mapToDouble(Double::doubleValue).average().orElse(0);
            double var = dades.stream()
                              .mapToDouble(d -> Math.pow(d - mitjaLocal, 2))
                              .average()
                              .orElse(0);
            desviacio = Math.sqrt(var);
            esperar(barrier);
        };

        // ExecutorService con 3 hilos
        ExecutorService executor = Executors.newFixedThreadPool(3);
        executor.submit(tascaSuma);
        executor.submit(tascaMitjana);
        executor.submit(tascaDesviacio);

        // Cerrar executor al final
        executor.shutdown();
    }

    private static void esperar(CyclicBarrier barrier) {
        try {
            barrier.await();
        } catch (InterruptedException | BrokenBarrierException e) {
            e.printStackTrace();
        }
    }
}
