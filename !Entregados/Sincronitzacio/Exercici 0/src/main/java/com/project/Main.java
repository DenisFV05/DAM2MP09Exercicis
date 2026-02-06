package com.project;

import java.util.Map;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

public class Main {

    private static final ConcurrentHashMap<Integer, Integer> partials = new ConcurrentHashMap<>();

    public static void main(String[] args) {
        System.out.println("Simulant microserveis concurrentment...");

        // Crear barrera per 3 microserveis
        CyclicBarrier barrier = new CyclicBarrier(3, () -> {
            // Combinar resultats quan tots hagin acabat
            int total = partials.values().stream().mapToInt(Integer::intValue).sum();
            System.out.println("=== TOTS els microserveis han acabat ===");
            System.out.println("Parcials: " + partials);
            System.out.println("Resultat global combinat: " + total);
        });

        // Executor amb 3 fils
        ExecutorService executor = Executors.newFixedThreadPool(3);

        executor.submit(microservice(1, barrier));
        executor.submit(microservice(2, barrier));
        executor.submit(microservice(3, barrier));

        executor.shutdown();
        try {
            executor.awaitTermination(10, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    private static Runnable microservice(int id, CyclicBarrier barrier) {
        return () -> {
            try {
                System.out.println("Microservei " + id + " processant dades...");
                // Simular temps de procés
                Thread.sleep(ThreadLocalRandom.current().nextInt(500, 1500));

                // Exemple: càlcul simple
                int partial = 0;
                for (int i = id * 10; i < id * 10 + 5; i++) {
                    partial += i;
                }

                partials.put(id, partial);
                System.out.println("Microservei " + id + " acabat (parcial=" + partial + ")");
                barrier.await(); // Esperar a la resta
            } catch (InterruptedException | BrokenBarrierException e) {
                Thread.currentThread().interrupt();
            }
        };
    }
}
