
Simple demo of Cirru Shell
------

### Usage

```bash
➤➤ npm install -g cirru-shell
➤➤ cirru-shell
```

Tab completion is supported, try it.

Notice that values and mathods are not store in the same table.

A demo of running Cirru Shell:

```
cirru> number 1
=> 1

cirru> string 2
=> 2

cirru> array 1
=> [ 1 ]

cirru> array (array (array (map )
=> [ [ [ {} ] ] ]

cirru> array (array (array (map (a $ number 4)))
=> [ [ [ [Object] ] ] ]

cirru> set a 1
=> 1

cirru> get a
=> 1

cirru> set a $ map (b 4) (c 5)
=> { b: 4, c: 5 }

cirru> display
=> [ 'a' ]

cirru> level
=> 0

cirru> forward a
=> { b: 4, c: 5 }

cirru> display
=> [ 'b', 'c' ]

cirru> level
=> 1

cirru> back
=> { a: { b: 4, c: 5 } }

cirru> level
=> 0

cirru> set d $ array 1 2 3 4 5
=> [ 1, 2, 3, 4, 5 ]

cirru> e d
display   define

cirru> forward d
=> [ 1, 2, 3, 4, 5 ]

cirru> display
=> [ '0', '1', '2', '3', '4' ]

cirru> level
=> 1

cirru> get 0
=> 1

cirru> get 2
=> 3

cirru> back
=> { a: { b: 4, c: 5 }, d: [ 1, 2, 3, 4, 5 ] }

cirru> + 1 2 3
=> 6

cirru> + 1 2 3 (- 6 2)
=> 10

cirru> define (add a b c) (+ a b c)
=> [Function]

cirru> add 1 2 3
=> 6

cirru> define (times-2 x) (set y x) (+ x y)
=> [Function]

cirru> times-2 3
=> 6
```

### Tab completion

available for functions, values and parentheses.