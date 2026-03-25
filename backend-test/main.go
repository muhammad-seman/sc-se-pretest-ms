package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

// workerFunction memproses sebagian array, menjumlahkan semua bilangan genap
func workerFunction(id int, chunk []int, resultChan chan<- int, wg *sync.WaitGroup) {
	defer wg.Done()
	
	sum := 0
	for _, val := range chunk {
		if val%2 == 0 {
			sum += val
		}
	}
	
	// Mengembalikan parsial sum ke channel
	resultChan <- sum
	fmt.Printf("Worker %d selesai memproses %d elemen. Parsial sum: %d\n", id, len(chunk), sum)
}

func main() {
	// 1. Persiapan data berupa slice besar
	size := 10_000_000
	fmt.Printf("Mempersiapkan %d data acak...\n", size)
	
	data := make([]int, size)
	for i := 0; i < size; i++ {
		// Mengisi slice dengan angka random sederhana (atau bisa range 1 to size)
		// Kita akan menggunakan angka 1 - 100 agar jumlah sum tidak overflow tipe int.
		data[i] = rand.Intn(100) + 1
	}

	// 2. Setup goroutine
	numWorkers := 4
	chunkSize := len(data) / numWorkers
	
	// Channel untuk mengumpulkan hasil (kapasitas bisa disamakan dengan jumlah worker)
	resultChan := make(chan int, numWorkers)
	
	var wg sync.WaitGroup

	startTime := time.Now()
	fmt.Printf("Memulai proses dengan %d goroutine worker...\n", numWorkers)

	for i := 0; i < numWorkers; i++ {
		startIdx := i * chunkSize
		endIdx := startIdx + chunkSize
		
		// Pastikan worker terakhir memproses sisa pembagian slice jika ada
		if i == numWorkers-1 {
			endIdx = len(data)
		}
		
		chunk := data[startIdx:endIdx]
		
		wg.Add(1)
		go workerFunction(i+1, chunk, resultChan, &wg)
	}

	// 3. Menutup channel di goroutine terpisah
	// Menggunakan wg.Wait() di dalam goroutine anonim untuk menghindari blockage 
	// saat channel sedang menerima data di main goroutine
	go func() {
		wg.Wait()
		close(resultChan)
	}()

	// 4. Mengumpulkan semua hasil kalkulasi sum dari setiap worker
	totalSum := 0
	for partialSum := range resultChan {
		totalSum += partialSum
	}

	elapsed := time.Since(startTime)
	fmt.Println("===================================================")
	fmt.Printf("Proses Selesai dalam waktu: %s\n", elapsed)
	fmt.Printf("Total Sum Seluruh Angka Genap: %d\n", totalSum)
	fmt.Println("===================================================")
}
