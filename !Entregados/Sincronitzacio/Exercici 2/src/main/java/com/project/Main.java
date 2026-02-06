package com.project;

import java.util.concurrent.*;

public class Main {

    // Clase que representa el parking
    static class ParkingLot {
        private final Semaphore espacios;

        public ParkingLot(int capacidad) {
            this.espacios = new Semaphore(capacidad);
        }

        public void entrar(String coche) {
            try {
                System.out.println(coche + " intenta entrar...");
                espacios.acquire(); // intenta coger un permiso
                System.out.println(coche + " ha entrado al parking. Espacios disponibles: " + espacios.availablePermits());
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }

        public void salir(String coche) {
            espacios.release(); // libera el permiso
            System.out.println(coche + " ha salido del parking. Espacios disponibles: " + espacios.availablePermits());
        }
    }

    // Runnable que simula la vida de un coche en el parking
    static class Car implements Runnable {
        private final String name;
        private final ParkingLot parking;

        public Car(String name, ParkingLot parking) {
            this.name = name;
            this.parking = parking;
        }

        @Override
        public void run() {
            parking.entrar(name);
            try {
                // Simula el tiempo que el coche está en el parking (1000-3000ms)
                Thread.sleep(ThreadLocalRandom.current().nextInt(1000, 3001));
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            parking.salir(name);
        }
    }

    public static void main(String[] args) {
        int capacidad = 3;    // Capacidad máxima del parking
        int numCoches = 8;    // Número de coches que quieren entrar

        ParkingLot parking = new ParkingLot(capacidad);
        ExecutorService executor = Executors.newFixedThreadPool(numCoches);

        for (int i = 1; i <= numCoches; i++) {
            executor.submit(new Car("Coche " + i, parking));
        }

        executor.shutdown();
        try {
            executor.awaitTermination(30, TimeUnit.SECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        System.out.println("Simulacion finalizada.");
    }
}
