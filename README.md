# MGOL Compiler
An MGOL to C compiler using Ruby. This program performs lexic, syntatic and semantic analysis using predefined rules and finite automatas. 
It's actually a transpiler since C code is generated as output, rather than machine code. 
The syntax state machine was hand-crafted as part of the project and you may check it [here](Syntax%20State%20Machine.pdf).
MGOL is a language definition we used to learn compilers throughout the course. 

## Usage

- Install [Ruby 2.3.1](https://www.ruby-lang.org/pt/documentation/installation/)
- Install pry with `gem install pry`
- Write some code in MGOL language. An usable example is [program.mgol](program.mgol).
- Run `ruby main.rb program.mgol` to compile *program.mgol* into *program.c*.

---
This program was developed as final project for the 2018/2 Compilers (INF0031) class of Computer Science course at Universidade Federal de Goiás (UFG, Brazil).
