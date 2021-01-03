SW: main.o SmithWaterman.o
	g++ main.o SmithWaterman.o -o SW

main.o: SmithWaterman.h main.cpp
	g++ -c main.cpp -o main.o

test.o: SmithWaterman.h SmithWaterman.cpp 
	g++ -c SmithWaterman.cpp -o SmithWaterman.o

clean:
	rm *.o SW