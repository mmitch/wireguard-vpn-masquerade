.PHONY: test

all:	test

test:
	cd test; ./run-tests.sh

clean:
	rm -f *~ test/*~ test/tests/*~
