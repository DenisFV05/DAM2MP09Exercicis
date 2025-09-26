package com.project;

import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;


public class Main {
    public static void main(String[] args) {
        ConcurrentHasmap <String, Integer> compteBanc = new ConcurrentHashMap<>();
        
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

            




























        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
