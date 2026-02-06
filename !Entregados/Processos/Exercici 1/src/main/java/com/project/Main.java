package com.project;

import java.util.concurrent.Callable;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;


public class Main {
    public static void main(String[] args) {
        ConcurrentHashMap <String, Integer> compteBanc = new ConcurrentHashMap<>();
        
        ExecutorService executor = Executors.newFixedThreadPool(3);
        try { 
            Runnable entraDades = () -> { // T1 INTRODUIR
                compteBanc.put("saldo", 1000);
                System.out.println("Thread 1: Dades inicials -> saldo: " + compteBanc.get("saldo"));
            };

            Runnable calculInteres = () -> { // T2 MODIFICAR
                try {
                    TimeUnit.MILLISECONDS.sleep(100); // 1 segon per que la introducció termini
                    int saldoActual = compteBanc.get("saldo");
                    int saldoNou = saldoActual + saldoActual / 10; // +10%
                    compteBanc.put("saldo", saldoNou);
                    System.out.println("Thread 2: Dades amb interès -> saldo: " + compteBanc.get("saldo"));
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            };

            Callable<Integer> obtenirSaldoFinal = () -> { // T3 LLEGEIX i FINAL
                try {
                    TimeUnit.MILLISECONDS.sleep(200); // Que T2 termini primer
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                int saldoFinal = compteBanc.get("saldo");
                System.out.println("Thread 3: Saldo final -> " + saldoFinal);
                return saldoFinal;
            };

            // Enviar les tasques a l'executor
            executor.execute(entraDades);
            executor.execute(calculInteres);
            Future<Integer> resultatFuture = executor.submit(obtenirSaldoFinal);

            Integer resultatFinal = resultatFuture.get();
            System.out.println("Resultat final: " + resultatFinal);

        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
        } finally {
            executor.shutdown(); // tanca l'executor
        }
    }
}
