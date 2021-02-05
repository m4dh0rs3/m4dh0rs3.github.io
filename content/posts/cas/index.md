---
title: "Computer–algebra–system in Rust"
math: true
mermaid: true
summary: "How does a computer translate complex, symbol heavy expressions to simple machine code instructions?"
---

Modern calculators automate most of the generic maths, even bridge to computing. Even though on the hardware level, they are just computers, operating in binary arithmetics, they can

- differentiate, integrate
- solve for $n$, solve to $y$, solve sets of equations
- evaluate infinite series, limits

and much more. Also the simple stuff you don't even notice like trigonometric functions (or preschool math like divisions by hand for that matter...), everything is been taking care of by your calculator. But these all aren't binary logic or electronic circuits.

> How does a computer translate complex, symbol heavy expressions to simple machine code instructions?

This is the task of a _computer–algebra–system_, `CAS` for short. At the surface, it's the shell you type your expressions in, behind the scenes it's very similar to a compiler.

## Algebraic expressions

> But let's get started with the very basics. What is an expression?

The type of math you learn in school is mostly algebra and analysis. What you write down on your paper are expressions, they convey a special meaning of mathematical definitions and relationships.

They are called algebraic expressions:

<p>
$$
\pi = 3.14159\dots \\
10cm \\
y = 5x^3 \\
4.3 - \pi^2 = sin(a)
$$
</p>

### Tokens

It can be split up into tokens, which have two types:

Token | is a | Example
--- | --- | ---
**Atom** | number, symbol, element of a set | $4.3, \pi, 2, a$
**Operator** | function manipulating atom(s) | $-$, `^`[^2], $=, sin$

<script src="https://gist.github.com/m4dh0rs3/d12d29b79fcc545e9a61cb75f9e0d60c.js"></script>

### Operators

Operators and their operants relate in a special syntactical way. These properties are precedence, associativity and the number of arguments.

#### Operator types

There are three possibilities, if you ignore sets, to give the operator it's arguments.

Operator type | Sequence | Operators
--- | --- | ---
Prefix | $\circ a$ | $+, -, f$ (call)
Postfix | $a \circ$ | $!$
Infix | $a \circ b$ | $+, -, *, \div, \dots$

#### Precedence

The operator precedence decides, what operator has to be evaluated first.

Precedence | Infix operator | Sequence
--- | --- | ---
1 | $.$, `_` (child) | $(A_b)^c$
2 | `^` | $(a^b)*c$
3 | $*, \div$ | $(a*b)+c$
4 | $+, -$ | $(a+b) \land c$
5 | $\land, \lor, \%$ (modulus) | $c(a + b)$
6 | $f$ (call) | $(a(b))=c$
7 | $=, \neq, >, <, \geq, \leq$ | $(a = b), c$[^1]
8 | $,$ (tuple) | $[a, b] := c$
9 | $:=$ (definition) | $(a):=(c)$

#### Associativity

Associativity is the order of arguments of infix operators.

Operator | Associativity | Sequence
--- | --- | ---
$+, -, *, \div, \dots$ | Left to right | $(a \circ b) \circ c$
$=, \neq, >, <, \geq, \leq$ | Right to left | $a \circ (b \circ c)$

<script src="https://gist.github.com/m4dh0rs3/3d4437e37ed147aa9656640d7181a164.js"></script>

### Notation

We normally write such expressions in **infix-notation**, where one has to know these rules to correctly interpret an expression and evaluate it in the right order.

But there is an alternative notation, called **polish-notation**, which simplifies it very much.

$4.3 - \pi^2 = sin(a)$ becomes `= sin a - 4.3 ^ π 2`.

The associativity and order of operations is now the order of characters in the linear sequence. Every operation is a list of arguments, starting with the operator.

### Expression tree

You can rewrite an expression into an expression tree, which is the visual equivalent of the polish-notation. Compilers of programming languages also often create an expression tree. Of course they operate on a wider scope, given a sequence of expressions.

{{<mermaid>}}
graph TD
    A(=)
    B("-")
    C(sin)
    A --- C
    A --- B
    D((a))
    C --- D
    E((4.3))
    F("^")
    G((π))
    H((2))
    B --- E
    B --- F
    F --- G
    F --- H
{{</mermaid>}}

The leafs are atoms and the parents nodes are operators.

<script src="https://gist.github.com/m4dh0rs3/b41cad9671d0e18b9324ce03256a04a4.js"></script>

## CAS structure

The endgoal of an `CAS` is to evaluate an expression in infix-notation. For that we have to translate the input into an expression tree, which than can be evaluated.

Given a string:

1. Lexer $\to$ split it into a sequence of tokens.
2. Parser $\to$ reorder them into an expression tree
3. Eval $\to$ single atom / simplified expression

### Lexer

The lexer creates a stream of tokens given a string. A stream means it doesn't have to return all tokens at once, but can step token by token. For that it needs to know what kind of token it is returning, and where it begins and ends. The most important tool of the lexer is to look one char ahead. Every token can be classified by it's first character. Now the lexer is in one of two states:

First char | Token
--- | ---
`+-*/:^%()[]{},;_<>!~=` | Operator
`a-Z, α-Ω` | Atom: Symbol
`0-9, .`[^3] | Atom: Number
`  \t\n` | Whitespace

<script src="https://gist.github.com/m4dh0rs3/3eb79b869090a4dfe51fd0865435b069.js"></script>

<script src="https://gist.github.com/m4dh0rs3/1d3b2ace1a8051bfcd164e5080e89dd3.js"></script>

#### Operators

Operators consist of maximum 2 characters. Because the lexer already knows from the first char if it is an operator, it can step and have a look at the second one. It can compare them to a list of possible operators and than return the first character or both.

<script src="https://gist.github.com/m4dh0rs3/9a842f87b61858821707e28a6b8cc53d.js"></script>

#### Symbols

Symbols can have indefinite length, the lexer can step until either the expression ends, or another token begins. Now, another token could also be a symbol. For that special case, all symbols definitions are checked character by character if the symbol has to be split up into a multiplication expression. If the symbols is defined as a function call, the lexer returns an prefix operator.

#### Numbers

Numbers are more complicated, because they can also contain a decimal and an power extension, with a minus sign. These are treated all optional.

### Parser

## Evaluate

### Environment

[^1]: If the separation operator really has higher precedency than a comparison is debatable. Note that a tuple normally comes with parenthesis, which delimit the expression, not needing any precedence.

[^2]: Unless your calculator interface supports a special type of expression editor (called [WYSIWYG](https://en.wikipedia.org/wiki/WYSIWYG)), you type it as an linear sequence of characters: `4.3 - π^2 = sin y` (the power operation $a^b$ for example becomes `a^b`).

[^3]: Numbers on a different basis often use a wider set of characters. Hexadecimal numbers consist of `0-9, A-F`. That's why many implementations require a `0x` in front of the hex, so the lexer can work with it more easily.