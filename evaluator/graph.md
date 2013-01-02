
## Design of Cirru

#### value

* string
* number
* bool (true / false / nil)

inherent:

```coffee
a = 1
b = a # a == b == 1
b = 2 # a == 1, b == 2
```

#### List

```coffee
a = [1,2]
b = a # a == b == [1,2]
b[1] = 3 # a == [1,2], b == [3,2]
```

#### Map

```coffee
a =
  a: "string"

b = a # a == b == {a: "string"}
b.a = "more" # a == {a: "string"}, b == {a: "more"}

```