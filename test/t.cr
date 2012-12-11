
echo load\ t.cr
init set-env init

set 0 (number 0)
set 1 (number 1)
set 2 (number 2)
set 3 (number 3)
set 4 (number 4)
set 5 (number 5)
set 6 (number 6)
set 10 (number 10)
set 20 (number 20)

set f1
  fn (n)
    if (< n 2) 1
      +
        f1 (- n 1)
        f1 (- n 2)

print (f1 20)

exit